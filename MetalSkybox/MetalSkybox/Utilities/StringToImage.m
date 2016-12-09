//
//  StringToImage.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/9.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "StringToImage.h"

@implementation StringToImage

// 将视频转换成字符串，绘制成图片输出
+(UIImage *)imageFromString:(NSString*)str withFont: (CGFloat)fontSize {
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CGFloat fHeight = 0.0f;
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attribute = @{NSFontAttributeName: font,
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName: [UIColor whiteColor]};
    CGSize stringSize = [str boundingRectWithSize:CGSizeMake(300, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    fHeight += stringSize.height;
    CGFloat fWidth = stringSize.width;
    CGSize newSize = CGSizeMake(fWidth, fHeight);
    UIGraphicsBeginImageContextWithOptions(newSize,NO,0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetCharacterSpacing(ctx, 10);
    CGContextSetTextDrawingMode (ctx, kCGTextFillStroke);
    CGContextSetRGBFillColor (ctx, 0.1, 0.1, 0.1, 1); // 6
    CGContextSetRGBStrokeColor (ctx, 0, 0, 0, 1);
    CGRect rect = CGRectMake(0, 0, fWidth + 10, fHeight + 10);
    [str drawInRect:rect withAttributes:attribute];
    //transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    NSLog(@"width: %lf, height: %lf", image.size.width, image.size.height);
    UIGraphicsEndImageContext();
    return image;
}

@end
