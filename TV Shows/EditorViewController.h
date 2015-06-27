//
//  EditorViewController.h
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TVShow.h"

@class EditorViewController;

@protocol ShowEditorDelegate <NSObject>

-(void)didFinishEditingShowWithTitle:(NSString *)title AndDetail:(NSString *)detail AndDay:(NSString *)day;
-(void)didConfirmDeleteShowNamed:(NSString *)name;

@end

@interface EditorViewController : NSViewController <NSAlertDelegate>

@property (nonatomic, strong) TVShow *show;

@property (nonatomic, weak) id <ShowEditorDelegate> delegate;

@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSTextField *titleLabel;

@property (assign) IBOutlet NSButton *doneButton;

@property (assign) IBOutlet NSComboBox *dayPickerComboBox;

- (IBAction)doneAction:(id)sender;

- (IBAction)deleteAction:(id)sender;


@end
