/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Photos/Photos.h>

@interface PHAsset (SDWebImagePhotosPlugin)

/// The convenience way to retrive the URL representation of PHAssert. The same as `+[NSURL sd_URLWithAsset:]`
@property (nonatomic, strong, readonly, nonnull) NSURL *sd_URLRepresentation;

@end
