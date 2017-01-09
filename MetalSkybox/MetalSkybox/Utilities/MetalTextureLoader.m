//
//  MetalTextureLoader.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "MetalTextureLoader.h"

@implementation MetalTextureLoader

// 获取图片的数据，通过 CGImage在CGContex 上draw的方法来取得图像
+ (uint8_t *)dataForImage:(UIImage *)image {
    CGImageRef imageRef = [image CGImage];
    const NSUInteger width = CGImageGetWidth(imageRef);
    const NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *rawData = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t));
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * width;
    const NSUInteger bitsPerComponent = 8;
    CGContextRef contex = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(contex, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(contex);
    return rawData;
}

// 2D纹理贴图
+ (id<MTLTexture>)texture2DWithImageNamed:(NSString *)imageName device:(id<MTLDevice>)device
{
    UIImage *image = [UIImage imageNamed:imageName];
    CGSize imageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * imageSize.width;
    uint8_t *imageData = [self dataForImage:image];
    
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                                 width:imageSize.width
                                                                                                height:imageSize.height
                                                                                             mipmapped:NO];
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];
    
    MTLRegion region = MTLRegionMake2D(0, 0, imageSize.width, imageSize.height);
    [texture replaceRegion:region mipmapLevel:0 withBytes:imageData bytesPerRow:bytesPerRow];
    
    free(imageData);
    return texture;
}


+ (id<MTLTexture>)texture2DWithImage:(UIImage *)image device:(id<MTLDevice>)device
{
    CGSize imageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * imageSize.width;
    uint8_t *imageData = [self dataForImage:image];
    
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                                 width:imageSize.width
                                                                                                height:imageSize.height
                                                                                             mipmapped:NO];
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];
    
    MTLRegion region = MTLRegionMake2D(0, 0, imageSize.width, imageSize.height);
    [texture replaceRegion:region mipmapLevel:0 withBytes:imageData bytesPerRow:bytesPerRow];
    
    free(imageData);
    return texture;
}

+ (id<MTLTexture>)texture2DWithStringToImage:(NSString *)string device:(id<MTLDevice>)device withFont:(CGFloat)font
{
    UIImage *image = [StringToImage imageFromString:string withFont:font];
    CGSize imageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * imageSize.width;
    uint8_t *imageData = [self dataForImage:image];
    
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                                 width:imageSize.width
                                                                                                height:imageSize.height
                                                                                             mipmapped:NO];
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];
    
    MTLRegion region = MTLRegionMake2D(0, 0, imageSize.width, imageSize.height);
    [texture replaceRegion:region mipmapLevel:0 withBytes:imageData bytesPerRow:bytesPerRow];
    
    free(imageData);
    return texture;
}

// 立方体纹理贴图
+ (id<MTLTexture>)textureCubeWithImagesNamed:(NSArray *)imageNameArray device:(id<MTLDevice>)device {
    NSAssert(imageNameArray.count == 6, @"Cube textures can only be created from exactly six images");
    UIImage *firstImage = [UIImage imageNamed:[imageNameArray firstObject]];
    const CGFloat cubSize = firstImage.size.width * firstImage.scale;
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * cubSize;
    const NSUInteger bytesPerImage = bytesPerRow * cubSize;
    MTLRegion region = MTLRegionMake2D(0, 0, cubSize, cubSize);
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor textureCubeDescriptorWithPixelFormat:(MTLPixelFormatRGBA8Unorm) size:cubSize mipmapped:NO];
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];
    // 将数据加载到每一个立方体面
    for (size_t slice = 0; slice < 6; slice++) {
        NSString *imageName = imageNameArray[slice];
        UIImage *image = [UIImage imageNamed:imageName];
        uint8_t *imageData = [self dataForImage:image];
        NSAssert(image.size.width, @"Cube map image must be square and uniformly-sized");
        /**
         *  imageData     必须是在纹理述符中指定的任何像素格式。
         bytesPerRow   是立方体的宽度乘以每个像素的字节数。
         bytesPerImage 又是每行的字节数乘以立方体的高度。
         */
        [texture replaceRegion:region mipmapLevel:0 slice:slice withBytes:imageData bytesPerRow:bytesPerRow bytesPerImage:bytesPerImage];
        free(imageData);
    }
    return texture;
}

@end
