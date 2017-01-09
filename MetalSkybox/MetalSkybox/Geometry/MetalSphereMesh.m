//
//  MetalSphereMesh.m
//  MetalSkybox
//
//  Created by cfq on 2017/1/3.
//  Copyright © 2017年 Dlodlo. All rights reserved.
//

#import "MetalSphereMesh.h"
#import "Sphere.h"

@implementation MetalSphereMesh
@synthesize vertexBuffer = _vertexBuffer;
@synthesize indexBuffer = _indexBuffer;

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    if ((self = [super init]))
    {
        Sphere *sphereMesh = [[Sphere alloc] init];
        [sphereMesh initSphere];
        _vertexBuffer = [device newBufferWithBytes:sphereMesh.vertice length:sphereMesh.numVertices * 3 * sizeof(CGFloat) options:0];
        [_vertexBuffer setLabel:@"SphereVertices"];
        
        _indexBuffer = [device newBufferWithBytes:sphereMesh.indice length:sphereMesh.numIndices*sizeof(GLushort) options:0];
        [_indexBuffer setLabel:@"SphereIndices"];
    }
    return self;
}

@end
