//
//  Sphere.h
//  MetalSkybox
//
//  Created by cfq on 2017/1/3.
//  Copyright © 2017年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sphere : NSObject
@property (assign, nonatomic) int numIndices;
@property (assign, nonatomic) int numVertices;
@property (assign, nonatomic) GLfloat *vertice;
@property (assign, nonatomic) GLfloat *textcoord;
@property (assign, nonatomic) GLushort *indice;

- (void)initSphere;

@end
