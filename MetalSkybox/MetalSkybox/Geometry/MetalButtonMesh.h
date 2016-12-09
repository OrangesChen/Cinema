//
//  MetalButoonMesh.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/6.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetalMesh.h"

@interface MetalButtonMesh : MetalMesh

- (instancetype)initWithDevice:(id<MTLDevice>) device;
- (instancetype)initWithStartDevice:(id<MTLDevice>) device;
- (instancetype)initWithNextDevice:(id<MTLDevice>) device;
- (instancetype)initWithPretDevice:(id<MTLDevice>) device;
- (instancetype)initWithProgresstDevice:(id<MTLDevice>) device;
- (instancetype)initWithRightLabelDevice:(id<MTLDevice>) device;
- (instancetype)initWithLeftLabelDevice:(id<MTLDevice>) device;
- (instancetype)initWithSpotDevice:(id<MTLDevice>) device;

@end
