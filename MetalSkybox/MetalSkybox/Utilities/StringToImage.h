//
//  StringToImage.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/9.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StringToImage : NSObject

/**
 *  输入字符串生成图片
 *
 *  @param str      字符串
 *  @param fontSize 字体大小
 *
 *  @return 图片
 */
+(UIImage *)imageFromString:(NSString*)str withFont: (CGFloat)fontSize;

@end
