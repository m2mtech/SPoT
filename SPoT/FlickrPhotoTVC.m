//
//  FlickrPhotoTVC.m
//  Shutterbug
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrPhotoTVC.h"
#import "FlickrFetcher.h"
#import "RecentFlickrPhotos.h"

@interface FlickrPhotoTVC ()

@end

@implementation FlickrPhotoTVC

- (void)setPhotos:(NSArray *)photos
{
    _photos = [photos sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_TITLE ascending:YES]]];
    [self.tableView reloadData];
}

- (void)sendDataforIndexPath:(NSIndexPath *)indexPath toViewController:(UIViewController *)vc
{
    if ([vc respondsToSelector:@selector(setImageURL:)]) {
        [RecentFlickrPhotos addPhoto:self.photos[indexPath.row]];
        NSURL *url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
        [vc performSelector:@selector(setImageURL:) withObject:url];
        [vc setTitle:[self titleForRow:indexPath.row]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                [self sendDataforIndexPath:indexPath
                          toViewController:segue.destinationViewController];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (NSString *)titleForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_PHOTO_TITLE] description];
}

- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [[self.photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self sendDataforIndexPath:indexPath
              toViewController:[self.splitViewController.viewControllers lastObject]];
}


@end
