//
//  SortViewController.h
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SortViewController;

@protocol SortingDelegate <NSObject>

-(void)didFinishSelectingSortOrder:(NSInteger)sorder AndSortTitle:(NSString *)sortTitle;

@end

@interface SortViewController : NSViewController

@property (nonatomic, weak) id <SortingDelegate> delegate;

- (IBAction)sortAction:(id)sender;

@end
