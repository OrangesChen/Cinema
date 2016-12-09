//
//  MetalTextureLoader.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <UIKit/UIKit.h>

@interface MetalTextureLoader : NSObject

// 2D纹理贴图
+ (id<MTLTexture>)texture2DWithImageNamed:(NSString *)imageName device:(id<MTLDevice>)device;
+ (id<MTLTexture>)texture2DWithImage:(UIImage *)image device:(id<MTLDevice>)device;

+ (id<MTLTexture>)textureCubeWithImagesNamed:(NSArray *)imageNameArray device:(id<MTLDevice>)device;

@end
