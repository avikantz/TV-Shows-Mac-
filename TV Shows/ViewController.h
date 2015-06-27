//
//  ViewController.h
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TVShow.h"
#import "AppDelegate.h"
#import "AddViewController.h"
#import "EditorViewController.h"
#import "SortViewController.h"
#import "GeneratorViewController.h"

typedef NS_ENUM(NSInteger, SortOrder) {
	SortOrder_RANKING = 1,
	SortOrder_ALPHABETICAL = 2,
	SortOrder_CURRENTLY_FOLLOWING = 3,
	SortOrder_TO_BE_DOWNLOADED = 4,
	SortOrder_TO_BE_ENCODED = 5,
	SortOrder_EPISODE_COUNT_ASC = 6,
	SortOrder_EPISODE_COUNT_DES = 7,
	SortOrder_SIZE_ASC = 8,
	SortOrder_SIZE_DES = 9,
};

@interface ViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, AddShowDelegate, ShowEditorDelegate, SortingDelegate, GeneratorDelegate>

@property (weak) IBOutlet AppDelegate *appDelegate;

@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSButton *sortOrderButton;

@property (weak) IBOutlet NSButton *informationButton;

@property (weak) IBOutlet NSButton *rearrangeButton;

- (IBAction)rearrangeAction:(id)sender;

- (IBAction)sortAction:(id)sender;

@end

