//
//  MetalView.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "MetalView.h"

@implementation MetalView

+ (Class)layerClass {
    return [CAMetalLayer class];
}

- (CAMetalLayer *)metalLayer {
    return (CAMetalLayer *)self.layer;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat scale = [UIScreen mainScreen].scale;
    if (self.window) {
        scale = self.window.screen.scale;
    }
    
    CGSize drawableSize = self.bounds.size;
    drawableSize.width *= scale;
    drawableSize.height *= scale;

    self.metalLayer.drawableSize = drawableSize;
    // 这个属性必须设置，否则渲染出的视频颜色会蒙上白色背景
    self.backgroundColor = nil;
}

@end
