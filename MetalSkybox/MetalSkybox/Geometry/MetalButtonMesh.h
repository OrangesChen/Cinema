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

// 屏幕
- (instancetype)initWithDevice:(id<MTLDevice>) device;
// 开始按钮
- (instancetype)initWithStartDevice:(id<MTLDevice>) device;
// 下一个
- (instancetype)initWithNextDevice:(id<MTLDevice>) device;
// 上一个
- (instancetype)initWithPretDevice:(id<MTLDevice>) device;
// 进度条
- (instancetype)initWithProgresstDevice:(id<MTLDevice>) device;
// 时间label
- (instancetype)initWithRightLabelDevice:(id<MTLDevice>) device;
- (instancetype)initWithLeftLabelDevice:(id<MTLDevice>) device;
// 焦点
- (instancetype)initWithSpotDevice:(id<MTLDevice>) device;

@end
