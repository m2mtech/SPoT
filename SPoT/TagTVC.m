//
//  TagTVC.m
//  SPoT
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "TagTVC.h"
#import "FlickrFetcher.h"

@interface TagTVC ()

@property (nonatomic, strong) NSArray *photos; // of NSDictionary
@property (nonatomic, strong) NSDictionary *photosByTag; // of NSArray of NSDictionary

@end

@implementation TagTVC

- (void)updatePhotosByTag
{
    NSMutableDictionary *photosByTag = [NSMutableDictionary dictionary];
    for (NSDictionary *photo in self.photos) {
        for (NSString *tag in [photo[FLICKR_TAGS] componentsSeparatedByString:@" "]) {
            if ([tag isEqualToString:@"cs193pspot"]) continue;
            if ([tag isEqualToString:@"portrait"]) continue;
            if ([tag isEqualToString:@"landscape"]) continue;
            NSMutableArray *photos = [photosByTag objectForKey:tag];
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
    self.photos = [FlickrFetcher stanfordPhotos];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSString *tag = [[self.photosByTag allKeys] objectAtIndex:indexPath.row];
    int photoCount = [self.photosByTag[tag] count];
    cell.textLabel.text = [tag capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@", photoCount, photoCount > 1 ? @"s" : @""];
    
    return cell;
}

#pragma mark - Table view delegate

@end
