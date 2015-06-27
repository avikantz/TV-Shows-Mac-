//
//  AddViewController.h
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AddViewController;

@protocol AddShowDelegate <NSObject>

-(void)didFinishAddingShowWithName:(NSString *)name andDetail:(NSString *)detail;

@end

@interface AddViewController : NSViewController

@property (nonatomic, weak) id <AddShowDelegate> delegate;

@property (weak) IBOutlet NSTextField *nameField;

@property (unsafe_unretained) IBOutlet NSTextView *detailTextView;

- (IBAction)doneAction:(id)sender;

@end
