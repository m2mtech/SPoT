//
//  ImageViewController.m
//  Shutterbug
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate,
                                   UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;

@end

@implementation ImageViewController

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        if (image) {
            self.scrollView.zoomScale = 1.0;
            self.scrollView.contentSize = image.size;
            self.imageView.image = image;
            self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            [self setZoomScaleToFillScreen];
        }
    }
}

- (void)setZoomScaleToFillScreen
{
    double wScale = self.scrollView.bounds.size.width / self.imageView.image.size.width;
    double hScale = self.scrollView.bounds.size.height / self.imageView.image.size.height;
    if (wScale > hScale) self.scrollView.zoomScale = wScale;
    else self.scrollView.zoomScale = hScale;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
    self.titleBarButtonItem.title = self.title;
    self.splitViewController.delegate = self;
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setZoomScaleToFillScreen];
}

#pragma mark - Scroll view
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - Split view

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) {
        [toolbarItems removeObject:_splitViewBarButtonItem];
    }
    if (splitViewBarButtonItem) {
        [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    }
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                               target:barButtonItem.target
                               action:barButtonItem.action];
    barButtonItem = button;
    self.splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
}


@end
