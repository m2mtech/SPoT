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
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self updatePhotosByTag];
    [self.tableView reloadData];
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_queue_t queue = dispatch_queue_create("Flickr Downloader", NULL);
    dispatch_async(queue, ^{
        [NetworkActivityIndicator start];
        //[NSThread sleepForTimeInterval:
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        [NetworkActivityIndicator stop];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
        });
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photos"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSString *tag = [self tagForRow:indexPath.row];
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
    return [self.photosByTag count];
}

- (NSString *)tagForRow:(NSUInteger)row
{
    return [[self.photosByTag allKeys] sortedArrayUsingSelector:@selector(compare:)][row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSString *tag = [self tagForRow:indexPath.row];
    int photoCount = [self.photosByTag[tag] count];
    cell.textLabel.text = [tag capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@", photoCount, photoCount > 1 ? @"s" : @""];
    
    return cell;
}

#pragma mark - Table view delegate

@end
