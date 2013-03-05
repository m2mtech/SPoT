//
//  FlickrCache.m
//  SPoT
//
//  Created by Martin Mandl on 04.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrCache.h"

@interface FlickrCache()

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSURL *cacheFolder;

@end

@implementation FlickrCache

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [[NSFileManager alloc] init];
    }
    return _fileManager;
}

- (NSURL *)cacheFolder
{
    if (!_cacheFolder) {
        _cacheFolder = [[[self.fileManager URLsForDirectory:NSCachesDirectory
                                                  inDomains:NSUserDomainMask] lastObject]
                        URLByAppendingPathComponent:FLICKRCACHE_FOLDER
                                        isDirectory:YES];
        BOOL isDir = NO;
        if (![self.fileManager fileExistsAtPath:[_cacheFolder path]
                                    isDirectory:&isDir]) {
            [self.fileManager createDirectoryAtURL:_cacheFolder
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:nil];
        }
    }
    return _cacheFolder;
}

- (NSURL *)getCachedURLforURL:(NSURL *)url
{
    return [self.cacheFolder URLByAppendingPathComponent:
            [[url path] lastPathComponent]];    
}

- (BOOL)fileExistsAtURL:(NSURL *)url
{
    return [self.fileManager fileExistsAtPath:[url path]];
}

- (void)cleanupOldFiles
{
    NSDirectoryEnumerator *dirEnumerator =
    [self.fileManager enumeratorAtURL:self.cacheFolder
           includingPropertiesForKeys:@[NSURLAttributeModificationDateKey]
                              options:NSDirectoryEnumerationSkipsHiddenFiles
                         errorHandler:nil];
    NSNumber *fileSize;
    NSDate *fileDate;
    NSMutableArray *files = [NSMutableArray array];
    __block NSUInteger dirSize = 0;
    for (NSURL *url in dirEnumerator) {
        [url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        [url getResourceValue:&fileDate forKey:NSURLAttributeModificationDateKey error:nil];
        dirSize += [fileSize integerValue];        
        [files addObject:@{@"url":url, @"size":fileSize, @"date":fileDate}];
    }
    int maxCacheSize = FLICKRCACHE_MAXSIZE_IPHONE;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        maxCacheSize = FLICKRCACHE_MAXSIZE_IPAD;
    }
    if (dirSize > maxCacheSize) {
        NSArray *sorted = [files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1[@"date"] compare:obj2[@"date"]];
        }];
        [sorted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            dirSize -= [obj[@"size"] integerValue];
            NSError *error;
            [self.fileManager removeItemAtURL:obj[@"url"] error:&error];
            *stop = error || (dirSize < maxCacheSize);
        }];
    }    
}

+ (NSURL *)cachedURLforURL:(NSURL *)url
{
    FlickrCache *cache = [[FlickrCache alloc] init];
    NSURL *cachedUrl = [cache getCachedURLforURL:url];
    if ([cache fileExistsAtURL:cachedUrl]) {
        return cachedUrl;
    }
    return nil;
}

+ (void)cacheData:(NSData *)data forURL:(NSURL *)url
{
    if (!data) return;
    FlickrCache *cache = [[FlickrCache alloc] init];
    NSURL *cachedUrl = [cache getCachedURLforURL:url];
    if ([cache fileExistsAtURL:cachedUrl]) {
        [cache.fileManager setAttributes:@{NSFileModificationDate:[NSDate date]}
                            ofItemAtPath:[cachedUrl path] error:nil];
    } else {
        [cache.fileManager createFileAtPath:[cachedUrl path]
                                   contents:data attributes:nil];
        [cache cleanupOldFiles];
    }
}

@end
