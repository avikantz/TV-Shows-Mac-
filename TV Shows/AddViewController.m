//
//  AddViewController.m
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "AddViewController.h"

@interface AddViewController ()

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
	
	_nameField.placeholderString = @"Name";
	_nameField.stringValue = @"";
	_detailTextView.string = @"";
}

- (IBAction)doneAction:(id)sender {
	if (![_nameField.stringValue isEqualToString:@""] && ![_detailTextView.string isEqualToString:@""]) {
		[self.delegate didFinishAddingShowWithName:_nameField.stringValue andDetail:[self stringByRemovingName:_nameField.stringValue FromString:_detailTextView.string]];
		[self dismissController:self];
	}
}

- (NSString *)stringByRemovingName:(NSString *)name FromString:(NSString *)string {
	NSString *newString = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ - ", name] withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".mkv" withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".avi" withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".srt" withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
	return newString;
}

@end
