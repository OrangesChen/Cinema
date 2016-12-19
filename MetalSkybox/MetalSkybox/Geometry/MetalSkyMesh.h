//
//  MetalSkyMesh.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetalMesh.h"

@interface MetalSkyMesh : MetalMesh

//生成天空盒
- (instancetype)initWithDevice:(id<MTLDevice>) device;
@end
