//
//  MetalSkyMesh.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "MetalSkyMesh.h"

static float vertices[] =
{
    // + Y
    -0.5,  0.5,  0.5, 1.0,  0.0, -1.0,  0.0, 0.0,
     0.5,  0.5,  0.5, 1.0,  0.0, -1.0,  0.0, 0.0,
     0.5,  0.5, -0.5, 1.0,  0.0, -1.0,  0.0, 0.0,
    -0.5,  0.5, -0.5, 1.0,  0.0, -1.0,  0.0, 0.0,
    // -Y
    -0.5, -0.5, -0.5, 1.0,  0.0,  1.0,  0.0, 0.0,
     0.5, -0.5, -0.5, 1.0,  0.0,  1.0,  0.0, 0.0,
     0.5, -0.5,  0.5, 1.0,  0.0,  1.0,  0.0, 0.0,
    -0.5, -0.5,  0.5, 1.0,  0.0,  1.0,  0.0, 0.0,
    // +Z
    -0.5, -0.5,  0.5, 1.0,  0.0,  0.0, -1.0, 0.0,
     0.5, -0.5,  0.5, 1.0,  0.0,  0.0, -1.0, 0.0,
     0.5,  0.5,  0.5, 1.0,  0.0,  0.0, -1.0, 0.0,
    -0.5,  0.5,  0.5, 1.0,  0.0,  0.0, -1.0, 0.0,
    // -Z
     0.5, -0.5, -0.5, 1.0,  0.0,  0.0,  1.0, 0.0,
    -0.5, -0.5, -0.5, 1.0,  0.0,  0.0,  1.0, 0.0,
    -0.5,  0.5, -0.5, 1.0,  0.0,  0.0,  1.0, 0.0,
     0.5,  0.5, -0.5, 1.0,  0.0,  0.0,  1.0, 0.0,
    // -X
    -0.5, -0.5, -0.5, 1.0,  1.0,  0.0,  0.0, 0.0,
    -0.5, -0.5,  0.5, 1.0,  1.0,  0.0,  0.0, 0.0,
    -0.5,  0.5,  0.5, 1.0,  1.0,  0.0,  0.0, 0.0,
    -0.5,  0.5, -0.5, 1.0,  1.0,  0.0,  0.0, 0.0,
    // +X
     0.5, -0.5,  0.5, 1.0, -1.0,  0.0,  0.0, 0.0,
     0.5, -0.5, -0.5, 1.0, -1.0,  0.0,  0.0, 0.0,
     0.5,  0.5, -0.5, 1.0, -1.0,  0.0,  0.0, 0.0,
     0.5,  0.5,  0.5, 1.0, -1.0,  0.0,  0.0, 0.0,
};

static uint16_t indices[] =
{
    0,  3,  2,  2,  1,  0,
    4,  7,  6,  6,  5,  4,
    8, 11, 10, 10,  9,  8,
    12, 15, 14, 14, 13, 12,
    16, 19, 18, 18, 17, 16,
    20, 23, 22, 22, 21, 20,
};

@implementation MetalSkyMesh
@synthesize vertexBuffer=_vertexBuffer;
@synthesize indexBuffer=_indexBuffer;

- (instancetype)initWithDevice:(id<MTLDevice>) device
{
    if ((self = [super init]))
    {
        _vertexBuffer = [device newBufferWithBytes:vertices length:24 * 8 * sizeof(float) options:0];
        [_vertexBuffer setLabel:@"SkyVertices"];
        _indexBuffer = [device newBufferWithBytes:indices length:36 * sizeof(uint16_t) options:0];
        [_indexBuffer setLabel:@"SkyIndices"];
    }
    return self;
}
@end



