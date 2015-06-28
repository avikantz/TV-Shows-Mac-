//
//  GeneratorViewController.m
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "GeneratorViewController.h"
#import "Item.h"

@interface GeneratorViewController ()

@end

@implementation GeneratorViewController {
	NSMutableArray *showList;
	
	NSMutableString *detailString;
	NSInteger seasonCount, episodeCount;
	CGFloat sizeCount;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	_exportButton.hidden = YES;
	_appendButton.hidden = YES;
	
	_savedToDesktopLabel.stringValue = @"Enter path of the root \"Shows\" directory.";
	
	_spinnerProgressIndicator.hidden = YES;
	
	if ([[NSUserDefaults standardUserDefaults] valueForKey:@"lastEditedPath"])
		_pathTextField.stringValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastEditedPath"];
	
}

- (IBAction)pathTextFieldDidReturn:(id)sender {
	
	[[NSUserDefaults standardUserDefaults] setObject:_pathTextField.stringValue forKey:@"lastEditedPath"];
	
	_spinnerProgressIndicator.hidden = NO;
	
	showList = [[NSMutableArray alloc] init];
	
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *contents = [manager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@", _pathTextField.stringValue] error:nil];
	
	// Root Path : Root Directory
	[contents enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
		if ([filename hasPrefix:@"."])
			return;
		Item *item = [[Item alloc] init];
		item.itemPath = [[NSString stringWithFormat:@"%@", _pathTextField.stringValue] stringByAppendingPathComponent:filename];
		
		NSMutableDictionary *show = [[NSMutableDictionary alloc] init];
		
		// Subfolder Level 1 : Show Folder
		if ([item.itemKind isEqualToString:@"Folder"]) {
			
			// Extracting Icons
		/*
			NSData *data = [item.itemIcon TIFFRepresentation];
			NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:data];
			NSNumber *compressionFactor = [NSNumber numberWithFloat:0.7];
			NSDictionary *imageProps = [NSDictionary dictionaryWithObject:compressionFactor forKey:NSImageCompressionFactor];
			data = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
			[data writeToFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@.png", item.itemDisplayName]] atomically:YES];
		*/
			
			[show setObject:[NSString stringWithFormat:@"%@",item.itemDisplayName] forKey:@"Title"];
			
			detailString = [NSMutableString stringWithString:@""];
			seasonCount = 0, episodeCount = 0;
			sizeCount = 0.f;
			
			NSMutableString *seasonDetailString = [NSMutableString stringWithString:@""];
			
			NSArray *subcontents = [manager contentsOfDirectoryAtPath:item.itemPath error:nil];
			[subcontents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([obj hasPrefix:@"."] || [obj containsString:@"Icon"])
					return;
				Item *subItem = [[Item alloc] init];
				subItem.itemPath = [item.itemPath stringByAppendingPathComponent:obj];
				
				// Subfolder Level 2 : Seasons Folder
				if ([subItem.itemKind isEqualToString:@"Folder"]) {
					
					seasonCount++;
					
					[seasonDetailString appendString:[NSString stringWithFormat:@"\n%@\n\n", subItem.itemDisplayName]];
					
					NSMutableArray *titleArray = [[NSMutableArray alloc] init];
					NSArray *seasonContents = [manager contentsOfDirectoryAtPath:subItem.itemPath error:nil];
					[seasonContents enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx, BOOL *stop) {
						if ([obj2 hasPrefix:@"."] || [obj2 containsString:@"Icon"])
							return;
						
						Item *subSubItem = [[Item alloc] init];
						subSubItem.itemPath = [subItem.itemPath stringByAppendingPathComponent:obj2];
						
						if (!([subSubItem.itemKind isEqualToString:@"Subtitle"] || [subSubItem.itemKind isEqualToString:@"Folder"])&& subSubItem.itemSize > 0.001) {
							sizeCount += subSubItem.itemSize;
							episodeCount++;
							
							[titleArray addObject:[NSString stringWithFormat:@"%@\n", [subSubItem.itemDisplayName stringByDeletingPathExtension]]];
							//							[seasonDetailString appendString:[NSString stringWithFormat:@"%@\n", [subSubItem.itemDisplayName stringByDeletingPathExtension]]];
						}
					}];
					titleArray = [NSMutableArray arrayWithArray:[titleArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
					for (int i = 0; i < [titleArray count]; ++i) {
						[seasonDetailString appendString:[NSString stringWithFormat:@"%@", [titleArray objectAtIndex:i]]];
					}
				}
				
				else if (!([subItem.itemKind isEqualToString:@"Subtitle"] || [subItem.itemKind isEqualToString:@"Folder"])) {
					[seasonDetailString appendString:[NSString stringWithFormat:@"%@\n", [subItem.itemDisplayName stringByDeletingPathExtension]]];
					sizeCount += subItem.itemSize;
					episodeCount++;
				}
				
			}];
			
			seasonDetailString = [NSMutableString stringWithString:[seasonDetailString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ - ", item.itemDisplayName] withString:@""]];
			
			if (seasonCount == 0 && episodeCount > 0)
				[detailString appendString:[NSString stringWithFormat:@"%li Episode%@ (%@)\n\n%@", episodeCount, (episodeCount == 1)?@"":@"s", [self getSizeStringFromSize:sizeCount], seasonDetailString]];
			else
				[detailString appendString:[NSString stringWithFormat:@"%li Season%@, %li Episode%@ (%@)\n\n%@", seasonCount, (seasonCount == 1)?@"":@"s", episodeCount, (episodeCount == 1)?@"":@"s", [self getSizeStringFromSize:sizeCount], seasonDetailString]];
			
			[show setObject:detailString forKey:@"Detail"];
			
			if (sizeCount > 0 && episodeCount  > 0)
				[showList addObject:show];
			
		}
		
	}];
	
	[showList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [[obj1 valueForKey:@"Title"] compare:[obj2 valueForKey:@"Title"] options:NSCaseInsensitiveSearch];
	}];
	
	if (showList.count > 0) {
		NSData *data = [NSJSONSerialization dataWithJSONObject:showList options:kNilOptions error:nil];
		[data writeToFile:[self desktopPathForFileName:@"TVShows.dat"] atomically:YES];
		_savedToDesktopLabel.stringValue = @"File saved to ~/Desktop/TVShows.dat";
		_exportButton.hidden = NO;
		_appendButton.hidden = NO;
	}
	else {
		_savedToDesktopLabel.stringValue = @"No shows/episodes found. Enter path again.";
	}
	
	_spinnerProgressIndicator.hidden = YES;
	
}

- (IBAction)openAction:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Choose the root TV shows directory...";
	openPanel.canChooseDirectories = YES;
	openPanel.canCreateDirectories = NO;
	openPanel.allowsMultipleSelection = NO;
	[openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
		if (result == NSModalResponseOK) {
			NSURL *selection = openPanel.URLs[0];
			NSString *filepath = [selection.path stringByResolvingSymlinksInPath];
			_pathTextField.stringValue = filepath;
			[self pathTextFieldDidReturn:self];
		}
	}];
}

- (NSString *)desktopPathForFileName:(NSString *)name {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [NSString stringWithFormat:@"%@", [paths lastObject]];
	return [documentsPath stringByAppendingPathComponent:name];
}

- (NSString *)imagesPathForFileName:(NSString *)name {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [NSString stringWithFormat:@"%@", [paths lastObject]];
	[manager createDirectoryAtPath:[NSString stringWithFormat:@"%@/Listing (Mac)/Images", [paths lastObject]] withIntermediateDirectories:YES attributes:nil error:nil];
	return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Listing (Mac)/Images/%@", name]];
}

- (IBAction)exportAction:(id)sender {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:[NSString stringWithFormat:@"Append?"]];
	[alert setInformativeText:@"This will replace the existing data source with the generated data. Are you sure you want to continue?"];
	[alert addButtonWithTitle:@"Nope"];
	[alert addButtonWithTitle:@"Yeah"];
	[alert setDelegate:self];
	
	if ([alert runModal] == NSAlertSecondButtonReturn) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString *filepath = [[NSString stringWithFormat:@"%@/Listing (Mac)/", [paths lastObject]] stringByAppendingPathComponent:@"TVShows.dat"];
		NSData *data = [NSJSONSerialization dataWithJSONObject:showList options:kNilOptions error:nil];
		[data writeToFile:filepath atomically:YES];
		
		[self.delegate didFinishExportingGeneratedShowList];
		[self dismissController:self];
	}
}

- (IBAction)appendAction:(id)sender {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:[NSString stringWithFormat:@"Append?"]];
	[alert setInformativeText:@"This will append the generated data to the existing data source. Are you sure you want to continue?"];
	[alert addButtonWithTitle:@"Nope"];
	[alert addButtonWithTitle:@"Yeah"];
	[alert setDelegate:self];
	
	if ([alert runModal] == NSAlertSecondButtonReturn) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString *filepath = [[NSString stringWithFormat:@"%@/Listing (Mac)/", [paths lastObject]] stringByAppendingPathComponent:@"TVShows.dat"];
		NSMutableArray *existingArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filepath] options:kNilOptions error:nil];
		NSMutableArray *newArray = [NSMutableArray arrayWithArray:existingArray];
		[newArray addObjectsFromArray:showList];
		
		NSData *newData = [NSJSONSerialization dataWithJSONObject:newArray options:kNilOptions error:nil];
		[newData writeToFile:filepath atomically:YES];
		
		[self.delegate didFinishExportingGeneratedShowList];
		[self dismissController:self];
	}
}

-(NSString *)getSizeStringFromSize:(CGFloat)size {
	NSString *sizeString = @"";
	if (size < 1)
		sizeString = [NSString stringWithFormat:@"%.1f MB", size*1000];
	else
		sizeString = [NSString stringWithFormat:@"%.2f GB", size];
	return sizeString;
}

@end
