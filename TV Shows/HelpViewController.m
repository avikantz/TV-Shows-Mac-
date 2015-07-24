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
	
	if (_episodeCount == 0)
		_episodeCountLabel.hidden = YES;
	if (_showsCount == 0)
		_showsCountLabel.hidden = YES;
	if (_sizeCount < 1)
		_sizeCountLabel.hidden = YES;
	
	_episodeCountLabel.stringValue = [NSString stringWithFormat:@"%li", _episodeCount];
	_showsCountLabel.stringValue = [NSString stringWithFormat:@"%li", _showsCount];
	_sizeCountLabel.stringValue = [NSString stringWithFormat:@"%.2f", _sizeCount];
}

@end
