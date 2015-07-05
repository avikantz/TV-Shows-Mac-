//
//  NameTableCellView.h
//  Listing
//
//  Created by Avikant Saini on 6/14/15.
//  Copyright (c) 2015 n/a. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NameTableCellView : NSTableCellView

@property (strong, nonatomic) IBOutlet NSTextField *nameTextField;

@property (strong, nonatomic) IBOutlet NSTextField *rankTextField;

@property (strong, nonatomic) IBOutlet NSTextField *dayTextField;

@property (weak) IBOutlet NSImageView *backgroundImageView;


@end
