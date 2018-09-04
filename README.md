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

## Usage
To support Photos Library plugin. Firstly add the photos loader to image manager. You can add to the default manager using [loaders manager](https://github.com/rs/SDWebImage/wiki/Advanced-Usage#loaders-manager), or create custom manager for usage.

+ Objective-C

```objectivec
// Assign loader to manager
SDWebImageManager *manager = [[SDWebImageManager alloc] initWithCache:SDImageCache.sharedCache loader:SDWebImagePhotosLoader.sharedLoader];
```

+ Swift

```swift
// Assign loader to manager
let manager = SDWebImageManager(cache: SDImageCache.shared, loader: SDWebImagePhotosLoader.shared)
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
SDWebImagePhotosLoader.sharedLoader.fetchOptions = fetchOptions;
// request-level control
[imageView sd_setImageWithURL:photosURL placeholderImage:nil context:@{SDWebImageContextPhotosImageRequestOptions: requestOptions, SDWebImageCustomManager: manager}];
```

+ Swift

```swift
// loader-level control
SDWebImagePhotosLoader.shared.fetchOptions = fetchOptions
// request-level control
imageView.sd_setImage(with: photosURL, placeholderImage: nil, context:[.requestOptions: requestOptions, .customManager: manager])
```

## Tips

1. Since Photos Library image is already stored on the device disk. And query speed is fast enough for small resolution image. You can use `SDWebImageContextStoreCacheType` with `SDImageCacheTypeNone` to disable cache storage. And use `SDWebImageFromLoaderOnly` to disable cache query.
2. If you use `PHImageRequestOptionsDeliveryModeOpportunistic` to load the image, PhotosKit will return a degraded thumb image firstly and again with the full pixel image. When the image is degraded, the loader completion block will set `finished = NO`. But this will not trigger the View Category completion block, only trigger a image refresh (like progressive loading behavior for network image using `SDWebImageProgressiveLoad`)

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

Note that because the dependency SDWebImage currently is in beta. You should use `Carthage v0.30.1` or above to support beta [sem-version](https://semver.org/).

```
github "SDWebImage/SDWebImagePhotosPlugin"
```

## Author

DreamPiggy, lizhuoli1126@126.com

## License

SDWebImagePhotosPlugin is available under the MIT license. See the LICENSE file for more info.


