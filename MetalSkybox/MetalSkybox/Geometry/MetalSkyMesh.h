//
//  MetalSkyMesh.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetalMesh.h"
@import Metal;

@interface MetalSkyMesh : MetalMesh
- (instancetype)initWithDevice:(id<MTLDevice>) device;
@end
