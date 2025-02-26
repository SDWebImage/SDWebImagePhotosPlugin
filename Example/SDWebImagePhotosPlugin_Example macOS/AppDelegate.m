//
//  AppDelegate.m
//  SDWebImagePhotosPlugin_Example macOS
//
//  Created by lizhuoli on 2018/7/19.
//  Copyright © 2018年 DreamPiggy. All rights reserved.
//

#import "AppDelegate.h"
#import <SDWebImage/SDWebImage.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    if (@available(macOS 11.0, *)) {
        [SDImageCodersManager.sharedManager addCoder:SDImageAWebPCoder.sharedCoder];
    }
    [SDImageCodersManager.sharedManager addCoder:SDImageHEICCoder.sharedCoder];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)reloadButtonDidTap:(NSMenuItem *)sender {
    // Menu item target-action
}

@end
