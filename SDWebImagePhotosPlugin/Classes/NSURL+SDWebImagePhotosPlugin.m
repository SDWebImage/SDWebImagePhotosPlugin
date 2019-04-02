/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSURL+SDWebImagePhotosPlugin.h"
#import "SDWebImagePhotosDefine.h"
#import <Photos/Photos.h>
#import <objc/runtime.h>

static NSString * _Nonnull const SDWebImagePhotosURLHostAsset = @"asset";

@implementation NSURL (SDWebImagePhotosPlugin)

- (BOOL)sd_isPhotosURL {
    return [self.scheme isEqualToString:SDWebImagePhotosScheme];
}

- (NSString *)sd_assetLocalIdentifier {
    if (!self.sd_isPhotosURL) {
        return nil;
    }
    PHAsset *asset = self.sd_asset;
    if (asset) {
        return asset.localIdentifier;
    }
    NSString *host = self.host;
    if (![SDWebImagePhotosURLHostAsset isEqualToString:host]) {
        return nil;
    }
    NSString *path = self.path;
    if (path.length <= 1) {
        return nil;
    }
    
    return [[path substringFromIndex:1] stringByRemovingPercentEncoding];
}

- (PHAsset *)sd_asset {
    return objc_getAssociatedObject(self, @selector(sd_asset));
}

- (void)setSd_asset:(PHAsset * _Nullable)sd_asset {
    objc_setAssociatedObject(self, @selector(sd_asset), sd_asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (instancetype)sd_URLWithAssetLocalIdentifier:(NSString *)identifier {
    if (!identifier) {
        return nil;
    }
    // photos://asset/123
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:[NSString stringWithFormat:@"%@://%@/", SDWebImagePhotosScheme, SDWebImagePhotosURLHostAsset]];
    NSString *encodedPath = [identifier stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    components.path = [components.path stringByAppendingString:encodedPath];
    
    return components.URL;
}

+ (instancetype)sd_URLWithAsset:(PHAsset *)asset {
    if (![asset isKindOfClass:[PHAsset class]]) {
        return nil;
    }
    NSString *localIdentifier = asset.localIdentifier;
    if (!localIdentifier) {
        return nil;
    }
    
    NSURL *url = [self sd_URLWithAssetLocalIdentifier:localIdentifier];
    url.sd_asset = asset;
    
    return url;
}

@end
