//
//  TodayViewController.m
//  TV Shows Info
//
//  Created by Avikant Saini on 7/22/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "TodayViewController.h"
#import "TVShow.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
	NSMutableArray *FullList;
	NSMutableArray *ShowList;
	NSMutableArray *TodaysShows;
	
	NSInteger episodeCount;
	CGFloat sizeCount;
}

-(void)viewDidLoad {
	NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.avikantz.todaysshows"];
	FullList = [sharedDefaults objectForKey:@"fulllist"];
	
	ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
	
	sizeCount = 0;
	episodeCount = 0;
	for (TVShow *show in ShowList) {
		episodeCount += show.Episodes;
		sizeCount += show.Size;
	}
	
	_showsCountLabel.integerValue = ShowList.count;
	_episodesCountLabel.stringValue = [NSString stringWithFormat:@"%li Episodes", episodeCount];
	_sizeCountLabel.stringValue = [NSString stringWithFormat:@"%0.2f GB", sizeCount];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    completionHandler(NCUpdateResultNoData);
	
	[self viewDidLoad];
}

-(NSEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(NSEdgeInsets)defaultMarginInset {
	return NSEdgeInsetsZero;
}

@end

