//
//  TestCollectionView.m
//  SDWebImagePhotosPlugin_Example macOS
//
//  Created by lizhuoli on 2018/7/19.
//  Copyright © 2018年 DreamPiggy. All rights reserved.
//

#import "TestCollectionView.h"

@implementation TestCollectionView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = YES;
    }
    return self;
}

@end
