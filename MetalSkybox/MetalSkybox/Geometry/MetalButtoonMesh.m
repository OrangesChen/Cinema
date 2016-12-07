//
//  MetalButoonMesh.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/6.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "MetalButtonMesh.h"

static float vertices[] = {

//    -0.5, -0.5,  0.5,  1.0, 0.0, 1.0, 0.5,
//    0.5, -0.5,  0.5,  1.0, 0.0, 1.0, 0.5,
//    0.5,  0.5,  0.5,  1.0, 0.0, 1.0, 0.5,
//    -0.5,  0.5,  0.5,  1.0, 0.0, 1.0, 0.5,
    // +Z 颜色
//    -0.9,   -0.2,  1,  0.0, 0.0, 0.0, 0.9,
//     0.9,   -0.2,  1,  0.0, 0.0, 0.0, 0.9,
//     0.95,   0.8,  1,  0.0, 0.0, 0.0, 0.9,
//    -0.9,    0.8,   1,  0.0, 0.0, 0.0, 0.9,
    
    // 纹理
    -0.5,  0.1, 1,  1, 1,
    0.5,   0.1,  1,  1, 0,
    0.5,   0.6,  1,  0,    0,
    -0.5,  0.6, 1,  0, 1,
};

static uint16_t indices[] =
{
   0,  3,  2,  2,  1,  0,
//    4,  7,  6,  6,  5,  4,
//    8, 11, 10, 10,  9,  8,
//    12, 15, 14, 14, 13, 12,
//    16, 19, 18, 18, 17, 16,
//    20, 23, 22, 22, 21, 20,
};

// 开始按钮
static float startVertices[] = {
    // 纹理
     0.6,   -0.1,  1,  1, 0,
     0.7,  -0.1,  1,  0, 0,
     0.7,   0.0,  1,  0, 1,
     0.6,   0.0,  1,  1, 1,
};

static uint16_t startIndices[] =
{
    0,  3,  2,  2,  1,  0,
};

@implementation MetalButtonMesh

@synthesize vertexBuffer = _vertexBuffer;
@synthesize indexBuffer = _indexBuffer;
- (instancetype)initWithDevice:(id<MTLDevice>) device
{
    if ((self = [super init]))
    {
        _vertexBuffer = [device newBufferWithBytes:vertices length:4 * 5 * sizeof(float) options:0];
        _indexBuffer = [device newBufferWithBytes:indices length:6  * sizeof(uint16_t) options:0];
    }
    return self;
}

- (instancetype)initWithStartDevice:(id<MTLDevice>) device
{
    if (self = [super init]) {
        _vertexBuffer = [device newBufferWithBytes:startVertices length:4 * 5 * sizeof(float) options:0];
        _indexBuffer = [device newBufferWithBytes:startIndices length:6  * sizeof(uint16_t) options:0];
    }
    
    return self;
}

@end
