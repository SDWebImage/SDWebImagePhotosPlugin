/*
 * This file is part of the SDWebImagePhotosPlugin package.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SystemAlert.h"
#import "dlfcn.h"

@interface SystemAlert (ForMethodCompletionOnly)
+ (id)localTarget;
- (id)frontMostApp;
- (id)alert;
- (id)buttons;
- (void)tap;
@end

@implementation SystemAlert

+ (void)load {
    dlopen([@"/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation" fileSystemRepresentation], RTLD_LOCAL);
}

+ (NSArray *)currentButtons {
    id localTarget = [NSClassFromString(@"UIATarget") localTarget];
    id app = [localTarget frontMostApp];
    id alert = [app alert];
    id buttons = [alert buttons];
    if (![buttons isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return buttons;
}

+ (void)tapLeftButton {
    id button = [self currentButtons].firstObject;
    [button tap];
}

+ (void)tapRightButton {
    id button = [self currentButtons].lastObject;
    [button tap];
}

@end
