//
//  GeneratorViewController.h
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GeneratorViewController;

@protocol GeneratorDelegate <NSObject>

-(void)didFinishExportingGeneratedShowList;

@end

@interface GeneratorViewController : NSViewController <NSApplicationDelegate>

@property (nonatomic, weak) id <GeneratorDelegate> delegate;

@property (weak) IBOutlet NSTextField *pathTextField;
- (IBAction)pathTextFieldDidReturn:(id)sender;

@property (weak) IBOutlet NSTextField *savedToDesktopLabel;

@property (weak) IBOutlet NSButton *exportButton;
- (IBAction)exportAction:(id)sender;

@property (weak) IBOutlet NSProgressIndicator *spinnerProgressIndicator;

@end
