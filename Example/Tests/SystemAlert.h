/*
 * This file is part of the SDWebImagePhotosPlugin package.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>

// Automation API to force tap current system alert
@interface SystemAlert : NSObject
+ (void)tapLeftButton;
+ (void)tapRightButton;
@end
