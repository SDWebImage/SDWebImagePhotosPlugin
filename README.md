# SDWebImagePhotosPlugin

[![CI Status](https://img.shields.io/travis/SDWebImage/SDWebImagePhotosPlugin.svg?style=flat)](https://travis-ci.org/SDWebImage/SDWebImagePhotosPlugin)
[![Version](https://img.shields.io/cocoapods/v/SDWebImagePhotosPlugin.svg?style=flat)](https://cocoapods.org/pods/SDWebImagePhotosPlugin)
[![License](https://img.shields.io/cocoapods/l/SDWebImagePhotosPlugin.svg?style=flat)](https://cocoapods.org/pods/SDWebImagePhotosPlugin)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImagePhotosPlugin.svg?style=flat)](https://cocoapods.org/pods/SDWebImagePhotosPlugin)

## What's for
SDWebImagePhotosPlugin is a plugin for [SDWebImage](https://github.com/rs/SDWebImage/) framework, which provide the image loading support for [Photos Library](https://developer.apple.com/documentation/photokit).

By using this plugin, it allows you to use your familiar View Category method from SDWebImage, to load Photos image with `PHAsset` or `localIdentifier`.

## Usage
To support Photos Library plugin. Firstly add the photos loader to image manager. You can add to the default manager using [loaders manager](https://github.com/rs/SDWebImage/wiki/Advanced-Usage#loaders-manager), or create custom manager for usage.

+ Objective-C

```objectivec
// Assign loader to manager
SDWebImageManager *manager = [[SDWebImageManager alloc] initWithCache:SDImageCache.sharedCache loader:SDWebImagePhotoLoader.sharedLoader];
```

+ Swift

```swift
// Assign loader to manager
let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDWebImagePhotoLoader.shared)
```

To start load Photos Library image, use the `NSURL+SDWebImagePhotosPlugin` to create a Photos URL and call View Category method.

+ Objective-C

```objectivec
// Create with `PHAsset`
PHAsset *asset;
NSURL *photosURL = [NSURL sd_URLWithAsset:asset];
// Create with `localIdentifier`
NSString *identifier;
NSURL *potosURL = [NSURL sd_URLWithAssetLocalIdentifier:identifier];

// Load image
[imageView sd_setImageWithURL:photosURL placeholderImage:nil context:@{SDWebImageCustomManager: manager}];
```

+ Swift

```swift
// Create with `PHAsset`
let asset: PHAsset
let photosURL = NSURL.sd_URL(with: asset)
// Create with `localIdentifier`
let identifier: String
let potosURL = NSURL.sd_URL(withAssetLocalIdentifier: identifier)

// Load image
imageView.sd_setImage(with: photosURL, placeholderImage: nil, context: [.customManager: manager])
```

To specify custom options like `PHFetchOptions` or `PHImageRequestOptions`. Either to change the property in loader, or provide a context options for each Photos Library image request.

+ Objective-C

```objectivec
// loader-level control
SDWebImagePhotoLoader.sharedLoader.fetchOptions = fetchOptions;
// request-level control
[imageView sd_setImageWithURL:photosURL placeholderImage:nil context:@{SDWebImageContextPhotosImageRequestOptions: requestOptions, SDWebImageCustomManager: manager}];
```

+ Swift

```swift
// loader-level control
SDWebImagePhotoLoader.shared.fetchOptions = fetchOptions
// request-level control
imageView.sd_setImage(with: photosURL, placeholderImage: nil, context:[.requestOptions: requestOptions, .customManager: manager])
```

## Tips

1. Since Photos Library image is already stored on the device disk. And query speed is fast enough for small resolution image. You can use `SDWebImageContextStoreCacheType` with `SDImageCacheTypeNone` to disable cache storage. And use `SDWebImageFromLoaderOnly` to disable cache query.
2. If you use `PHImageRequestOptionsDeliveryModeOpportunistic` to load the image, PhotosKit will return a degraded thumb image firstly and again with the full pixel image. When the image is degraded, the loader completion block will set `finished = NO`. But this will not trigger the View Category completion block, only trigger a image refresh (like progressive loading behavior for network image using `SDWebImageProgressiveLoad`)

## Requirements

+ iOS 8+
+ macOS 10.10+
+ tvOS 9+
+ Xcode 9+

## Author

DreamPiggy, lizhuoli1126@126.com

## License

SDWebImagePhotosPlugin is available under the MIT license. See the LICENSE file for more info.


