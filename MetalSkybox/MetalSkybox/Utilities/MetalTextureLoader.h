//
//  MetalTextureLoader.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MetalTextureLoader : NSObject

// 2D纹理贴图
+ (id<MTLTexture>)texture2DWithImageNamed:(NSString *)imageName device:(id<MTLDevice>)device;
/**
 *  传入图片，生成2D纹理贴图
 *
 *  @param image  图片
 *  @param device 设备
 *
 *  @return 纹理贴图
 */
+ (id<MTLTexture>)texture2DWithImage:(UIImage *)image device:(id<MTLDevice>)device;

/**
 *  输入包含6张图片名称的数组生成立方体纹理
 *
 *  @param imageNameArray 数组
 *  @param device         设备
 *
 *  @return 立方体纹理贴图
 */
+ (id<MTLTexture>)textureCubeWithImagesNamed:(NSArray *)imageNameArray device:(id<MTLDevice>)device;

+ (id<MTLTexture>)texture2DWithStringToImage:(NSString *)string device:(id<MTLDevice>)device withFont:(CGFloat)font;

@end
