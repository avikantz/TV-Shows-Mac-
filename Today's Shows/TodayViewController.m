//
//  TodayViewController.m
//  Today's Shows
//
//  Created by Avikant Saini on 7/13/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "TodayViewController.h"
#import "ListRowViewController.h"
#import "TVShow.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding, NCWidgetListViewDelegate, NCWidgetSearchViewDelegate>

@property (strong) IBOutlet NCWidgetListViewController *listViewController;
@property (strong) NCWidgetSearchViewController *searchController;

@end


@implementation TodayViewController {
	NSMutableArray *FullList;
	NSMutableArray *ShowList;
	NSMutableArray *TodaysShows;
}

#pragma mark - NSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up the widget list view controller.
    // The contents property should contain an object for each row in the list.
	
	NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.avikantz.todaysshows"];
	FullList = [sharedDefaults objectForKey:@"fulllist"];
	
	ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
	
	NSDate *referenceDate = [NSDate date];
	NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
	
	NSInteger weekDay = [calendar component:NSCalendarUnitWeekday fromDate:referenceDate];
	
	TodaysShows = [[NSMutableArray alloc] init];
	
	for (TVShow *show in ShowList) {
		if (weekDay == show.weekDay) {
			[TodaysShows addObject:[NSString stringWithFormat:@"%@", show.Title]];
		}
	}
	
	NSLog(@"\nToday: %@", TodaysShows);
	
	if (TodaysShows.count > 0)
		self.listViewController.contents = TodaysShows;
	else
		self.listViewController.contents = @[@"No shows today. :("];
	
}

- (void)dismissViewController:(NSViewController *)viewController {
    [super dismissViewController:viewController];

    // The search controller has been dismissed and is no longer needed.
    if (viewController == self.searchController) {
        self.searchController = nil;
    }
}

#pragma mark - NCWidgetProviding

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Refresh the widget's contents in preparation for a snapshot.
    // Call the completion handler block after the widget's contents have been
    // refreshed. Pass NCUpdateResultNoData to indicate that nothing has changed
    // or NCUpdateResultNewData to indicate that there is new data since the
    // last invocation of this method.
	
	NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.avikantz.todaysshows"];
	FullList = [sharedDefaults objectForKey:@"fulllist"];
	
	ShowList = [TVShow returnShowArrayFromJsonStructure:FullList];
	
	NSDate *referenceDate = [NSDate date];
	NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
	
	NSInteger weekDay = [calendar component:NSCalendarUnitWeekday fromDate:referenceDate];
	
	TodaysShows = [[NSMutableArray alloc] init];
	
	for (TVShow *show in ShowList) {
		if (weekDay == show.weekDay) {
			[TodaysShows addObject:[NSString stringWithFormat:@"%@ (%@)", show.Title, show.NextEpisode]];
		}
	}
	
	NSLog(@"\nToday: %@", TodaysShows);
	
	if (TodaysShows.count > 0)
		self.listViewController.contents = TodaysShows;
	else
		self.listViewController.contents = @[@"No shows today. :("];
	
    completionHandler(NCUpdateResultNoData);
}

- (NSEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(NSEdgeInsets)defaultMarginInset {
    // Override the left margin so that the list view is flush with the edge.
    return NSEdgeInsetsMake(6, 0, 6, 0);
}

-(void)viewDidAppear {
	
}

- (BOOL)widgetAllowsEditing {
    // Return YES to indicate that the widget supports editing of content and
    // that the list view should be allowed to enter an edit mode.
    return NO;
}

- (void)widgetDidBeginEditing {
    // The user has clicked the edit button.
    // Put the list view into editing mode.
    self.listViewController.editing = YES;
}

- (void)widgetDidEndEditing {
    // The user has clicked the Done button, begun editing another widget,
    // or the Notification Center has been closed.
    // Take the list view out of editing mode.
    self.listViewController.editing = NO;
}

#pragma mark - NCWidgetListViewDelegate

- (NSViewController *)widgetList:(NCWidgetListViewController *)list viewControllerForRow:(NSUInteger)row {
    // Return a new view controller subclass for displaying an item of widget
    // content. The NCWidgetListViewController will set the representedObject
    // of this view controller to one of the objects in its contents array.
    return [[ListRowViewController alloc] init];
}

- (void)widgetListPerformAddAction:(NCWidgetListViewController *)list {
    // The user has clicked the add button in the list view.
    // Display a search controller for adding new content to the widget.
    self.searchController = [[NCWidgetSearchViewController alloc] init];
    self.searchController.delegate = self;

    // Present the search view controller with an animation.
    // Implement dismissViewController to observe when the view controller
    // has been dismissed and is no longer needed.
    [self presentViewControllerInWidget:self.searchController];
}

- (BOOL)widgetList:(NCWidgetListViewController *)list shouldReorderRow:(NSUInteger)row {
    // Return YES to allow the item to be reordered in the list by the user.
    return YES;
}

- (void)widgetList:(NCWidgetListViewController *)list didReorderRow:(NSUInteger)row toRow:(NSUInteger)newIndex {
    // The user has reordered an item in the list.
}

- (BOOL)widgetList:(NCWidgetListViewController *)list shouldRemoveRow:(NSUInteger)row {
    // Return YES to allow the item to be removed from the list by the user.
    return YES;
}

- (void)widgetList:(NCWidgetListViewController *)list didRemoveRow:(NSUInteger)row {
    // The user has removed an item from the list.
}

#pragma mark - NCWidgetSearchViewDelegate

- (void)widgetSearch:(NCWidgetSearchViewController *)searchController searchForTerm:(NSString *)searchTerm maxResults:(NSUInteger)max {
    // The user has entered a search term. Set the controller's searchResults property to the matching items.
    searchController.searchResults = @[];
}

- (void)widgetSearchTermCleared:(NCWidgetSearchViewController *)searchController {
    // The user has cleared the search field. Remove the search results.
    searchController.searchResults = nil;
}

- (void)widgetSearch:(NCWidgetSearchViewController *)searchController resultSelected:(id)object {
    // The user has selected a search result from the list.
}

- (NSString *)documentsPathForFileName:(NSString *)name {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [[NSString stringWithFormat:@"%@/Listing (Mac)/", [paths lastObject]] stringByReplacingOccurrencesOfString:@"Containers/com.avikantz.TV-Shows.Today-s-Shows/Data/Library/" withString:@""];
	return [documentsPath stringByAppendingPathComponent:name];
}

@end
