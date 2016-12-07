//
//  modelIORender.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/7.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MetalKit;

@interface modelIORender : NSObject<MTKViewDelegate>
- (void)init:(MTKView *)view device:(id<MTLDevice>)device;
@property (nonatomic, assign) id<MTKViewDelegate> delegate;
@end
