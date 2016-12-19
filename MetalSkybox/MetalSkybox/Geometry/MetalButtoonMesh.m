//
//  MetalButoonMesh.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/6.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "MetalButtonMesh.h"

static float vertices[] = {

    //   位置         纹理
    -0.5,  0.1,  1,  1, 1,
     0.5,  0.1,  1,  1, 0,
     0.5,  0.6,  1,  0, 0,
    -0.5,  0.6,  1,  0, 1,
};

static uint16_t indices[] =
{
   0,  3,  2,  2,  1,  0,
};

// 开始按钮
static float startVertices[] = {
    // 纹理
     0.32,  -0.08,  1,  1, 0,
     0.4,   -0.08,  1,  0, 0,
     0.4,    0.00,  1,  0, 1,
     0.32,   0.00,  1,  1, 1,
};

static float preVertices[] = {
   
     0.42, -0.08,  1,  1, 0,
     0.5,  -0.08,  1,  0, 0,
     0.5,   0.00,  1,  0, 1,
     0.42,  0.00,  1,  1, 1,
};

static float nextVertices[] = {
 
    0.22, -0.08,  1,  1, 0,
    0.3,  -0.08,  1,  0, 0,
    0.3,   0.00,  1,  0, 1,
    0.22,  0.00,  1,  1, 1,
};

static float progressVertices[] = {
  
     0.5, 0.05,  1,  1, 0,
    -0.5, 0.05,  1,  0, 0,
    -0.5, 0.045, 1,  0, 1,
     0.5, 0.045, 1,  1, 1,
};

static float leftLabelVertices[] = {
    
    0.65, 0.07, 1,  1, 0,
    0.55, 0.07, 1,  0, 0,
    0.55, 0.03, 1,  0, 1,
    0.65, 0.03, 1,  1, 1,

};

static float rightLabelVertices[] = {
    
     -0.65, 0.07, 1,  1, 0,
     -0.55, 0.07, 1,  0, 0,
     -0.55, 0.03, 1,  0, 1,
     -0.65, 0.03, 1,  1, 1,
};


static float spotVertices[] = {
    
    -0.2, 0.2,  0,  1, 0,
     0,   0.2,  0,  0, 0,
     0,   0.00, 0,  0, 1,
    -0.2, 0.00, 0,  1, 1,
};

static uint16_t buttonIndices[] =
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
        [_vertexBuffer setLabel:@"ScreenVertices"];
        
        _indexBuffer = [device newBufferWithBytes:indices length:6  * sizeof(uint16_t) options:0];
        [_indexBuffer setLabel:@"ScreenIndices"];
    }
    return self;
}

- (instancetype)initWithNextDevice:(id<MTLDevice>) device
{
    if (self = [super init]) {
        _vertexBuffer = [device newBufferWithBytes:nextVertices length:4 * 5 * sizeof(float) options:0];
        [_vertexBuffer setLabel:@"NextVertices"];
        _indexBuffer = [device newBufferWithBytes:buttonIndices length:6  * sizeof(uint16_t) options:0];
        [_indexBuffer setLabel:@"NextIndices"];
    }
    
    return self;
}

- (instancetype)initWithStartDevice:(id<MTLDevice>) device
{
    if (self = [super init]) {
        _vertexBuffer = [device newBufferWithBytes:startVertices length:4 * 5 * sizeof(float) options:0];
        [_vertexBuffer setLabel:@"StartVertices"];
        _indexBuffer = [device newBufferWithBytes:buttonIndices length:6  * sizeof(uint16_t) options:0];
        [_indexBuffer setLabel:@"StartIndices"];
    }
    
    return self;
}

- (instancetype)initWithPretDevice:(id<MTLDevice>) device
{
    if (self = [super init]) {
        _vertexBuffer = [device newBufferWithBytes:preVertices length:4 * 5 * sizeof(float) options:0];
        [_vertexBuffer setLabel:@"PreVertices"];
        _indexBuffer = [device newBufferWithBytes:buttonIndices length:6  * sizeof(uint16_t) options:0];
        [_indexBuffer setLabel:@"PreIndices"];
    }
    
    return self;
}

- (instancetype)initWithProgresstDevice:(id<MTLDevice>) device
{
    if (self = [super init]) {
        _vertexBuffer = [device newBufferWithBytes:progressVertices length:4 * 5 * sizeof(float) options:0];
        [_vertexBuffer setLabel:@"ProgressVertices"];
        _indexBuffer = [device newBufferWithBytes:buttonIndices length:6  * sizeof(uint16_t) options:0];
        [_indexBuffer setLabel:@"ProgressIndices"];
    }
    return self;
}

- (instancetype)initWithRightLabelDevice:(id<MTLDevice>) device
{
    if (self = [super init]) {
        _vertexBuffer = [device newBufferWithBytes:rightLabelVertices length:4 * 5 * sizeof(float) options:0];
        [_vertexBuffer setLabel:@"RightLabelVertices"];
        _indexBuffer = [device newBufferWithBytes:buttonIndices length:6  * sizeof(uint16_t) options:0];
        [_indexBuffer setLabel:@"RightLabelIndices"];
    }
    return self;
}

- (instancetype)initWithLeftLabelDevice:(id<MTLDevice>) device
{
    if (self = [super init]) {
        _vertexBuffer = [device newBufferWithBytes:leftLabelVertices length:4 * 5 * sizeof(float) options:0];
        [_vertexBuffer setLabel:@"LefttLabelVertices"];
        _indexBuffer = [device newBufferWithBytes:buttonIndices length:6  * sizeof(uint16_t) options:0];
        [_indexBuffer setLabel:@"LeftLabelIndices"];
    }
    return self;
}

- (instancetype)initWithSpotDevice:(id<MTLDevice>) device
{
    if (self = [super init]) {
        _vertexBuffer = [device newBufferWithBytes:spotVertices length:4 * 5 * sizeof(float) options:0];
        [_vertexBuffer setLabel:@"SpotVertices"];
        _indexBuffer = [device newBufferWithBytes:buttonIndices length:6  * sizeof(uint16_t) options:0];
        [_indexBuffer setLabel:@"SpotIndices"];
    }
    return self;
}

@end
