//
//  RecentFlickrPhotos.h
//  SPoT
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentFlickrPhotos : NSObject

+ (NSArray *)allPhotos;
+ (void) addPhoto:(NSDictionary *)photo;

@end
