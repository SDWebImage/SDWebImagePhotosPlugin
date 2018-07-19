//
//  ViewController.m
//  SDWebImagePhotosPlugin_Example macOS
//
//  Created by lizhuoli on 2018/7/19.
//  Copyright © 2018年 DreamPiggy. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImagePhotosPlugin/SDWebImagePhotosPlugin.h>
#import "TestCollectionView.h"
#import "TestCollectionViewItem.h"
#import "PHCollection.h" // Currently seems `PHAssetCollection` is not list in public header, but it works

static NSString * const TestCollectionViewItemIdentifier = @"TestCollectionViewItemIdentifier";

@interface ViewController () <NSCollectionViewDelegate, NSCollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray<NSURL *> *objects;
@property (nonatomic, strong) TestCollectionView *collectionView;
@property (nonatomic, strong) NSScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.objects = [NSMutableArray array];
    // Setup Photos Loader
    SDWebImageManager.defaultImageLoader = [SDWebImagePhotosLoader sharedLoader];

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
        //            NSURL *url = [NSURL sd_URLWithAssetLocalIdentifier:asset.localIdentifier];
        // Or even `PHAsset` itself
        NSURL *url = [NSURL sd_URLWithAsset:asset];
        [self.objects addObject:url];
    }
    
    [self.view addSubview:self.scrollView];
    [self.collectionView reloadData];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    TestCollectionViewItem *cell = [collectionView makeItemWithIdentifier:TestCollectionViewItemIdentifier forIndexPath:indexPath];
    NSURL *photosURL = self.objects[indexPath.item];
    [cell.imageViewDisplay sd_setImageWithURL:photosURL placeholderImage:nil options:SDWebImageFromLoaderOnly context:@{SDWebImageContextStoreCacheType: @(SDImageCacheTypeNone)}];
    return cell;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.objects.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (TestCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[TestCollectionView alloc] initWithFrame:self.view.bounds];
        NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
        layout.scrollDirection = NSCollectionViewScrollDirectionVertical;
        layout.itemSize = NSMakeSize(300, 300);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        _collectionView.collectionViewLayout = layout;
        _collectionView.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        [_collectionView registerClass:[TestCollectionViewItem class] forItemWithIdentifier:TestCollectionViewItemIdentifier];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (NSScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[NSScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        _scrollView.documentView = self.collectionView;
    }
    return _scrollView;
}

@end
