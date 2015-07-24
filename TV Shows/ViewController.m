//
//  ViewController.m
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "ViewController.h"
#import "NameTableCellView.h"
#import "DetailTableCellView.h"
#import "HelpViewController.h"
#import "NSImage+Blur.h"
#import "SSZipArchive.h"

@implementation ViewController {
	NSMutableArray *FullList;
	NSMutableArray *ShowList;
	
	BOOL allowDragDrop;
	SortOrder sortOrder;
	
	NSInteger episodeCount;
	CGFloat sizeCount;
	
	NSInteger tEpisodeCount;
	CGFloat tSizeCount;
	
	BOOL optionKeyPressed;
	
	BRRequestUpload *uploadFile;
	NSData *uploadData;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view.
	
	_addButton.alphaValue = 0.0;
	_sortOrderButton.alphaValue = 0.0;
	_rearrangeButton.alphaValue = 0.0;
	_generatorButton.alphaValue = 0.0;
	_informationButton.alphaValue = 0.0;
	_tableView.alphaValue = 0.5;
	_titleLabel.alphaValue = 0.0;
	
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		context.duration = 1.6f;
		context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		[_addButton.animator setAlphaValue:1.f];
		[_sortOrderButton.animator setAlphaValue:1.f];
		[_rearrangeButton.animator setAlphaValue:1.f];
		[_generatorButton.animator setAlphaValue:1.f];
		[_informationButton.animator setAlphaValue:1.f];
		[_tableView.animator setAlphaValue:1.f];
		[_titleLabel.animator setAlphaValue:1.f];
	} completionHandler:nil];
	
	_tableView.dataSource = self;
	_tableView.delegate = self;
	
	[self.tableView registerForDraggedTypes: [NSArray arrayWithObjects:@"public.text", nil]];
	
	NSString *filepath = [self documentsPathForFileName:[NSString stringWithFormat:@"TVShows.dat"]];
	if (![NSData dataWithContentsOfFile:filepath])
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"TVShows.dat" ofType:nil]] options:kNilOptions error:nil];
	else
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filepath] options:kNilOptions error:nil];
	
	ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
	
	allowDragDrop = NO;
	optionKeyPressed = NO;
	sortOrder = ([[NSUserDefaults standardUserDefaults] integerForKey:@"SortOrder"] != 0)?[[NSUserDefaults standardUserDefaults] integerForKey:@"SortOrder"]:SortOrder_RANKING;
	[self sortList];
	[self updateSortAndInformationLabels];
	
//	[self updateAppIcon];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

-(void)updateAppIcon {
	
//	CIImage *image = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForImageResource:@"icon"]]];
	
//	NSGraphicsContext *iconContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:[NSBitmapImageRep imageRepWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForImageResource:@"icon"]]]];
	
//	NSTextField *field = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(67, 83, 117, 86))];
//	field.stringValue = [NSString stringWithFormat:@"%li", ShowList.count];
//	field.font = [NSFont fontWithName:@"DINAlternate-Bold" size:24.f];
	
	[[NSString stringWithFormat:@"%li", ShowList.count] drawInRect:NSRectFromCGRect(CGRectMake(67, 83, 117, 86)) withAttributes:@{NSFontAttributeName: [NSFont fontWithName:@"DINAlternate-Bold" size:24.f]}];
	
//	NSImage *image = [[iconContext CIContext] ]
	
	[[NSApplication sharedApplication] setApplicationIconImage: [NSImage imageNamed:@"AppIcon"]];
}

// Open a file and set it as data source...
- (IBAction)openAction:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Choose a probably '.dat' data source file...";
	openPanel.showsHiddenFiles = NO;
	openPanel.canChooseDirectories = NO;
	openPanel.canCreateDirectories = NO;
	openPanel.allowsMultipleSelection = NO;
	[openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
		if (result == NSModalResponseOK) {
			NSURL *selection = openPanel.URLs[0];
			NSString *filepath = [selection.path stringByResolvingSymlinksInPath];
			if (![NSData dataWithContentsOfFile:filepath])
				FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"TVShows.dat" ofType:nil]] options:kNilOptions error:nil];
			else
				FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filepath] options:kNilOptions error:nil];
			
			ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];

			allowDragDrop = NO;
			sortOrder = SortOrder_RANKING;
			
			[self.tableView reloadData];
			[self updateSortAndInformationLabels];
		}
	}];
}

#pragma mark - Key presses

- (void)flagsChanged:(NSEvent *)theEvent {
	if ([theEvent modifierFlags] & NSAlternateKeyMask)
		optionKeyPressed = YES;
	else
		optionKeyPressed = NO;
	[self.tableView reloadData];
}

#pragma mark - Share and upload

- (IBAction)shareAction:(id)sender {
	// Upload the database to the server.
	[SSZipArchive createZipFileAtPath:[self documentsPathForFileName:@"shows.zip"] withFilesAtPaths:[NSArray arrayWithObjects:[self documentsPathForFileName:@"TVShows.dat"], nil]];
	
	NSString *filepath = [self documentsPathForFileName:@"shows.zip"];
	uploadData = [NSData dataWithContentsOfFile:filepath];
	
	uploadFile = [[BRRequestUpload alloc] initWithDelegate:self];
	
	uploadFile.path = @"/public_html/shows.zip";
	uploadFile.hostname = @"lordykw.comxa.com";
	uploadFile.username = @"a8163043";
	uploadFile.password = @"789UIOjkl";
	
	[uploadFile start];
}

-(BOOL) shouldOverwriteFileWithRequest: (BRRequest *) request {
	//----- set this as appropriate if you want the file to be overwritten
	if (request == uploadFile) {
		//----- if uploading a file, we set it to YES (if set to NO, nothing happens)
		return YES;
	}
	return NO;
}

- (NSData *) requestDataToSend: (BRRequestUpload *) request {
	//----- returns data object or nil when complete
	//----- basically, first time we return the pointer to the NSData.
	//----- and BR will upload the data.
	//----- Second time we return nil which means no more data to send
	NSData *temp = uploadData;   // this is a shallow copy of the pointer
	uploadData = nil;            // next time around, return nil...
	return temp;
}

-(void) requestCompleted: (BRRequest *) request {
	if (request == uploadFile) {
		NSLog(@"upload to '%@' completed!", request.hostname);
		uploadFile = nil;
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:[NSString stringWithFormat:@"Upload success."]];
		[alert setInformativeText:@"File \"shows.zip\" upload to server \"lordykw.comxa.com\" successfully completed."];
		[alert addButtonWithTitle:@"Okie Dokie."];
		[alert runModal];
	}
}

-(void) requestFailed:(BRRequest *) request {
	if (request == uploadFile) {
		NSLog(@"Error in uploading: %@", request.error.message);
		uploadFile = nil;
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:[NSString stringWithFormat:@"Upload failed."]];
		[alert setInformativeText:[NSString stringWithFormat:@"File \"shows.zip\" upload to server \"lordykw.comxa.com\" failed with error: %@.", request.error.message]];
		[alert addButtonWithTitle:@"Okie Dokie."];
		[alert runModal];
	}
}


#pragma mark - Sorting actions

- (IBAction)rearrangeAction:(id)sender {
	_rearrangeButton.state = ![sender state];
	if (sortOrder == SortOrder_RANKING)
		allowDragDrop = !allowDragDrop;
	else
		allowDragDrop = NO;
	if (allowDragDrop)
		_rearrangeButton.title = @"Rearranging...";
	else
		_rearrangeButton.title = @"Rearrange";
}

- (IBAction)sortAction:(id)sender {
	sortOrder = [sender tag];
	[[NSUserDefaults standardUserDefaults] setInteger:[sender tag] forKey:@"SortOrder"];
	[self sortList];
	_sortOrderButton.title = [sender title];
	_rearrangeButton.title = @"Rearrange";
}

- (void)sortList {
	[self sortListWithSortOrder:sortOrder];
	allowDragDrop = NO;
	[self.tableView reloadData];
	[self updateSortAndInformationLabels];
}

-(void)sortListWithSortOrder:(SortOrder)sorder {
	ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
	switch (sorder) {
		case 1:
			break;
		case 2: {
			NSArray *sortedArray = [ShowList sortedArrayUsingComparator:^(TVShow *a, TVShow *b) {
				return [a.Title caseInsensitiveCompare:b.Title];
			}];
			ShowList = [[NSMutableArray alloc] initWithArray:sortedArray];
		}
			break;
		case 3: {
			NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
			for (TVShow *show in ShowList) {
				if ([show.Detail containsString:@"CURRENTLY_FOLLOWING"])
					[sortedArray addObject:show];
			}
			ShowList = sortedArray;
		}
			break;
		case 4: {
			NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
			for (TVShow *show in ShowList) {
				if ([show.Detail containsString:@"TO_BE_DOWNLOADED"])
					[sortedArray addObject:show];
			}
			ShowList = sortedArray;
		}
			break;
		case 5: {
			NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
			for (TVShow *show in ShowList) {
				if ([show.Detail containsString:@"TO_BE_ENCODED"])
					[sortedArray addObject:show];
			}
			ShowList = sortedArray;
		}
			break;
		case 6: {
			NSArray *sortedArray = [ShowList sortedArrayUsingComparator:^(TVShow *a, TVShow *b) {
				if ([TVShow numberOfEpisodesInString:a.Detail] > [TVShow numberOfEpisodesInString:b.Detail])
					return NSOrderedDescending;
				else if ([TVShow numberOfEpisodesInString:a.Detail] < [TVShow numberOfEpisodesInString:b.Detail])
					return NSOrderedAscending;
				return NSOrderedSame;
			}];
			ShowList = [[NSMutableArray alloc] initWithArray:sortedArray];
		}
			break;
		case 7: {
			NSArray *sortedArray = [ShowList sortedArrayUsingComparator:^(TVShow *a, TVShow *b) {
				if ([TVShow numberOfEpisodesInString:a.Detail] < [TVShow numberOfEpisodesInString:b.Detail])
					return NSOrderedDescending;
				else if ([TVShow numberOfEpisodesInString:a.Detail] > [TVShow numberOfEpisodesInString:b.Detail])
					return NSOrderedAscending;
				return NSOrderedSame;
			}];
			ShowList = [[NSMutableArray alloc] initWithArray:sortedArray];
		}
			break;
		case 8: {
			NSArray *sortedArray = [ShowList sortedArrayUsingComparator:^(TVShow *a, TVShow *b) {
				if ([TVShow sizeOfShowFromString:a.Detail] > [TVShow sizeOfShowFromString:b.Detail])
					return NSOrderedDescending;
				else if ([TVShow sizeOfShowFromString:a.Detail] < [TVShow sizeOfShowFromString:b.Detail])
					return NSOrderedAscending;
				return NSOrderedSame;
			}];
			ShowList = [[NSMutableArray alloc] initWithArray:sortedArray];
		}
			break;
		case 9: {
			NSArray *sortedArray = [ShowList sortedArrayUsingComparator:^(TVShow *a, TVShow *b) {
				if ([TVShow sizeOfShowFromString:a.Detail] < [TVShow sizeOfShowFromString:b.Detail])
					return NSOrderedDescending;
				else if ([TVShow sizeOfShowFromString:a.Detail] > [TVShow sizeOfShowFromString:b.Detail])
					return NSOrderedAscending;
				return NSOrderedSame;
			}];
			ShowList = [[NSMutableArray alloc] initWithArray:sortedArray];
		}
			break;
		default:
			break;
	}
}

-(void)didFinishSelectingSortOrder:(NSInteger)sorder AndSortTitle:(NSString *)sortTitle {
	sortOrder = sorder;
	[self sortList];
	_sortOrderButton.title = sortTitle;
	_rearrangeButton.title = @"Rearrange";
}

#pragma mark - Table view datasource and delegates

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	return 32.f;
}

//-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
//	[tableView reloadData];
//	return YES;
//}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [ShowList count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	TVShow *show = [ShowList objectAtIndex:row];
	if ([tableColumn.title isEqualToString:@"Name"]) {
		NameTableCellView *ntsv = [self.tableView makeViewWithIdentifier:@"nameTableCell" owner:self];
		ntsv.nameTextField.stringValue = [NSString stringWithFormat:@"%@", show.Title];
		ntsv.rankTextField.stringValue = [NSString stringWithFormat:@"%4ld. ", (long)row+1];
		ntsv.dayTextField.stringValue = @"";
		if (show.CURRENTLY_FOLLOWING)
			ntsv.dayTextField.stringValue = show.Day;
//		if (row == tableView.selectedRow) {
//			ntsv.backgroundImageView.image = [[[[NSImage alloc] initWithContentsOfFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-poster.jpg", show.Title]]] blurImageWithRadius:10.f] resizeImageWithSize:NSSizeFromCGSize(CGSizeMake(ntsv.frame.size.width, 93))];
//		}
//		else
//			ntsv.backgroundImageView.image = nil;
		return ntsv;
	}
	if ([tableColumn.title isEqualToString:@"Detail"]) {
		DetailTableCellView *dtsv = [self.tableView makeViewWithIdentifier:@"detailTableCell" owner:self];
		if (optionKeyPressed)
			dtsv.detailField.stringValue = [NSString stringWithFormat:@"%li Episode%@\t\tavg. (%.2f MB)", show.Episodes, (show.Episodes>1)?@"s":@"", show.SizePEpisode];
		else
			dtsv.textField.stringValue = show.Detail;
		dtsv.currentlyFollowing.hidden = YES;
		dtsv.toBeDownloaded.hidden = YES;
		dtsv.toBeDownloaded.image = [NSImage imageNamed:@"TO_BE_DOWNLOADED"];
		dtsv.toBeEncoded.hidden = YES;
		if (show.TO_BE_ENCODED) {
			if (show.TO_BE_DOWNLOADED) {
				dtsv.toBeDownloaded.hidden = NO;
				dtsv.toBeEncoded.hidden = NO;
			}
			else {
				dtsv.toBeDownloaded.image = [NSImage imageNamed:@"TO_BE_ENCODED"];
				dtsv.toBeDownloaded.hidden = NO;
			}
		}
		if (show.TO_BE_DOWNLOADED)
			dtsv.toBeDownloaded.hidden = NO;
		if (show.CURRENTLY_FOLLOWING)
			dtsv.currentlyFollowing.hidden = NO;
		if (row == tableView.selectedRow) {
			
		}
		return dtsv;
	}
	NSView *view = [NSView new];
	return view;
}

#pragma mark - Add and Edit

-(void)didFinishAddingShowWithName:(NSString *)name andDetail:(NSString *)detail {
	if (([TVShow numberOfEpisodesInString:detail] >= 1) && ([TVShow sizeOfShowFromString:detail] > 0.05f)) {
		NSString *filepath = [self documentsPathForFileName:[NSString stringWithFormat:@"TVShows.dat"]];
		if (![NSData dataWithContentsOfFile:filepath])
			FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"FullList" ofType:@"json"]] options:kNilOptions error:nil];
		else
			FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filepath] options:kNilOptions error:nil];
		
		NSMutableDictionary *Show = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%@", name], @"Title", [NSString stringWithFormat:@"%@", detail], @"Detail",	nil];
		BOOL alreadyPersent = NO;
		
		NSMutableArray *NewFullList = [[NSMutableArray alloc] init];
		for (int i = 0; i<[FullList count]; ++i) {
			NSMutableDictionary *show = [[NSMutableDictionary alloc] init];
			show = [FullList objectAtIndex:i];
			if ([[Show objectForKey:@"Title"] isEqualToString:[show objectForKey:@"Title"]])
				alreadyPersent = YES;
			[NewFullList addObject:show];
		}
		if (!alreadyPersent)
			[NewFullList addObject:Show];
		else {
			NSAlert *alert = [NSAlert alertWithError:[NSError errorWithDomain:@"Already Preseny" code:1 userInfo:nil]];
			[alert setAlertStyle:1];
			[alert runModal];
		}
		FullList = NewFullList;
		NSData *data = [NSJSONSerialization dataWithJSONObject:FullList options:kNilOptions error:nil];
		[data writeToFile:filepath atomically:YES];
		ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
		
		[self.tableView reloadData];
		[self updateSortAndInformationLabels];
	}
}

-(void)didFinishEditingShowWithTitle:(NSString *)title AndShow:(TVShow *)show {
	NSString *filepath = [self documentsPathForFileName:[NSString stringWithFormat:@"TVShows.dat"]];
	if (![NSData dataWithContentsOfFile:filepath])
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"FullList" ofType:@"json"]] options:kNilOptions error:nil];
	else
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filepath] options:kNilOptions error:nil];
	
	NSMutableArray *NewFullList = [[NSMutableArray alloc] init];
	for (int i = 0; i<[FullList count]; ++i) {
		NSMutableDictionary *Show = [[NSMutableDictionary alloc] init];
		if ([[[FullList objectAtIndex:i] objectForKey:@"Title"] isEqualToString:title]) {
			if (show.imagePosterURL && show.imageBannerURL && show.imageFanartURL)
				Show = [NSMutableDictionary dictionaryWithDictionary:@{@"Title": show.Title, @"Detail": show.Detail, @"Day": show.Day,
																   @"imagePoster": show.imagePosterURL,
																   @"imageBanner": show.imageBannerURL,
																   @"imageFanart": show.imageFanartURL}];
			else
				Show = [NSMutableDictionary dictionaryWithDictionary:@{@"Title": show.Title, @"Detail": show.Detail, @"Day": show.Day}];
		}
		else
			Show = [FullList objectAtIndex:i];
		[NewFullList addObject:Show];
	}
	FullList = NewFullList;
	
	NSData *data = [NSJSONSerialization dataWithJSONObject:FullList options:kNilOptions error:nil];
	[data writeToFile:filepath atomically:YES];
	
	ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
	[self sortListWithSortOrder:sortOrder];
	
	[self.tableView reloadData];
	[self updateSortAndInformationLabels];
}

#pragma mark - Drag and drop

-(id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
	if (!allowDragDrop)
		return nil;
	
	TVShow *show = [ShowList objectAtIndex:row];
	
	NSPasteboardItem *pasteBoardItem = [[NSPasteboardItem alloc] init];
	[pasteBoardItem setString:show.Title forType:@"public.text"];
	
	return pasteBoardItem;
}

-(NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
	if (allowDragDrop)
		return NSDragOperationMove;
	else
		return NSDragOperationNone;
}

-(BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
	NSPasteboard *pasteboard = [info draggingPasteboard];
	NSString *title = [pasteboard stringForType:@"public.text"];
	
	NSString *filepath = [self documentsPathForFileName:[NSString stringWithFormat:@"TVShows.dat"]];
	if (![NSData dataWithContentsOfFile:filepath])
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"FullList" ofType:@"json"]] options:kNilOptions error:nil];
	else
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filepath] options:kNilOptions error:nil];
	
	NSMutableArray *newFullList = [[NSMutableArray alloc] init];
	
	NSDictionary *showToMove = [[NSDictionary alloc] init];
	for (NSDictionary *show in FullList) {
		if ([[show valueForKey:@"Title"] isEqualToString:title])
			showToMove = show;
		else
			[newFullList addObject:show];
	}
	
	if (row >= [FullList count])
		row = [FullList count] - 1;
	
	[newFullList insertObject:showToMove atIndex:row];
	
	FullList = newFullList;
	NSData *data = [NSJSONSerialization dataWithJSONObject:FullList options:kNilOptions error:nil];
	[data writeToFile:filepath atomically:YES];
	ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
	
	[self.tableView reloadData];
	
	return YES;
}



#pragma mark - Navigation

-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"helpSegue"]) {
		HelpViewController *hvc = [segue destinationController];
		hvc.showsCount = [ShowList count];
		hvc.episodeCount = episodeCount;
		hvc.sizeCount = sizeCount;
	}
	if ([segue.identifier isEqualToString:@"addSegue"]) {
		AddViewController *avc = [segue destinationController];
		avc.delegate = self;
	}
	if ([segue.identifier isEqualToString:@"editorSegue"]) {
		TVShow *show = [ShowList objectAtIndex:[_tableView clickedRow]];
		EditorViewController *evc = [segue destinationController];
		evc.delegate = self;
		evc.show = show;
	}
	if ([segue.identifier isEqualToString:@"sortSegue"]) {
		SortViewController *svc = [segue destinationController];
		svc.delegate = self;
	}
	if ([segue.identifier isEqualToString:@"generatorSegue"]) {
		GeneratorViewController *gvc = [segue destinationController];
		gvc.delegate = self;
	}
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
//	if ([identifier isEqualToString:@"helpSegue"] && helpPresented)
//		return NO;
	return YES;
}

#pragma mark - Exportng list finished

-(void)didFinishExportingGeneratedShowList {
	NSString *filepath = [self documentsPathForFileName:[NSString stringWithFormat:@"TVShows.dat"]];
	if (![NSData dataWithContentsOfFile:filepath])
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"TVShows.dat" ofType:nil]] options:kNilOptions error:nil];
	else
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filepath] options:kNilOptions error:nil];
	
	ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
	allowDragDrop = NO;
	sortOrder = SortOrder_RANKING;
	[self.tableView reloadData];
	[self updateSortAndInformationLabels];
}

#pragma mark - Delete from data source

-(void)didConfirmDeleteShowNamed:(NSString *)name {
	NSString *filepath = [self documentsPathForFileName:[NSString stringWithFormat:@"TVShows.dat"]];
	if (![NSData dataWithContentsOfFile:filepath])
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"TVShows.dat" ofType:nil]] options:kNilOptions error:nil];
	else
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filepath] options:kNilOptions error:nil];
	
	NSMutableArray *newFullList = [[NSMutableArray alloc] init];
	for (NSDictionary *show in FullList) {
		if (![[show valueForKey:@"Title"] isEqualToString:name])
			[newFullList addObject:show];
	}
	FullList = newFullList;
	
	NSData *data = [NSJSONSerialization dataWithJSONObject:FullList options:kNilOptions error:nil];
	[data writeToFile:filepath atomically:YES];
	
	ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
	[self sortListWithSortOrder:sortOrder];
	
	[self.tableView reloadData];
	[self updateSortAndInformationLabels];
}

#pragma mark - Scheduling notifications

-(void)scheduleNotificationsForShows {
	NSArray *scheduledNotifications = [[NSUserNotificationCenter defaultUserNotificationCenter] scheduledNotifications];
	for (NSUserNotification *not in scheduledNotifications)
		[[NSUserNotificationCenter defaultUserNotificationCenter] removeScheduledNotification:not];
	
	NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
	for (TVShow *show in ShowList) {
		if ([show.Detail containsString:@"CURRENTLY_FOLLOWING"])
			[sortedArray addObject:show];
	}
	
	for (TVShow *show in sortedArray) {
			NSUserNotification *notification = [[NSUserNotification alloc] init];
			notification.title = [NSString stringWithFormat:@"\"%@\"", show.Title];
			notification.informativeText = [NSString stringWithFormat:@"New episode for %@", show.Title];
			
			NSDate *referenceDate = [NSDate date];
			NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
			NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:referenceDate];
			NSInteger targetWeekday = show.weekDay;
			if (dateComponents.weekday >= targetWeekday)
				dateComponents.weekOfMonth++;
			dateComponents.weekday = targetWeekday;
			dateComponents.hour = 9;
			dateComponents.minute = 30;
			dateComponents.second = arc4random_uniform(60);
			NSDate *followingTargetDay = [calendar dateFromComponents:dateComponents];
			notification.deliveryDate = followingTargetDay;
			[[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
	}
	
//	scheduledNotifications = [[NSUserNotificationCenter defaultUserNotificationCenter] scheduledNotifications];
//	for (NSUserNotification *not in scheduledNotifications)
//		NSLog(@"\n%@ - %@\n\n", not.title, not.deliveryDate);
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
	return YES;
}

#pragma mark - Other

-(void)updateSortAndInformationLabels {
	episodeCount = tEpisodeCount = 0;
	sizeCount = tSizeCount = 0.f;
	for (TVShow *show in ShowList) {
		episodeCount += show.Episodes;
		sizeCount += show.Size;
	}
	NSMutableArray *fullShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
	for (TVShow *show in fullShowList) {
		tEpisodeCount += show.Episodes;
		tSizeCount += show.Size;
	}
	_informationButton.title = [NSString stringWithFormat:@"%li Show%@ (%.2f GB)", ShowList.count, (ShowList.count > 1)?@"s":@"", sizeCount];
	_titleLabel.stringValue = [NSString stringWithFormat:@"TV Listing (%li Shows, %li Episodes, %.2f GB)", FullList.count, tEpisodeCount, tSizeCount];
	_sortOrderButton.title = [SortViewController titleForSortOrder:sortOrder];
	[self updateAppIcon];
	
	NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.avikantz.todaysshows"];
	[sharedDefaults setObject:FullList forKey:@"fulllist"];
	[sharedDefaults synchronize];
	
	[self scheduleNotificationsForShows];
	
}

- (NSString *)documentsPathForFileName:(NSString *)name {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [NSString stringWithFormat:@"%@/Listing (Mac)/", [paths lastObject]];
	return [documentsPath stringByAppendingPathComponent:name];
}

- (NSString *)imagesPathForFileName:(NSString *)name {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [NSString stringWithFormat:@"%@", [paths lastObject]];
	[manager createDirectoryAtPath:[NSString stringWithFormat:@"%@/Listing (Mac)/Images", [paths lastObject]] withIntermediateDirectories:YES attributes:nil error:nil];
	return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Listing (Mac)/Images/%@", name]];
}

@end
