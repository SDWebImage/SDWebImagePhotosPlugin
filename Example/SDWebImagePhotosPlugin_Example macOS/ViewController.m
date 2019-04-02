//
//  ViewController.m
//  SDWebImagePhotosPlugin_Example macOS
//
//  Created by lizhuoli on 2018/7/19.
//  Copyright © 2018年 DreamPiggy. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImagePhotosPlugin/SDWebImagePhotosPlugin.h>
#import "TestCollectionViewItem.h"
#import "PHCollection.h" // Currently seems `PHAssetCollection` is not list in public header, but it works

static NSString * const TestCollectionViewItemIdentifier = @"TestCollectionViewItemIdentifier";

@interface ViewController () <NSCollectionViewDelegate, NSCollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray<NSURL *> *objects;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSCollectionView *collectionView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.objects = [NSMutableArray array];
    // Setup Photos Loader
    SDWebImageManager.defaultImageLoader = [SDWebImagePhotosLoader sharedLoader];
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.sd_targetSize = CGSizeMake(500, 500); // The original image size may be 4K, we only query the max view size :)
    SDWebImagePhotosLoader.sharedLoader.imageRequestOptions = options;

    // Photos Library Demo
    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                                          subtype:PHAssetCollectionSubtypeAlbumImported
                                                                                          options:nil];
    PHAssetCollection *collection = result.firstObject;
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
    for (PHAsset *asset in assets) {
        // You can use local identifier of `PHAsset` to create URL
//        NSURL *url = [NSURL sd_URLWithAssetLocalIdentifier:asset.localIdentifier];
        // Or even `PHAsset` itself
        NSURL *url = [NSURL sd_URLWithAsset:asset];
        [self.objects addObject:url];
    }
    
    [self.collectionView registerClass:[TestCollectionViewItem class] forItemWithIdentifier:TestCollectionViewItemIdentifier];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    TestCollectionViewItem *cell = [collectionView makeItemWithIdentifier:TestCollectionViewItemIdentifier forIndexPath:indexPath];
    NSURL *photosURL = self.objects[indexPath.item];
    cell.imageViewDisplay.sd_imageTransition = SDWebImageTransition.fadeTransition;
    [cell.imageViewDisplay sd_setImageWithURL:photosURL placeholderImage:nil options:SDWebImageFromLoaderOnly context:@{SDWebImageContextStoreCacheType: @(SDImageCacheTypeNone)}];
    return cell;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.objects.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

@end
