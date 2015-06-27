//
//  DetailTableCellView.h
//  Listing
//
//  Created by Avikant Saini on 6/14/15.
//  Copyright (c) 2015 n/a. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DetailTableCellView : NSTableCellView

@property (strong, nonatomic) IBOutlet NSTextField *detailField;

@property (strong, nonatomic) IBOutlet NSImageView *currentlyFollowing;
@property (strong, nonatomic) IBOutlet NSImageView *toBeDownloaded;
@property (strong, nonatomic) IBOutlet NSImageView *toBeEncoded;

@end
