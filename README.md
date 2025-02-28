# SDWebImagePhotosPlugin

[![CI Status](https://img.shields.io/travis/SDWebImage/SDWebImagePhotosPlugin.svg?style=flat)](https://travis-ci.org/SDWebImage/SDWebImagePhotosPlugin)
[![Version](https://img.shields.io/cocoapods/v/SDWebImagePhotosPlugin.svg?style=flat)](https://cocoapods.org/pods/SDWebImagePhotosPlugin)
[![License](https://img.shields.io/cocoapods/l/SDWebImagePhotosPlugin.svg?style=flat)](https://cocoapods.org/pods/SDWebImagePhotosPlugin)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImagePhotosPlugin.svg?style=flat)](https://cocoapods.org/pods/SDWebImagePhotosPlugin)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/SDWebImage/SDWebImagePhotosPlugin)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager/)
[![codecov](https://codecov.io/gh/SDWebImage/SDWebImagePhotosPlugin/branch/master/graph/badge.svg)](https://codecov.io/gh/SDWebImage/SDWebImagePhotosPlugin)

## What it's for
SDWebImagePhotosPlugin is a plugin for the [SDWebImage](https://github.com/rs/SDWebImage/) framework, which provides image loading support for the [Photos Library](https://developer.apple.com/documentation/photokit).

This plugin allows you to use your familiar View Category method from SDWebImage, for loading Photos images with `PHAsset` or `localIdentifier`.


## Requirements

+ iOS 9+
+ macOS 10.13+
+ tvOS 10+
+ Xcode 10+

## Installation

#### CocoaPods

SDWebImagePhotosPlugin is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDWebImagePhotosPlugin'
```

#### Carthage

SDWebImagePhotosPlugin is available through [Carthage](https://github.com/Carthage/Carthage).

```
github "SDWebImage/SDWebImagePhotosPlugin"
```

#### Swift Package Manager (Xcode 11+)

SDWebImagePhotosPlugin is available through [Swift Package Manager](https://swift.org/package-manager).

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImagePhotosPlugin.git", from: "1.0")
    ]
)
```

## Usage
**Important!** To use this Photos Library plugin, you first need to register the photos loader to image manager.

There are two ways to register the photos loader. One is for temporarily usage (when providing URL is definitely Photos URL but not HTTP URL), and another for global support (don't need any check, supports both HTTP URL as well as Photos URL).

#### Use custom manager (temporarily)
You can create a custom manager for temporary usage. When you use custom manager, be sure to specify `SDWebImageContextCustomManager` context option with your custom manager for View Category methods.

+ Objective-C

```objectivec
// Assign loader to custom manager
SDWebImageManager *manager = [[SDWebImageManager alloc] initWithCache:SDImageCache.sharedImageCache loader:SDImagePhotosLoader.sharedLoader];
```

+ Swift

```swift
// Assign loader to custom manager
let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
```

#### Use loaders manager (globally)
You can replace the default manager's loader implementation using [loaders manager](https://github.com/rs/SDWebImage/wiki/Advanced-Usage#loaders-manager) to support both HTTP && Photos URL globally. Put these code just at the application launch time (or some time just before `SDWebImageManager.sharedManager` is initialized).

+ Objective-C

```objectivec
// Supports HTTP URL as well as Photos URL globally
SDImageLoadersManager.sharedManager.loaders = @[SDWebImageDownloader.sharedDownloader, SDImagePhotosLoader.sharedLoader];
// Replace default manager's loader implementation
SDWebImageManager.defaultImageLoader = SDImageLoadersManager.sharedManager;
```

+ Swift

```swift
// Supports HTTP URL as well as Photos URL globally
SDImageLoadersManager.shared.loaders = [SDWebImageDownloader.shared, SDImagePhotosLoader.shared]
// Replace default manager's loader implementation
SDWebImageManager.defaultImageLoader = SDImageLoadersManager.shared
```

#### Load Images
To start loading the Photos Library image, use the `NSURL+SDWebImagePhotosPlugin` to create a Photos URL and call View Category method.

+ Objective-C

```objectivec
// Create with `PHAsset`
PHAsset *asset;
NSURL *photosURL = asset.sd_URLRepresentation;
// The same as `[NSURL sd_URLWithAsset:asset];`
// Create with `localIdentifier`
NSString *identifier;
NSURL *potosURL = [NSURL sd_URLWithAssetLocalIdentifier:identifier];

// Load image (assume using custom manager)
[imageView sd_setImageWithURL:photosURL placeholderImage:nil context:@{SDWebImageContextCustomManager: manager}];
```

+ Swift

```swift
// Create with `PHAsset`
let asset: PHAsset
let photosURL = asset.sd_URLRepresentation
// The same as `NSURL.sd_URL(with: asset) as URL`
// Create with `localIdentifier`
let identifier: String
let potosURL = NSURL.sd_URL(withAssetLocalIdentifier: identifier) as URL

// Load image (assume using custom manager)
imageView.sd_setImage(with: photosURL, placeholderImage: nil, context: [.customManager: manager])
```

#### Animated Images
SDWebImagePhotosPlugin supports GIF images stored in Photos Library as well. Just use the same API as normal images to query the asset. We will query the image data and decode the animated images (compatible with `UIImageView` as well as [SDAnimatedImageView](https://github.com/rs/SDWebImage/wiki/Advanced-Usage#animated-image-50))


#### Video Assets
SDWebImagePhotosPlugin supports loading Video Asset poster as well. By default, we don't allow non-image type assets, to avoid accidentally picking a wrong Asset. But you can disable this limit as well.

+ Objective-C

```objectivec
SDImagePhotosLoader.sharedLoader.requestImageAssetOnly = NO;
``` 

+ Swift

```swift
SDImagePhotosLoader.shared.requestImageAssetOnly = false
```

Then just request the PHAssets or using the fetch options, which the media type is `.video`.

#### HDR Photo Rendering
To enable HDR decoding and rendering, upgrade SDWebImage to 5.21.0+, then, request the image data from Photos Library and turn on HDR decoding.

+ Objective-C

```objective-c
#if TARGET_OS_OSX
BOOL supportsHDR = NSScreen.mainScreen.maximumPotentialExtendedDynamicRangeColorComponentValue > 1.0;
#else
#define NSImageDynamicRangeHigh UIImageDynamicRangeHigh
BOOL supportsHDR = UIScreen.mainScreen.potentialEDRHeadroom > 1.0;
#endif
SDWebImageMutableContext *context = [@{SDWebImageContextStoreCacheType: @(SDImageCacheTypeNone)} mutableCopy];
if (supportsHDR) {
    if (@available (macOS 14.0, iOS 17, *)) {
        cell.imageViewDisplay.preferredImageDynamicRange = NSImageDynamicRangeHigh; // Enable Image View Level control for HDR
    }
    context[SDWebImageContextPhotosRequestImageData] = @(YES); // Photos Library only load HDR info when requestImageData
    context[SDWebImageContextImageDecodeToHDR] = @(YES); // When decoding HDR data, we need explicit enable HDR decoding
}
// Then loading HDR assets with context option
[imageView sd_setImageWithURL:photosURL placeholderImage:nil context:context];
```

+ Swift

```swift
#if os(macOS)
let supportsHDR = NSScreen.main.maximumPotentialExtendedDynamicRangeColorComponentValue > 1.0
#else
let supportsHDR = UIScreen.main.potentialEDRHeadroom > 1.0
#endif
var context = [
    SDWebImageContextStoreCacheType: SDImageCacheType.none.rawValue
]
if supportsHDR {
    if #available(macOS 14.0, iOS 17, *) {
        cell.imageViewDisplay.preferredImageDynamicRange = .high // Enable Image View Level control for HDR
    }
    context[.photosRequestImageData] = true // Photos Library only load HDR info when requestImageData
    context[.imageDecodeToHDR] = true // When decoding HDR data, we need explicit enable HDR decoding
}
// Then loading HDR assets with context option
imageView.sd_setImage(with: photosURL, placeholderImage: nil, context:context)
```

#### Fetch/Request Options
To specify options like `PHFetchOptions` or `PHImageRequestOptions` for Photos Library. Either to change the correspond properties in loader, or provide a context options for each image request.

+ Objective-C

```objectivec
// loader-level options
// ignore iCloud Shared Album (`localIdentifier` Photos URL only)
PHFetchOptions *fetchOptions = SDImagePhotosLoader.sharedLoader.fetchOptions;
fetchOptions.predicate = [NSPredicate predicateWithFormat:@"sourceType != %d", PHAssetSourceTypeCloudShared];

// request-level options
// disable iCloud Photos Library (networkAccessAllowed defaults to YES)
PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
requestOptions.networkAccessAllowed = NO;
[imageView sd_setImageWithURL:photosURL placeholderImage:nil context:@{SDWebImageContextPhotosImageRequestOptions: requestOptions, SDWebImageContextCustomManager: manager}];
```

+ Swift

```swift
// loader-level options
// ignore iCloud Shared Album (`localIdentifier` Photos URL only)
let fetchOptions = SDImagePhotosLoader.shared.fetchOptions
fetchOptions.predicate = NSPredicate(format: "sourceType != %d", PHAssetSourceType.typeCloudShared.rawValue)

// request-level options
// disable iCloud Photos Library (networkAccessAllowed defaults to YES)
let requestOptions = PHImageRequestOptions()
requestOptions.networkAccessAllowed = false
imageView.sd_setImage(with: photosURL, placeholderImage: nil, context:[.photosImageRequestOptions: requestOptions, .customManager: manager])
```

#### Control Query Image Size
Photos taken by the iPhone camera may have a really large pixel size (4K+). So, if you want to load large Photos Library assets for rendering, you should specify target size with a limited size (for example, the size of the imageView that you are loading into).

By default, we query the target size that matches the original image's largest size (see: [PHImageManagerMaximumSize](https://developer.apple.com/documentation/photokit/phimagemanagermaximumsize?language=objc)), which may consume too much memory on iOS devices. There are also two built-in dynamic values `SDWebImagePhotosPixelSize/SDWebImagePhotosPointSize` which are suitable for some cases.

You can change the fetch image size by either using the `PHImageRequestOptions.sd_targetSize`, or [Thumbnail Decoding](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#thumbnail-decoding-550) via `.imageThumbnailPixelSize` context option.

Control query image size limit in global:

+ Objective-C

```objective-c
SDImagePhotosLoader.sharedLoader.imageRequestOptions.sd_targetSize = CGSizeMake(1000, 1000); // Limit 1000x1000 pixels
```

+ Swift

```swift
SDImagePhotosLoader.shared.imageRequestOptions.sd_targetSize = CGSize(width: 1000, height: 1000) // Limit 1000x1000 pixels
```

Control query image size for individual assets:

+ Objective-C

```objective-c
UIImageView *imageView;
PHAsset *asset;
NSURL *url = asset.sd_URLRepresentation;
[imageView.sd_setImageWithURL:url options:0 context:@{SDWebImageContextImageThumbnailPixelSize: @(imageView.bounds.size)}]; // Fetch image based on image view size
```

+ Swift

```swift
let imageView: UIImageView
let asset: PHAsset
let url = asset.sd_URLRepresentation
imageView.sd_setImage(with: url, context: [.imageThumbnailPixelSize : imageView.bounds.size]) // Fetch image based on image view size
```

Note: You can also use `SDWebImageContextPhotosImageRequestOptions` as shown above. But the thumbnail pixel size can be used for normal Network URL as well, which can help you to unify the logic for HTTP URL and PHAsset URL.


## Tips

1. Images from the Photos Library are already stored on the device disk, and query speed is fast enough for small resolution images, so cache storage might be unnecessary. You can use `SDWebImageContextStoreCacheType` with `SDImageCacheTypeNone` to disable cache storage, and use `SDWebImageFromLoaderOnly` to disable cache queries.
2. If you use `PHImageRequestOptionsDeliveryModeOpportunistic` (default) to load the image, PhotosKit will return a degraded thumbnail image first and again with the full pixel image. When the image is degraded, the loader completion block will set `finished = NO`. However, this will not trigger the View Category completion block, and only trigger a image refresh (like progressive loading behavior for network image using `SDWebImageProgressiveLoad`)
3. By default, we will prefer using Photos [requestImageForAsset:targetSize:contentMode:options:resultHandler:](https://developer.apple.com/documentation/photokit/phimagemanager/1616964-requestimageforasset?language=objc) API for normal images, using [requestImageDataForAsset:options:resultHandler:](https://developer.apple.com/documentation/photokit/phimagemanager/1616957-requestimagedataforasset?language=objc) for animated images like GIF asset. If you need the raw image data for further image processing, you can always pass the `SDWebImageContextPhotosRequestImageData` context option to force using the request data API instead. Note that when requesting data, the `targetSize` and `contentMode` options are ignored. If you need smaller image sizes, consider using [Image Transformer](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#image-transformer-50) feature from SDWebImage 5.0.

## Demo

If you have some issue about usage, SDWebImagePhotosPlugin provide a demo for iOS & macOS platform. To run the demo, clone the repo and run the following command.

```bash
cd Example/
pod install
open SDWebImagePhotosPlugin.xcworkspace
```

After the Xcode project is opened, click <kbd>Run</kbd> to build and run the demo.

## Author

DreamPiggy, lizhuoli1126@126.com

## License

SDWebImagePhotosPlugin is available under the MIT license. See the LICENSE file for more info.


