/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImagePhotosDefine.h"

NSString * _Nonnull const SDWebImagePhotosScheme = @"photos";
const CGSize SDWebImagePhotosLoaderPixelSize = {.width = 0, .height = 0};
const CGSize SDWebImagePhotosLoaderPointSize = {.width = -1, .height = -1};
const int64_t SDWebImagePhotosProgressExpectedSize = 100LL;

SDWebImageContextOption _Nonnull const SDWebImageContextPhotosFetchOptions = @"photosFetchOptions";
SDWebImageContextOption _Nonnull const SDWebImageContextPhotosImageRequestOptions = @"photosImageRequestOptions";
SDWebImageContextOption _Nonnull const SDWebImageContextPhotosRequestImageData = @"photosRequestImageData";
