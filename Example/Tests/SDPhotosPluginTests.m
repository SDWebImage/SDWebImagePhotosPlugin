/*
 * This file is part of the SDWebImagePhotosPlugin package.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDTestCase.h"
#import "SystemAlert.h"

@interface SDPhotosPluginTests : SDTestCase

@end

@implementation SDPhotosPluginTests

+ (void)setUp {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Photos Library Permission"];
    // Request Photos Library access in advance
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        [expectation fulfill];
    }];
    // Auto grant access (OK button)
    [SystemAlert tapRightButton];
    
    __unused XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:kAsyncTestTimeout];
}

- (void)testUIImageViewSetImageWithAsset {
    XCTestExpectation *expectation = [self expectationWithDescription:@"UIImageView setImageWithAsset"];
    SDWebImageManager *manager = [[SDWebImageManager alloc] initWithCache:SDImageCache.sharedImageCache loader:SDImagePhotosLoader.sharedLoader];
    PHAsset *asset = [self smartAlbumAssets].firstObject;
    expect(asset).notTo.beNil();
    NSURL *originalImageURL = [NSURL sd_URLWithAsset:asset];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:originalImageURL
                 placeholderImage:nil
                          options:SDWebImageFromLoaderOnly
                          context:@{SDWebImageContextCustomManager : manager}
                         progress:nil
                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                            expect(image).toNot.beNil();
                            expect(error).to.beNil();
                            expect(originalImageURL).to.equal(imageURL);
                            expect(imageView.image).to.equal(image);
                            [expectation fulfill];
                        }];
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testUIImageViewSetImageWithAssetLocalIdentifier {
    XCTestExpectation *expectation = [self expectationWithDescription:@"UIImageView setImageWithAssetLocalIdentifier"];
    SDWebImageManager *manager = [[SDWebImageManager alloc] initWithCache:SDImageCache.sharedImageCache loader:SDImagePhotosLoader.sharedLoader];
    NSString *localIdentifier = [self smartAlbumAssets].firstObject.localIdentifier;
    expect(localIdentifier).notTo.beNil();
    NSURL *originalImageURL = [NSURL sd_URLWithAssetLocalIdentifier:localIdentifier];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:originalImageURL
                 placeholderImage:nil
                          options:SDWebImageFromLoaderOnly
                          context:@{SDWebImageContextCustomManager : manager}
                         progress:nil
                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                            expect(image).toNot.beNil();
                            expect(error).to.beNil();
                            expect(originalImageURL).to.equal(imageURL);
                            expect(imageView.image).to.equal(image);
                            [expectation fulfill];
                        }];
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testUIImageViewSetImageWithAssetAndThumbnailPixelSize {
    XCTestExpectation *expectation = [self expectationWithDescription:@"UIImageView setImageWithAssetAndThumbnailPixelSize"];
    SDWebImageManager *manager = [[SDWebImageManager alloc] initWithCache:SDImageCache.sharedImageCache loader:SDImagePhotosLoader.sharedLoader];
    PHAsset *asset = [self smartAlbumAssets].firstObject;
    expect(asset).notTo.beNil();
    NSURL *originalImageURL = [NSURL sd_URLWithAsset:asset];
    CGSize thumbnailPixelSize = CGSizeMake(1000, 1000);
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:originalImageURL
                 placeholderImage:nil
                          options:0
                          context:@{SDWebImageContextCustomManager : manager, SDWebImageContextImageThumbnailPixelSize : @(thumbnailPixelSize)}
                         progress:nil
                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                            expect(image).toNot.beNil();
                            expect(error).to.beNil();
                            expect(MAX(image.size.width, image.size.height), MAX(thumbnailPixelSize.width, thumbnailPixelSize.height)); // Aspect Fit
                            expect(originalImageURL).to.equal(imageURL);
                            expect(imageView.image).to.equal(image);
                            [expectation fulfill];
                        }];
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testUIImageViewSetImageWithGIFAsset {
    XCTestExpectation *expectation = [self expectationWithDescription:@"UIImageView setImageWithGIFAsset"];
    
    NSData *GIFData = [self testGIFData];
    __block NSString *localIdentifier = nil;
    // Write GIF image into Photos Library firstly
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        [request addResourceWithType:PHAssetResourceTypePhoto data:GIFData options:nil];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        expect(success).to.beTruthy();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Query the GIF image with localIdentifier
            SDWebImageManager *manager = [[SDWebImageManager alloc] initWithCache:SDImageCache.sharedImageCache loader:SDImagePhotosLoader.sharedLoader];
            NSURL *originalImageURL = [NSURL sd_URLWithAssetLocalIdentifier:localIdentifier];
            
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView sd_setImageWithURL:originalImageURL
                         placeholderImage:nil
                                  options:SDWebImageFromLoaderOnly
                                  context:@{SDWebImageContextCustomManager : manager}
                                 progress:nil
                                completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                    // Strong retain imageView to avoid immediatelly dealloc
                                    expect(imageView.image).equal(image);
                                    // Expect animated image
                                    expect(image.sd_isAnimated).to.beTruthy();
                                    // Clean the temp GIF asset
                                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
                                        [PHAssetChangeRequest deleteAssets:assets];
                                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                                        [expectation fulfill];
                                    }];
            }];
        });
    }];
    
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout * 2 handler:nil];
}

#pragma mark - Util

- (PHFetchResult<PHAsset *> *)smartAlbumAssets {
    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                          subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                                          options:nil];
    PHAssetCollection *collection = result.firstObject;
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
    
    return assets;
}

- (NSString *)testGIFPath {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return [testBundle pathForResource:@"TestImage" ofType:@"gif"];
}

- (NSData *)testGIFData {
    NSData *testData = [NSData dataWithContentsOfFile:[self testGIFPath]];
    return testData;
}

@end
