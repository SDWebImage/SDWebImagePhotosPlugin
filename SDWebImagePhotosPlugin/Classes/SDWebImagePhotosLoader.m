/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImagePhotosLoader.h"
#import "NSURL+SDWebImagePhotosPlugin.h"
#import "PHImageRequestOptions+SDWebImagePhotosPlugin.h"
#import "SDWebImagePhotosError.h"
#import <objc/runtime.h>
#if SD_UIKIT
#import <MobileCoreServices/MobileCoreServices.h>
typedef UIImageOrientation SDImageOrientation;
#else
typedef CGImagePropertyOrientation SDImageOrientation;
#endif

@interface SDWebImagePhotosLoaderOperation : NSObject <SDWebImageOperation>

@property (nonatomic, assign) PHImageRequestID requestID;
@property (nonatomic, getter=isCancelled) BOOL cancelled;

@end

@implementation SDWebImagePhotosLoaderOperation

- (void)cancel {
    [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
    self.cancelled = YES;
}

@end

@interface SDWebImagePhotosLoader ()

@property (nonatomic, strong, nonnull) NSHashTable<SDWebImagePhotosLoaderOperation *> *operationsTable;
@property (nonatomic, strong, nonnull) dispatch_queue_t fetchQueue;

@end

@implementation SDWebImagePhotosLoader

- (void)dealloc {
#if SD_UIKIT
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
}

+ (SDWebImagePhotosLoader *)sharedLoader {
    static dispatch_once_t onceToken;
    static SDWebImagePhotosLoader *loader;
    dispatch_once(&onceToken, ^{
        loader = [[SDWebImagePhotosLoader alloc] init];
    });
    return loader;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
        requestOptions.networkAccessAllowed = YES;
        requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        requestOptions.version = PHImageRequestOptionsVersionCurrent;
        self.imageRequestOptions = requestOptions;
        self.operationsTable = [NSHashTable weakObjectsHashTable];
        self.fetchQueue = dispatch_queue_create("SDWebImagePhotosLoader", DISPATCH_QUEUE_SERIAL);
#if SD_UIKIT
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    }
    return self;
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    for (SDWebImagePhotosLoaderOperation *operation in self.operationsTable) {
        [operation cancel];
    }
    [self.operationsTable removeAllObjects];
}

#pragma mark - Helper
+ (BOOL)isAnimatedImageWithUTType:(NSString *)UTType {
    if (!UTType) {
        return NO;
    }
    if ([UTType isEqualToString:(__bridge_transfer NSString *)kUTTypeGIF]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isPhotosStatusAuthorized {
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized;
}

#pragma mark - SDImageLoader

- (BOOL)canRequestImageForURL:(NSURL *)url {
    return url.sd_isPhotosURL;
}

- (id<SDWebImageOperation>)requestImageWithURL:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDImageLoaderCompletedBlock)completedBlock {
    BOOL isPhotosURL = url.sd_isPhotosURL;
    if (!isPhotosURL) {
        if (completedBlock) {
            NSError *error = [NSError errorWithDomain:SDWebImagePhotosErrorDomain code:SDWebImagePhotosErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Photos URL is nil"}];
            completedBlock(nil, nil, error, YES);
        }
        return nil;
    }
    
    if (![[self class] isPhotosStatusAuthorized]) {
        if (completedBlock) {
            NSError *error = [NSError errorWithDomain:SDWebImagePhotosErrorDomain code:SDWebImagePhotosErrorNotAuthorized userInfo:@{NSLocalizedDescriptionKey : @"Photos library access not authorized"}];
            completedBlock(nil, nil, error, YES);
        }
    }
    
    PHFetchOptions *fetchOptions;
    if ([context valueForKey:SDWebImageContextPhotosFetchOptions]) {
        fetchOptions = [context valueForKey:SDWebImageContextPhotosFetchOptions];
    } else {
        fetchOptions = self.fetchOptions;
    }
    
    // Begin fetch asset in fetcher queue because this block main queue
    SDWebImagePhotosLoaderOperation *operation = [[SDWebImagePhotosLoaderOperation alloc] init];
    dispatch_async(self.fetchQueue, ^{
        if (operation.isCancelled) {
            // Cancelled
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
            if (completedBlock) {
                completedBlock(nil, nil, error, YES);
            }
            return;
        }
        PHAsset *asset = url.sd_asset;
        if (!asset) {
            NSString *localIdentifier = url.sd_assetLocalIdentifier;
            PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:fetchOptions];
            asset = fetchResult.firstObject;
        }
        // Only support image
        if (!asset || asset.mediaType != PHAssetMediaTypeImage) {
            // Call error
            NSError *error = [NSError errorWithDomain:SDWebImagePhotosErrorDomain code:SDWebImagePhotosErrorNotImageAsset userInfo:nil];
            if (completedBlock) {
                completedBlock(nil, nil, error, YES);
            }
            return;
        }
        
        // Request image data instead of image
        BOOL requestImageData;
        if (context[SDWebImageContextPhotosRequestImageData]) {
            requestImageData = [context[SDWebImageContextPhotosRequestImageData] boolValue];
        } else {
            // Check UTType
            NSString *uniformTypeIdentifier;
            if ([asset respondsToSelector:@selector(uniformTypeIdentifier)]) {
                uniformTypeIdentifier = [asset valueForKey:NSStringFromSelector(@selector(uniformTypeIdentifier))];
            }
            // Check Animated Image, which need the original image data
            requestImageData = [[self class] isAnimatedImageWithUTType:uniformTypeIdentifier];
        }
        
        if (requestImageData) {
            [self fetchImageDataWithAsset:asset operation:operation url:url options:options context:context progress:progressBlock completed:completedBlock];
        } else {
            [self fetchImageWithAsset:asset operation:operation url:url options:options context:context progress:progressBlock completed:completedBlock];
        }
    });
    [self.operationsTable addObject:operation];
    
    return operation;
}

- (BOOL)shouldBlockFailedURLWithURL:(NSURL *)url error:(NSError *)error {
    if ([error.domain isEqualToString:SDWebImagePhotosErrorDomain]) {
        return error.code == SDWebImagePhotosErrorInvalidURL
        || error.code == SDWebImagePhotosErrorNotImageAsset;
    }
    return NO;
}

// This is used for normal image loading (With `requestImage:` API)
- (void)fetchImageWithAsset:(PHAsset *)asset operation:(SDWebImagePhotosLoaderOperation *)operation url:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDImageLoaderCompletedBlock)completedBlock {
    PHImageRequestOptions *requestOptions;
    if ([context valueForKey:SDWebImageContextPhotosImageRequestOptions]) {
        requestOptions = [context valueForKey:SDWebImageContextPhotosImageRequestOptions];
    } else {
        requestOptions = self.imageRequestOptions;
    }
    CGSize targetSize = requestOptions.sd_targetSize;
    if (CGSizeEqualToSize(targetSize, SDWebImagePhotosLoaderPixelSize)) {
        targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    } else if (CGSizeEqualToSize(targetSize, SDWebImagePhotosLoaderPointSize)) {
        CGFloat scale = 1;
        NSNumber *scaleValue = [context valueForKey:SDWebImageContextImageScaleFactor];
        if (scaleValue) {
            scale = scaleValue.doubleValue;
            if (scale < 1) {
                scale = 1;
            }
        } else {
#if SD_MAC
            scale = [NSScreen mainScreen].backingScaleFactor;
#else
            scale = [UIScreen mainScreen].scale;
#endif
        }
        targetSize = CGSizeMake(asset.pixelHeight * scale, asset.pixelHeight * scale);
    }
    PHImageContentMode contentMode = requestOptions.sd_contentMode;
    
    // Progerss Handler
    if (progressBlock) {
        requestOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            // Global queue, the same as us
            if (progressBlock) {
                progressBlock(progress * SDWebImagePhotosProgressExpectedSize, SDWebImagePhotosProgressExpectedSize, url);
            }
        };
    }
    
    __weak typeof(operation) weakOperation = operation;
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:contentMode options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (weakOperation.isCancelled) {
            // Cancelled
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
            if (completedBlock) {
                completedBlock(nil, nil, error, YES);
            }
            return;
        }
        if (result) {
            BOOL isDegraded = [info[PHImageResultIsDegradedKey] boolValue];
            BOOL finished;
            if (requestOptions.deliveryMode == PHImageRequestOptionsDeliveryModeOpportunistic) {
                // The completion block may call multiple times. Only pass YES when `isDegraded` set to NO
                finished = !isDegraded;
            } else {
                finished = YES;
            }
            dispatch_main_async_safe(^{
                if (completedBlock) {
                    completedBlock(result, nil, nil, finished);
                }
            });
        } else {
            NSError *error = info[PHImageErrorKey];
            dispatch_main_async_safe(^{
                if (completedBlock) {
                    completedBlock(nil, nil, error, YES);
                }
            });
        }
    }];
    
    operation.requestID = requestID;
}

// This is used for animated image loading (With `requestImageData:` API)
- (void)fetchImageDataWithAsset:(PHAsset *)asset operation:(SDWebImagePhotosLoaderOperation *)operation url:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDImageLoaderCompletedBlock)completedBlock {
    PHImageRequestOptions *requestOptions;
    if ([context valueForKey:SDWebImageContextPhotosImageRequestOptions]) {
        requestOptions = [context valueForKey:SDWebImageContextPhotosImageRequestOptions];
    } else {
        requestOptions = self.imageRequestOptions;
    }
    
    // Progerss Handler
    if (progressBlock) {
        requestOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            // Global queue, the same as us
            if (progressBlock) {
                progressBlock(progress * SDWebImagePhotosProgressExpectedSize, SDWebImagePhotosProgressExpectedSize, url);
            }
        };
    }
    
    __weak typeof(operation) weakOperation = operation;
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, SDImageOrientation orientation, NSDictionary * _Nullable info) {
        if (weakOperation.isCancelled) {
            // Cancelled
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
            if (completedBlock) {
                completedBlock(nil, nil, error, YES);
            }
            return;
        }
        if (imageData) {
            // Decode the image with data
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if (weakOperation.isCancelled) {
                    // Cancelled
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
                    if (completedBlock) {
                        completedBlock(nil, nil, error, YES);
                    }
                    return;
                }
                UIImage *image = SDImageLoaderDecodeImageData(imageData, url, options, context);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completedBlock) {
                        completedBlock(image, imageData, nil, YES);
                    }
                });
            });
        } else {
            NSError *error = info[PHImageErrorKey];
            dispatch_main_async_safe(^{
                if (completedBlock) {
                    completedBlock(nil, nil, error, YES);
                }
            })
        }
    }];
    
    operation.requestID = requestID;
}

@end
