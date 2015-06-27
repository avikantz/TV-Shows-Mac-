//
//  TVShow.m
//  Listing
//
//  Created by Avikant Saini on 6/14/15.
//  Copyright (c) 2015 n/a. All rights reserved.
//

#import "TVShow.h"

@implementation TVShow

+(id)returnShowArrayFromJsonStructure:(id)FullList {
	NSMutableArray *ShowList = [NSMutableArray new];
	for(int i=0; i<[FullList count]; ++i){
		TVShow *show = [TVShow new];
		show.Title = [NSString stringWithFormat:@"%@", [[FullList objectAtIndex:i] objectForKey:@"Title"]];
		show.Detail = [NSString stringWithFormat:@"%@",[[FullList objectAtIndex:i] objectForKey:@"Detail"]];
		show.Day = [NSString stringWithFormat:@"%@",[[FullList objectAtIndex:i] objectForKey:@"Day"]];
		show.Episodes = [self numberOfEpisodesInString:show.Detail];
		show.Size = [self sizeOfShowFromString:show.Detail];
		show.CURRENTLY_FOLLOWING = [show.Detail containsString:@"CURRENTLY_FOLLOWING"];
		show.TO_BE_DOWNLOADED = [show.Detail containsString:@"TO_BE_DOWNLOADED"];
		show.TO_BE_ENCODED = [show.Detail containsString:@"TO_BE_ENCODED"];
		if ([show.Day isEqualToString:@"SUN"]) show.weekDay = 1;
		if ([show.Day isEqualToString:@"MON"]) show.weekDay = 2;
		if ([show.Day isEqualToString:@"TUE"]) show.weekDay = 3;
		if ([show.Day isEqualToString:@"WED"]) show.weekDay = 4;
		if ([show.Day isEqualToString:@"THU"]) show.weekDay = 5;
		if ([show.Day isEqualToString:@"FRI"]) show.weekDay = 6;
		if ([show.Day isEqualToString:@"SAT"]) show.weekDay = 7;
		[ShowList addObject:show];
	}
	return ShowList;
}

+(NSInteger)numberOfEpisodesInString:(NSString *)string {
	NSInteger nooe = 0, to = 0;
	for (int i = 0; i < 40; ++i) {
		if ([string characterAtIndex:i] == 'E' && [string characterAtIndex:i+1] == 'p' && [string characterAtIndex:i+2] == 'i')
			to = i-1;
	}
	NSString *nooeString = [[string substringFromIndex:MAX(0, to-4)] substringToIndex:4];
	nooeString = [nooeString stringByReplacingOccurrencesOfString:@", " withString:@""];
	nooeString = [nooeString stringByReplacingOccurrencesOfString:@"n" withString:@""];
	nooeString = [nooeString stringByReplacingOccurrencesOfString:@"s" withString:@""];
	nooeString = [nooeString stringByReplacingOccurrencesOfString:@"e" withString:@""];
	nooe = [nooeString integerValue];
	return nooe;
}

+(CGFloat)sizeOfShowFromString:(NSString *)string {
	CGFloat sizeInGB = 0.f;
	NSInteger to = 0, from = 0;
	NSString *sizeString;
	for (int i = 0; i < 40; ++i) {
		if ([string characterAtIndex:i] == '(')
			from = i;
		if ([string characterAtIndex:i] == ')') {
			to = i;
			break;
		}
	}
	sizeString = [[string substringFromIndex:from+1] substringToIndex:to - from];
	if ([sizeString containsString:@"MB"])
		sizeInGB = [sizeString floatValue]/1000;
	else
		sizeInGB = [sizeString floatValue];
	return sizeInGB;
}

@end