//
//  MetalView.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MetalView : UIView
@property (nonatomic, readonly) CAMetalLayer *metalLayer;
@end
