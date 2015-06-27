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

@implementation ViewController {
	NSMutableArray *FullList;
	NSMutableArray *ShowList;
	
	BOOL allowDragDrop;
	SortOrder sortOrder;
	
	NSInteger episodeCount;
	CGFloat sizeCount;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view.
	
	_tableView.dataSource = self;
	_tableView.delegate = self;
	
	[self.tableView registerForDraggedTypes: [NSArray arrayWithObject: @"public.text"]];
	
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

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}


#pragma mark - Sorting actions

- (IBAction)rearrangeAction:(id)sender {
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
	return 27.f;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [ShowList count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	TVShow *show = [ShowList objectAtIndex:row];
	if ([tableColumn.title isEqualToString:@"Name"]) {
		NameTableCellView *ntsv = [self.tableView makeViewWithIdentifier:@"nameTableCell" owner:self];
		ntsv.nameTextField.stringValue = [NSString stringWithFormat:@"%@", show.Title];
		ntsv.rankTextField.stringValue = [NSString stringWithFormat:@"%4ld.", (long)row+1];
		ntsv.dayTextField.stringValue = @"";
		if (show.CURRENTLY_FOLLOWING)
			ntsv.dayTextField.stringValue = show.Day;
		return ntsv;
	}
	if ([tableColumn.title isEqualToString:@"Detail"]) {
		DetailTableCellView *dtsv = [self.tableView makeViewWithIdentifier:@"detailTableCell" owner:self];
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

-(void)didFinishEditingShowWithTitle:(NSString *)title AndDetail:(NSString *)detail AndDay:(NSString *)day {
	NSString *filepath = [self documentsPathForFileName:[NSString stringWithFormat:@"TVShows.dat"]];
	if (![NSData dataWithContentsOfFile:filepath])
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"FullList" ofType:@"json"]] options:kNilOptions error:nil];
	else
		FullList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filepath] options:kNilOptions error:nil];
	
	NSMutableArray *NewFullList = [[NSMutableArray alloc] init];
	for (int i = 0; i<[FullList count]; ++i) {
		NSMutableDictionary *Show = [[NSMutableDictionary alloc] init];
		if ([[[FullList objectAtIndex:i] objectForKey:@"Title"] isEqualToString:title])
			Show = [NSMutableDictionary dictionaryWithDictionary:@{@"Title": title, @"Detail": detail, @"Day": day}];
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

#pragma mark - Other methods

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

-(void)updateSortAndInformationLabels {
	episodeCount = 0;
	sizeCount = 0.f;
	for (TVShow *show in ShowList) {
		episodeCount += show.Episodes;
		sizeCount += show.Size;
	}
	_informationButton.title = [NSString stringWithFormat:@"%li Shows, %li Episodes (%.2f GB)", ShowList.count, episodeCount, sizeCount];
}

- (NSString *)documentsPathForFileName:(NSString *)name {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [NSString stringWithFormat:@"%@/Listing (Mac)/", [paths lastObject]];
	return [documentsPath stringByAppendingPathComponent:name];
}

@end
