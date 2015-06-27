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
						
						if (!([subSubItem.itemKind isEqualToString:@"Subtitle"] || [subSubItem.itemKind isEqualToString:@"Folder"])&& subSubItem.itemSize > 0.005) {
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
				[detailString appendString:[NSString stringWithFormat:@"%li Episodes (%@)\n\n%@", episodeCount, [self getSizeStringFromSize:sizeCount], seasonDetailString]];
			else
				[detailString appendString:[NSString stringWithFormat:@"%li Seasons, %li Episodes (%@)\n\n%@", seasonCount, episodeCount, [self getSizeStringFromSize:sizeCount], seasonDetailString]];
			
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
	}
	else {
		_savedToDesktopLabel.stringValue = @"Some error occured. Enter path again.";
	}
	
	_exportButton.hidden = NO;
	
	_spinnerProgressIndicator.hidden = YES;
	
}

- (NSString *)desktopPathForFileName:(NSString *)name {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [NSString stringWithFormat:@"%@", [paths lastObject]];
	return [documentsPath stringByAppendingPathComponent:name];
}

- (IBAction)exportAction:(id)sender {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *filepath = [[NSString stringWithFormat:@"%@/Listing (Mac)/", [paths lastObject]] stringByAppendingPathComponent:@"TVShows.dat"];
	NSData *data = [NSJSONSerialization dataWithJSONObject:showList options:kNilOptions error:nil];
	[data writeToFile:filepath atomically:YES];
	
	[self.delegate didFinishExportingGeneratedShowList];
	
	[self dismissController:self];
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
