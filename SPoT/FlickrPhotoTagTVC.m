//
//  TagTVC.m
//  SPoT
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrPhotoTagTVC.h"
#import "FlickrFetcher.h"
#import "NetworkActivityIndicator.h"

@interface FlickrPhotoTagTVC ()

@property (nonatomic, strong) NSArray *photos; // of NSDictionary
@property (nonatomic, strong) NSDictionary *photosByTag; // of NSArray of NSDictionary
@property (nonatomic, strong) NSArray *tags;

@end

@implementation FlickrPhotoTagTVC

- (void)updatePhotosByTag
{
    NSMutableDictionary *photosByTag = [NSMutableDictionary dictionary];
    for (NSDictionary *photo in self.photos) {
        for (NSString *tag in [photo[FLICKR_TAGS] componentsSeparatedByString:@" "]) {
            if ([tag isEqualToString:@"cs193pspot"]) continue;
            if ([tag isEqualToString:@"portrait"]) continue;
            if ([tag isEqualToString:@"landscape"]) continue;
            NSMutableArray *photos = photosByTag[tag];
            if (!photos) {
                photos = [NSMutableArray array];
                photosByTag[tag] = photos;
            }
            [photos addObject:photo];
        }
    }
    self.photosByTag = photosByTag;
    self.tags = [[photosByTag allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self updatePhotosByTag];
    [self.tableView reloadData];
}


- (void)loadPhtosFromFlickr
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t queue = dispatch_queue_create("Flickr Downloader", NULL);
    dispatch_async(queue, ^{
        [NetworkActivityIndicator start];
        //[NSThread sleepForTimeInterval: 2.0];
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        [NetworkActivityIndicator stop];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
            [self.refreshControl endRefreshing];
        });
    }); 
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(loadPhtosFromFlickr)
                  forControlEvents:UIControlEventValueChanged];
    [self loadPhtosFromFlickr];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photos"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSString *tag = self.tags[indexPath.row];
                    [segue.destinationViewController performSelector:@selector(setPhotos:)
                                                          withObject:self.photosByTag[tag]];
                    [segue.destinationViewController setTitle:[tag capitalizedString]];
                }
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSString *tag = self.tags[indexPath.row];
    int photoCount = [self.photosByTag[tag] count];
    cell.textLabel.text = [tag capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@", photoCount, photoCount > 1 ? @"s" : @""];
    
    return cell;
}

#pragma mark - Table view delegate

@end
