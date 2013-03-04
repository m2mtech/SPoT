//
//  NetworkActivityIndicator.m
//  SPoT
//
//  Created by Martin Mandl on 04.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "NetworkActivityIndicator.h"

@implementation NetworkActivityIndicator

+ (void)counterChange:(NSUInteger)change
{
    static NSUInteger counter = 0;
    static dispatch_queue_t queue;
    if (!queue) {
        queue = dispatch_queue_create("NetworkActivityIndicator Queue", NULL);
    }
    dispatch_sync(queue, ^{
        if (counter + change <= 0) {
            counter = 0;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        } else {
            counter += change;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    });
}


+ (void)start
{
    [self counterChange:1];
}

+ (void)stop
{
    [self counterChange:-1];
}

@end
