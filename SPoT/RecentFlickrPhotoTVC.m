//
//  RecentFlickrPhotoTVC.m
//  SPoT
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "RecentFlickrPhotoTVC.h"
#import "RecentFlickrPhotos.h"

@interface RecentFlickrPhotoTVC ()

@end

@implementation RecentFlickrPhotoTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.photos = [RecentFlickrPhotos allPhotos];
}

@end
