//
//  SortViewController.m
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "SortViewController.h"

@interface SortViewController ()

@end

@implementation SortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)sortAction:(id)sender {
	[self.delegate didFinishSelectingSortOrder:[sender tag] AndSortTitle:[sender title]];
	[[NSUserDefaults standardUserDefaults] setInteger:[sender tag] forKey:@"SortOrder"];
}

@end
