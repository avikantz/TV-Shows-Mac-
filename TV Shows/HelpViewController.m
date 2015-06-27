//
//  HelpViewController.m
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
	
	_episodeCountLabel.stringValue = [NSString stringWithFormat:@"%li", _episodeCount];
	_showsCountLabel.stringValue = [NSString stringWithFormat:@"%li", _showsCount];
	_sizeCountLabel.stringValue = [NSString stringWithFormat:@"%.2f", _sizeCount];
}

@end
