//
//  HelpViewController.h
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HelpViewController : NSViewController

@property NSInteger episodeCount;
@property NSInteger showsCount;
@property CGFloat sizeCount;

@property (weak) IBOutlet NSTextField *sizeCountLabel;
@property (weak) IBOutlet NSTextField *showsCountLabel;
@property (weak) IBOutlet NSTextField *episodeCountLabel;

@end
