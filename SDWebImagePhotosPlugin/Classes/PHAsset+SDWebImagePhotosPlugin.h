/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Photos/Photos.h>

@interface PHAsset (SDWebImagePhotosPlugin)

/// The convenience way to retrive the URL representation of PHAsset. The same as `+[NSURL sd_URLWithAsset:]`.
/// @note This API always create and return new object in Objective-C/struct in Swift of URL. (which does not store the URL inside PHAssets, to avoid retain cycle)
@property (nonatomic, strong, readonly, nonnull) NSURL *sd_URLRepresentation;

@end
