//
//  ViewController.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "ViewController.h"
#import "Types.h"
#import "MetalMatrixUtilities.h"
#import "MetalTextureLoader.h"
#import "MetalView.h"
#import "MetalRender.h"
@import Metal;
@import CoreMotion;
@import simd;


@interface ViewController ()
@property (nonatomic, strong) MetalRender *renderer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CMMotionManager *motionManager;
@end

@implementation ViewController

- (void)dealloc
{
    [_displayLink invalidate];
}

- (MetalView *)metalView
{
    return (MetalView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CAMetalLayer *metalLayer = [self.metalView metalLayer];
    self.renderer = [[MetalRender alloc] initWithLayer:metalLayer];
  
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    self.motionManager = [[CMMotionManager alloc] init];
    if (self.motionManager.deviceMotionAvailable)
    {
        self.motionManager.deviceMotionUpdateInterval = 1 / 60.0;
        CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXTrueNorthZVertical;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:frame];
    }
    
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)tap:(id)sender
{
    self.renderer.useRefractionMaterial = !self.renderer.useRefractionMaterial;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 根据CMDeviceMotion设置更改场景
- (void)updateDeviceOrientation
{
    if (self.motionManager.deviceMotionAvailable)
    {
        CMDeviceMotion *motion = self.motionManager.deviceMotion;
        CMRotationMatrix m = motion.attitude.rotationMatrix;
        /*
         每个人都有自己对于哪个视图坐标空间最直观的看法，但我总是选择一个右手系统，+ Y 向上，+ X 向右，+ Z 向观察者。 
         这不同于 Core Motion 的约定， 因此为了使用设备定向数据，我们按以下方式解释 Core Motion 的轴:Core Motion 
         的 X 轴成为我们的世界的 Z 轴，Z 成为 Y，Y 成为 X.我们没有以镜像为任 何轴，因为 Core Motion 的参考框架都是
         右手的。
         */
        // permute rotation matrix from Core Motion to get scene orientation
        vector_float4 X = { m.m12, m.m22, m.m32, 0 };
        vector_float4 Y = { m.m13, m.m23, m.m33, 0 };
        vector_float4 Z = { m.m11, m.m21, m.m31, 0 };
        vector_float4 W = {     0,     0,     0, 1 };
        
        matrix_float4x4 orientation = { X, Y, Z, W };
        self.renderer.sceneOrientation = orientation;
    }
}

- (void)displayLinkDidFire:(id)sender
{
    [self updateDeviceOrientation];
    [self redraw];
}

- (void)redraw
{
    [self.renderer draw];
}


@end
