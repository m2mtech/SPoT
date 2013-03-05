//
//  FlickrCache.h
//  SPoT
//
//  Created by Martin Mandl on 04.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FLICKRCACHE_MAXSIZE_IPHONE 1024*1024*3
#define FLICKRCACHE_MAXSIZE_IPAD 1024*1024*10
#define FLICKRCACHE_FOLDER @"flickrPhotos"

@interface FlickrCache : NSObject

+ (NSURL *)cachedURLforURL:(NSURL *)url;
+ (void)cacheData:(NSData *)data forURL:(NSURL *)url;

@end
