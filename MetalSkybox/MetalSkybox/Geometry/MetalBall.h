//
//  MetalBall.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/6.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ModelIO/ModelIO.h>
#import "MetalMesh.h"
#import <MetalKit/MetalKit.h>
@import Metal;

@interface MetalBall : MetalMesh {
    vector_float3 vector;
    MTKMesh *mesh;
    MTKSubmesh *submesh;
}

@property (nonatomic, assign) int indexCount;
@property (nonatomic, assign) MTLIndexType indexType;
@property (nonatomic, assign) MTLPrimitiveType primitiveType;
@property (nonatomic, strong) MTLVertexDescriptor *metalVertexDescriptor;


- (void)initWithDevice:(id<MTLDevice>)device xExtent:(float)xExtent yExtent:(float)yExtent zExtent:(float)zExtent uTesselation:(int)uTesselation vTesselation:(int)vTesselation;

@end
