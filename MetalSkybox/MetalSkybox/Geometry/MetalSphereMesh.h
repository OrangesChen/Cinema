//
//  MetalSphereMesh.h
//  MetalSkybox
//
//  Created by cfq on 2017/1/3.
//  Copyright © 2017年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MetalMesh;

@interface MetalSphereMesh : MetalMesh
- (instancetype)initWithDevice:(id<MTLDevice>) device;
@end
