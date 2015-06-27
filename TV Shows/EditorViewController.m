//
//  EditorViewController.m
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "EditorViewController.h"

@interface EditorViewController ()

@end

@implementation EditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
	
	self.titleLabel.stringValue = self.show.Title;
	self.textView.string = self.show.Detail;
	if (self.show.CURRENTLY_FOLLOWING) {
		self.dayPickerComboBox.stringValue = self.show.Day;
		self.dayPickerComboBox.hidden = NO;
	}
	else
		self.dayPickerComboBox.hidden = YES;
	
}

-(void)viewDidDisappear {
//	[self doneAction:self];
}

- (IBAction)doneAction:(id)sender {
	[self.delegate didFinishEditingShowWithTitle:self.show.Title AndDetail:[self stringByRemovingName:self.show.Title FromString:self.textView.string] AndDay:self.dayPickerComboBox.stringValue];
	[self dismissController:self];
}

- (IBAction)deleteAction:(id)sender {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:[NSString stringWithFormat:@"Delete \"%@\"?", self.show.Title]];
	[alert setInformativeText:@"This will remove the show from the data-source. This action is irreversible. Are you bloody sure you want to continue?"];
	[alert addButtonWithTitle:@"Nope"];
	[alert addButtonWithTitle:@"Yeah"];
	[alert setDelegate:self];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	if ([alert runModal] == NSAlertSecondButtonReturn) {
		NSLog(@"Deleting...");
		[self.delegate didConfirmDeleteShowNamed:self.show.Title];
		[self dismissController:self];
	}
}



- (NSString *)stringByRemovingName:(NSString *)name FromString:(NSString *)string {
	NSString *newString = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ - ", name] withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".mkv" withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".cbr" withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".avi" withString:@""];
	return newString;
}

@end
