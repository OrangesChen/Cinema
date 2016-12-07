//
//  MetalBall.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/6.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "MetalBall.h"

@import simd;

@interface MetalBall()

@end

@implementation MetalBall
@synthesize vertexBuffer = _vertexBuffer;
@synthesize indexBuffer = _indexBuffer;

- (MDLVertexDescriptor *) initializationHelper:(id<MTLDevice>)device {
    _metalVertexDescriptor = [[MTLVertexDescriptor alloc] init];
    // xyz 位置坐标
    _metalVertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
    _metalVertexDescriptor.attributes[0].offset = 0;
    _metalVertexDescriptor.attributes[0].bufferIndex = 0;
    // n 法线
    _metalVertexDescriptor.attributes[1].format = MTLVertexFormatFloat3;
    _metalVertexDescriptor.attributes[1].offset = 12;
    _metalVertexDescriptor.attributes[1].bufferIndex = 0;
    // st 纹理
    _metalVertexDescriptor.attributes[2].format = MTLVertexFormatHalf2;
    _metalVertexDescriptor.attributes[2].offset = 24;
    _metalVertexDescriptor.attributes[2].bufferIndex = 0;
    
    // Single interleaved buffer
    // 缓冲区中两个顶点属性数据之间的距离
    _metalVertexDescriptor.layouts[0].stride = 28;
    // 顶点及其属性呈现给顶点函数的间隔， 默认值为1; 如果stepRate等于1，则为每个实例提取新的属性数据; 如果stepRate等于2，则为每两个实例提取新的属性数据
    _metalVertexDescriptor.layouts[0].stepRate = 1;
    // stepRate值与stepFunction属性一起确定函数获取新属性数据的频率
    _metalVertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    
    // Model I/O vertex descriptor
    // 返回部分转换的模型I/O顶点描述符
    MDLVertexDescriptor *modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(_metalVertexDescriptor);
    modelIOVertexDescriptor.attributes[0].name = MDLVertexAttributePosition;
    modelIOVertexDescriptor.attributes[1].name = MDLVertexAttributeNormal;
    modelIOVertexDescriptor.attributes[2].name = MDLVertexAttributeTextureCoordinate;
    
    return modelIOVertexDescriptor;

}

- (void)initWithDevice:(id<MTLDevice>)device xExtent:(float)xExtent yExtent:(float)yExtent zExtent:(float)zExtent uTesselation:(int)uTesselation vTesselation:(int)vTesselation {
    
    vector.x = xExtent;
    vector.y = yExtent;
    vector.z = zExtent;
    MDLMesh *mdlMesh = [MDLMesh newEllipsoidWithRadii:vector radialSegments:uTesselation verticalSegments:vTesselation geometryType:MDLGeometryTypeTriangles inwardNormals:NO hemisphere:NO allocator:[[MTKMeshBufferAllocator alloc] initWithDevice: device]];
    mdlMesh.vertexDescriptor = [self initializationHelper:device];
    mesh = [[MTKMesh alloc] initWithMesh:mdlMesh device:device error:nil];
    submesh = mesh.submeshes[0];
    _vertexBuffer = mesh.vertexBuffers[0].buffer;
    _indexBuffer = submesh.indexBuffer.buffer;
    _indexCount = (int)submesh.indexCount;
    _indexType = submesh.indexType;
    _primitiveType = submesh.primitiveType;
}

@end
