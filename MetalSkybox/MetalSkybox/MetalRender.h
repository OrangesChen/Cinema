//
//  MetalRender.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetalRender : NSObject
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) CAMetalLayer *layer;
@property (nonatomic, assign) BOOL useRefractionMaterial;

// 场景位置
@property  (nonatomic, assign) matrix_float4x4 sceneOrientation;

- (instancetype)initWithLayer: (CAMetalLayer *)layer;
// 绘图
- (void)draw;

@end
