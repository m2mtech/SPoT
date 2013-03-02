//
//  RecentFlickrPhotos.m
//  SPoT
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "RecentFlickrPhotos.h"
#import "FlickrFetcher.h"

@implementation RecentFlickrPhotos

#define RECENT_FLICKR_PHOTOS_KEY @"RecentWatchedPhotos_Key"
#define RECENT_FLICKR_PHOTOS_NUMBER 20

+ (NSArray *)allPhotos
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:RECENT_FLICKR_PHOTOS_KEY];
}

+ (void)addPhoto:(NSDictionary *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recents = [[defaults objectForKey:RECENT_FLICKR_PHOTOS_KEY] mutableCopy];

    if (!recents) recents = [NSMutableArray array];
    NSUInteger key = [recents indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [photo[FLICKR_PHOTO_ID]
                isEqualToString:obj[FLICKR_PHOTO_ID]];
    }];
    if (key != NSNotFound) [recents removeObjectAtIndex:key];
    [recents insertObject:photo atIndex:0];
    while ([recents count] > RECENT_FLICKR_PHOTOS_NUMBER) {
        [recents removeLastObject];
    }
    
    [defaults setObject:recents forKey:RECENT_FLICKR_PHOTOS_KEY];
    [defaults synchronize];    
}

@end
