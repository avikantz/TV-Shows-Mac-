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

+(NSString *)titleForSortOrder:(NSInteger)sorder {
	NSString *sortString = @"";
	switch (sorder) {
		case 1: sortString = @"Rank Wise";
			break;
		case 2: sortString = @"Alphabetical";
			break;
		case 3: sortString = @"Currently Following";
			break;
		case 4: sortString = @"To Be Downloaded";
			break;
		case 5: sortString = @"To Be Encoded";
			break;
		case 6: sortString = @"Episodes (Ascending)";
			break;
		case 7: sortString = @"Episodes (Descending)";
			break;
		case 8: sortString = @"Size (Ascending)";
			break;
		case 9: sortString = @"Size (Descending)";
			break;
		default: sortString = @"Rank Wise";
			break;
	}
	return sortString;
}

@end
