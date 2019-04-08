# SDWebImagePhotosPlugin

[![CI Status](https://img.shields.io/travis/SDWebImage/SDWebImagePhotosPlugin.svg?style=flat)](https://travis-ci.org/SDWebImage/SDWebImagePhotosPlugin)
[![Version](https://img.shields.io/cocoapods/v/SDWebImagePhotosPlugin.svg?style=flat)](https://cocoapods.org/pods/SDWebImagePhotosPlugin)
[![License](https://img.shields.io/cocoapods/l/SDWebImagePhotosPlugin.svg?style=flat)](https://cocoapods.org/pods/SDWebImagePhotosPlugin)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImagePhotosPlugin.svg?style=flat)](https://cocoapods.org/pods/SDWebImagePhotosPlugin)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/SDWebImage/SDWebImagePhotosPlugin)
[![codecov](https://codecov.io/gh/SDWebImage/SDWebImagePhotosPlugin/branch/master/graph/badge.svg)](https://codecov.io/gh/SDWebImage/SDWebImagePhotosPlugin)

## What's for
SDWebImagePhotosPlugin is a plugin for [SDWebImage](https://github.com/rs/SDWebImage/) framework, which provide the image loading support for [Photos Library](https://developer.apple.com/documentation/photokit).

By using this plugin, it allows you to use your familiar View Category method from SDWebImage, to load Photos image with `PHAsset` or `localIdentifier`.


## Requirements

+ iOS 8+
+ macOS 10.13+
+ tvOS 10+
+ Xcode 9+

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

## Usage
**Important!** To use Photos Library plugin. Firstly you need to register the photos loader to image manager.

There are two ways to register the photos loader. One for temporarily usage (when providing URL is definitely Photos URL but not HTTP URL), and another for global support (don't need any check, support both HTTP URL as well as Photos URL).

#### Use custom manager (temporarily)
You can create custom manager for temporary usage. When you use custom manager, be sure to specify `SDWebImageContextCustomManager` context option with your custom manager for View Category methods.

+ Objective-C

```objectivec
// Assign loader to custom manager
SDWebImageManager *manager = [[SDWebImageManager alloc] initWithCache:SDImageCache.sharedImageCache loader:SDWebImagePhotosLoader.sharedLoader];
```

+ Swift

```swift
// Assign loader to custom manager
let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDWebImagePhotosLoader.shared)
```

#### Use loaders manager (globally)
You can replace the default manager's loader implementation using [loaders manager](https://github.com/rs/SDWebImage/wiki/Advanced-Usage#loaders-manager) to support both HTTP && Photos URL globally. Put these code just at the application launch time (or time just before `SDWebImageManager.sharedManager` initialized).

+ Objective-C

```objectivec
// Supports HTTP URL as well as Photos URL globally
SDImageLoadersManager.sharedManager.loaders = @[SDWebImageDownloader.sharedDownloader, SDWebImagePhotosLoader.sharedLoader];
// Replace default manager's loader implementation
SDWebImageManager.defaultImageLoader = SDImageLoadersManager.sharedManager;
```

+ Swift

```swift
// Supports HTTP URL as well as Photos URL globally
SDImageLoadersManager.shared.loaders = [SDWebImageDownloader.shared, SDWebImagePhotosLoader.shared]
// Replace default manager's loader implementation
SDWebImageManager.defaultImageLoader = SDImageLoadersManager.shared
```

#### Load Images
To start load Photos Library image, use the `NSURL+SDWebImagePhotosPlugin` to create a Photos URL and call View Category method.

+ Objective-C

```objectivec
// Create with `PHAsset`
PHAsset *asset;
NSURL *photosURL = [NSURL sd_URLWithAsset:asset];
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
let photosURL = NSURL.sd_URL(with: asset)
// Create with `localIdentifier`
let identifier: String
let potosURL = NSURL.sd_URL(withAssetLocalIdentifier: identifier)

// Load image (assume using custom manager)
imageView.sd_setImage(with: photosURL, placeholderImage: nil, context: [.customManager: manager])
```

#### Animated Images
SDWebImagePhotosPlugin supports GIF images stored in Photos Library as well. Just use the same API as normal images to query the asset. We will query the image data and decode the animated images (compatible with `UIImageView` as well as [SDAnimatedImageView](https://github.com/rs/SDWebImage/wiki/Advanced-Usage#animated-image-50))

#### Fetch/Request Options
To specify options like `PHFetchOptions` or `PHImageRequestOptions` for Photos Library. Either to change the correspond properties in loader, or provide a context options for each image request.

+ Objective-C

```objectivec
// loader-level options
// ignore iCloud Shared Album (`localIdentifier` Photos URL only)
PHFetchOptions *fetchOptions = [PHFetchOptions new];
fetchOptions.predicate = [NSPredicate predicateWithFormat:@"sourceType != %d", PHAssetSourceTypeCloudShared];
SDWebImagePhotosLoader.sharedLoader.fetchOptions = fetchOptions;

// request-level options
// allows iCloud Photos Library
PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
requestOptions.networkAccessAllowed = YES;
[imageView sd_setImageWithURL:photosURL placeholderImage:nil context:@{SDWebImageContextPhotosImageRequestOptions: requestOptions, SDWebImageContextCustomManager: manager}];
```

+ Swift

```swift
// loader-level options
// ignore iCloud Shared Album (`localIdentifier` Photos URL only)
let fetchOptions = PHFetchOptions()
fetchOptions.predicate = NSPredicate(format: "sourceType != %d", PHAssetSourceType.typeCloudShared.rawValue)
SDWebImagePhotosLoader.shared.fetchOptions = fetchOptions

// request-level options
// allows iCloud Photos Library
let requestOptions = PHImageRequestOptions()
requestOptions.networkAccessAllowed = true
imageView.sd_setImage(with: photosURL, placeholderImage: nil, context:[.photosImageRequestOptions: requestOptions, .customManager: manager])
```

## Tips

1. Since Photos Library image is already stored on the device disk. And query speed is fast enough for small resolution image. You can use `SDWebImageContextStoreCacheType` with `SDImageCacheTypeNone` to disable cache storage. And use `SDWebImageFromLoaderOnly` to disable cache query.
2. If you use `PHImageRequestOptionsDeliveryModeOpportunistic` (by default) to load the image, PhotosKit will return a degraded thumb image firstly and again with the full pixel image. When the image is degraded, the loader completion block will set `finished = NO`. But this will not trigger the View Category completion block, only trigger a image refresh (like progressive loading behavior for network image using `SDWebImageProgressiveLoad`)
3. By default, we will prefer using Photos [requestImageForAsset:targetSize:contentMode:options:resultHandler:](https://developer.apple.com/documentation/photokit/phimagemanager/1616964-requestimageforasset?language=objc) API for normal images, using [requestImageDataForAsset:options:resultHandler:](https://developer.apple.com/documentation/photokit/phimagemanager/1616957-requestimagedataforasset?language=objc) for animated images like GIF asset. If you need the raw image data for further image processing, you can always pass `SDWebImageContextPhotosRequestImageData` context option to force using the request data API instead. Note when request data, the `targetSize` and `contentMode` options are ignored. If you need smaller image size, consider using [Image Transformer](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#image-transformer-50) feature from SDWebImage 5.0

## Warning

The Photos taken by iPhone's Camera, its pixel size may be really large (4K+). So if you want to load large Photos Library assets for rendering, you'd better specify target size with a limited size (like you render imageView's size).

By default, we query the target size matching the original image pixel size (See: `SDWebImagePhotosLoaderPixelSize`), which may consume much memory on iOS device.

## Demo

If you have some issue about usage, SDWebImagePhotosPlugin provide a demo for iOS && macOS platform. To run the demo, clone the repo and run the following command.

```bash
cd Example/
pod install
open SDWebImagePhotosPlugin.xcworkspace
```

After the Xcode project was opened, click `Run` to build and run the demo.

## Author

DreamPiggy, lizhuoli1126@126.com

## License

SDWebImagePhotosPlugin is available under the MIT license. See the LICENSE file for more info.


