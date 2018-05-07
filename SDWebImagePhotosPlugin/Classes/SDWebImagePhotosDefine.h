/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <SDWebImage/SDWebImageDefine.h>

/**
 * The scheme when identifing the URL is Photos URL
 */
FOUNDATION_EXPORT NSString * _Nonnull const SDWebImagePhotosScheme;

/**
 * Specify to use the exact size of image instead of original pixel size.
 * This is the default value if you don't specify any targetSize.
 */
FOUNDATION_EXPORT const CGSize SDWebImagePhotosLoaderPixelSize;

/**
 * Specify to use the exact size of image instead of original point size.
 * The scale is from the custom scale factor, or using the device scale factor if not provide.
 */
FOUNDATION_EXPORT const CGSize SDWebImagePhotosLoaderPointSize;

/**
 * Because Photos Framework progressBlock does not contains the file size, only the progress. See `PHAssetImageProgressHandler`.
 * This value is used to represent the `exceptedSize`, and the `receivedSize` is calculated by multiplying with the progress value.
 */
FOUNDATION_EXPORT const int64_t SDWebImagePhotosProgressExpectedSize; /* 100LL */

/**
 A PHFetchOptions instance used in the Photos Library fetch process. If you do not provide, we will use the default options to fetch the asset. (PHFetchOptions)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextPhotosFetchOptions;

/**
 A PHImageRequestOptions instance used in the Photos Library image request process. If you do not provide, we will use the default options to fetch the image (PHImageRequestOptions)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextPhotosImageRequestOptions;
