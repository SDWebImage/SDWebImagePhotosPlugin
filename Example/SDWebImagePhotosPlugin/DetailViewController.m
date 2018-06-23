/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "DetailViewController.h"
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface DetailViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation DetailViewController

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidDoubleTapped:(UIGestureRecognizer *)gestureRecognizer {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    }
}

- (void)configureView
{
    self.scrollView.delegate = self;
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDidDoubleTapped:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTapGestureRecognizer];
    if (!self.imageView.sd_imageIndicator) {
        self.imageView.sd_imageIndicator = SDWebImageProgressIndicator.defaultIndicator;
    }
    [self.imageView sd_setImageWithURL:self.imageURL
                      placeholderImage:nil
                               options:SDWebImageFromLoaderOnly
                               context:@{SDWebImageContextStoreCacheType : @(SDImageCacheTypeNone)}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configureView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
