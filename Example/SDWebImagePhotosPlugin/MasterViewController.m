/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImagePhotosPlugin/SDWebImagePhotosPlugin.h>

@interface MyCustomTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *customTextLabel;
@property (nonatomic, strong) SDAnimatedImageView *customImageView;

@end

@implementation MyCustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _customImageView = [[SDAnimatedImageView alloc] initWithFrame:CGRectMake(20.0, 2.0, 60.0, 40.0)];
        [self.contentView addSubview:_customImageView];
        _customTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 12.0, 200, 20.0)];
        [self.contentView addSubview:_customTextLabel];
        
        _customImageView.clipsToBounds = YES;
        _customImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

@end

@interface MasterViewController ()

@property (nonatomic, strong) NSMutableArray<NSURL *> *objects;

@end

@implementation MasterViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"SDWebImage";
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"Reload"
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(reloadData)];
        self.objects = [NSMutableArray array];
        // Setup Photos Loader
        SDWebImageManager.defaultImageLoader = [SDWebImagePhotosLoader sharedLoader];
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.sd_targetSize = CGSizeMake(500, 500); // The original image size may be 4K, we only query the max view size :)
        SDWebImagePhotosLoader.sharedLoader.imageRequestOptions = options;
        // Request Video Asset Poster as well
        SDWebImagePhotosLoader.sharedLoader.requestImageAssetOnly = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Photos Library Demo
    [self reloadData];
}

- (void)fetchAssets {
    [self.objects removeAllObjects];
    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                          subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                                          options:nil];
    PHAssetCollection *collection = result.firstObject;
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
    for (PHAsset *asset in assets) {
        // You can use local identifier of `PHAsset` to create URL
        //            NSURL *url = [NSURL sd_URLWithAssetLocalIdentifier:asset.localIdentifier];
        // Or even `PHAsset` itself
        NSURL *url = [NSURL sd_URLWithAsset:asset];
        [self.objects addObject:url];
    }
}

- (void)reloadData
{
    [self fetchAssets];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    static UIImage *placeholderImage = nil;
    if (!placeholderImage) {
        placeholderImage = [UIImage imageNamed:@"placeholder"];
    }
    
    MyCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MyCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.customImageView.sd_imageTransition = SDWebImageTransition.fadeTransition;
        cell.customImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayIndicator;
    }
    
    cell.customTextLabel.text = [NSString stringWithFormat:@"Image #%ld", (long)indexPath.row];
    [cell.customImageView sd_setImageWithURL:self.objects[indexPath.row]
                            placeholderImage:placeholderImage
                                     options:SDWebImageFromLoaderOnly
                                     context:@{SDWebImageContextStoreCacheType : @(SDImageCacheTypeNone)}]; // Disable memory cache query/store
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *largeImageURL = self.objects[indexPath.row];
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    detailViewController.imageURL = largeImageURL;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
