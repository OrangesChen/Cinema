//
//  StringToImage.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/9.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import QuartzCore;

@interface StringToImage : NSObject

+(UIImage *)imageFromString:(NSString*)str withFont: (CGFloat)fontSize;

@end
