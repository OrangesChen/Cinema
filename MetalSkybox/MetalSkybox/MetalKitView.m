//
//  MetalKitView.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "MetalKitView.h"
#import "modelIORender.h"

@interface MetalKitView() {
    modelIORender *render;
}


@end

@implementation MetalKitView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self =  [super initWithCoder:coder];
    if (self) {
        render = [[modelIORender alloc] init];
        self.device = MTLCreateSystemDefaultDevice();
        [render init:self device:self.device];
        self.delegate = render;
    }
    
    return self;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

/*!
 @method drawInMTKView:
 @abstract Called on the delegate when it is asked to render into the view
 @discussion Called on the delegate when it is asked to render into the view
 */
- (void)drawInMTKView:(nonnull MTKView *)view {
    [render drawInMTKView:view];
}

@end
