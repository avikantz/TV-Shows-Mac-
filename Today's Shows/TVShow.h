//
//  TVShow.h
//  Listing
//
//  Created by Avikant Saini on 6/14/15.
//  Copyright (c) 2015 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVShow : NSObject

@property (strong, nonatomic) NSString *Title;
@property (strong, nonatomic) NSString *Detail;
@property (strong, nonatomic) NSString *Day;

@property (strong, nonatomic) NSString *imagePosterURL;
@property (strong, nonatomic) NSString *imageFanartURL;
@property (strong, nonatomic) NSString *imageBannerURL;

@property NSInteger weekDay;

@property BOOL CURRENTLY_FOLLOWING;
@property BOOL TO_BE_DOWNLOADED;
@property BOOL TO_BE_ENCODED;

@property NSString *NextEpisode;

@property NSInteger Episodes;
@property CGFloat Size;
@property CGFloat SizePEpisode;

+(id)returnShowArrayFromJsonStructure:(id)FullList;
+(NSInteger)numberOfEpisodesInString:(NSString *)string;
+(CGFloat)sizeOfShowFromString:(NSString *)string;

@end
