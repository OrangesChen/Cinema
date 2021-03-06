//
//  MetalRender.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "MetalRender.h"
#import "GetVedioTexture.h"

@interface MetalRender() {
    vector_float4 position;
    BOOL isPlayer;
    BOOL isRotate;
}
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLLibrary> library;
@property (nonatomic, strong) id<MTLRenderPipelineState> skyboxPipeline;
@property (nonatomic, strong) id<MTLRenderPipelineState> screenPipeline;
@property (nonatomic, strong) id<MTLRenderPipelineState> buttonPipeline;
@property (nonatomic, strong) id<MTLRenderPipelineState> spotPipeline;
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer;
@property (nonatomic, strong) id<MTLTexture> depthTexture;
@property (nonatomic, strong) id<MTLTexture> cubeTexture;

// TODO
@property (nonatomic, strong) id<MTLTexture> screenTexture;
@property (nonatomic, strong) id<MTLTexture> screenTexture1;
@property (nonatomic, strong) id<MTLTexture> screenTexture2;
@property (nonatomic, strong) id<MTLTexture> nextTexture;
@property (nonatomic, strong) id<MTLTexture> selectNextTexture;
@property (nonatomic, strong) id<MTLTexture> startTexture;
@property (nonatomic, strong) id<MTLTexture> selectStartTexture;
@property (nonatomic, strong) id<MTLTexture> stopTexture;
@property (nonatomic, strong) id<MTLTexture> selectStopTexture;
@property (nonatomic, strong) id<MTLTexture> preTexture;
@property (nonatomic, strong) id<MTLTexture> selectPreTexture;
@property (nonatomic, strong) id<MTLTexture> progressTexture;
@property (nonatomic, strong) id<MTLTexture> selectProgressTexture;
@property (nonatomic, strong) id<MTLTexture> rightTexture;
@property (nonatomic, strong) id<MTLTexture> leftTexture;
@property (nonatomic, strong) id<MTLTexture> spotTexture;

// 为单个设备编译的不可变的采样器状态集合
@property (nonatomic, strong) id<MTLSamplerState> samplerState;
// 天空盒网格
@property (nonatomic, strong) MetalSkyMesh *skybox;

// TODO
@property (nonatomic, strong) MetalButtonMesh *screenMesh;
@property (nonatomic, strong) MetalButtonMesh *nextButtonMesh;
@property (nonatomic, strong) MetalButtonMesh *startButtonMesh;
@property (nonatomic, strong) MetalButtonMesh *preButtonMesh;
@property (nonatomic, strong) MetalButtonMesh *progressButtonMesh;
@property (nonatomic, strong) MetalButtonMesh *rightLabelMesh;
@property (nonatomic, strong) MetalButtonMesh *leftLabelMesh;
@property (nonatomic, strong) MetalButtonMesh *spotMesh;

@property (nonatomic, strong) GetVedioTexture *vedioTexture;

// 旋转角度
@property (nonatomic, assign) CGFloat rotationAngle;

@end

@implementation MetalRender

- (instancetype)initWithLayer: (CAMetalLayer *)layer {
    self = [super init];
    if (self) {
        [self buildMetal];
        [self buildPipelines];
        [self buildResources];
        
        _layer = layer;
        _layer.device = _device;
        isPlayer = YES;
        isRotate = NO;
    }
    return self;
}

// Metal设置
- (void)buildMetal {
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    _library = [_device newDefaultLibrary];
    _vedioTexture = [[GetVedioTexture alloc] init];
    NSString *str = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"];
//    [_vedioTexture InitPlayer:0 filePath:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8" device:_device];
    [_vedioTexture InitPlayer:0 filePath:str device:_device];
}

- (id<MTLRenderPipelineState>)pipelineForVertexFunctionNamed:(NSString *)vertexFunctionName
                                       fragmentFunctionNamed:(NSString *)fragmentFunctionName
{
    MTLVertexDescriptor *vertexDescriptor = [MTLVertexDescriptor new];
    // position
    vertexDescriptor.attributes[0].bufferIndex = 0;
    vertexDescriptor.attributes[0].offset = 0;
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat4;
    
    // normal
    vertexDescriptor.attributes[1].offset = sizeof(vector_float4);
    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat4;
    vertexDescriptor.attributes[1].bufferIndex = 0;
    
    vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    vertexDescriptor.layouts[0].stride = sizeof(SkyVertex);
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.vertexFunction = [_library newFunctionWithName:vertexFunctionName];
    pipelineDescriptor.fragmentFunction = [_library newFunctionWithName:fragmentFunctionName];
    pipelineDescriptor.vertexDescriptor = vertexDescriptor;
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    NSError *error = nil;
    id<MTLRenderPipelineState> pipeline = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    if (!pipeline)
    {
        NSLog(@"Error occurred while creating render pipeline: %@", error);
    }
    
    return pipeline;
}


- (id<MTLRenderPipelineState>)pipeline2DForVertexFunction:(NSString *)vertexFunction fragmentFunction:(NSString *)fragFunction {
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.vertexFunction = [_library newFunctionWithName:vertexFunction];
    pipelineDescriptor.fragmentFunction = [_library newFunctionWithName:fragFunction];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    NSError *error = nil;
    id<MTLRenderPipelineState> pipeline = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    if (!pipeline)
    {
        NSLog(@"Error occurred while creating render pipeline: %@", error);
    }
    return pipeline;
}

// 渲染管道设置
- (void)buildPipelines
{
    // 天空盒
    self.skyboxPipeline = [self pipelineForVertexFunctionNamed:@"vertex_skybox"
                                         fragmentFunctionNamed:@"fragment_cube_lookup"];
    
    self.screenPipeline = [self pipeline2DForVertexFunction:@"texture_vertex"
                                           fragmentFunction:@"yuv_rgb"];
    
    self.buttonPipeline = [self pipeline2DForVertexFunction:@"texture_vertex"
                                           fragmentFunction:@"button_fragment"];
    
    self.spotPipeline = [self pipeline2DForVertexFunction:@"texture_vertex"
                                         fragmentFunction:@"spot_fragment"];

}

//  设置资源
- (void)buildResources
{
    // 获取天空盒的6涨图片
//    NSArray *imageNames = @[@"px", @"nx", @"py", @"ny", @"pz", @"nz"];
    NSArray *imageNames = @[@"cinema_0102_right.png", @"cinema_0102_left.png", @"cinema_0102_up.png", @"cinema_0102_down.png", @"cinema_0102_back.png", @"cinema_0102_front.png"];
    // 设置立方体纹理贴图
    self.cubeTexture = [MetalTextureLoader textureCubeWithImagesNamed:imageNames device:self.device];
    
    // 获取天空盒网格
    self.skybox = [[MetalSkyMesh alloc] initWithDevice:self.device];
    
    // 屏幕
    self.screenMesh = [[MetalButtonMesh alloc] initWithDevice:self.device];
    self.screenTexture = [MetalTextureLoader texture2DWithImageNamed:@"py" device:self.device];
    
    // 开始
    self.startButtonMesh = [[MetalButtonMesh alloc] initWithStartDevice:self.device];
    self.startTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_player_play" device:self.device];
    self.selectStartTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_player_play_CLICK" device:self.device];
    self.stopTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_play_pause" device:self.device];
    self.selectStopTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_play_pause_CLICK" device:self.device];
    
    // 上一首
    self.preButtonMesh = [[MetalButtonMesh alloc] initWithPretDevice:self.device];
    self.preTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_play_rewind" device:self.device];
    self.selectPreTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_play_rewind_CLICK" device:self.device];
    
    // 下一首
    self.nextButtonMesh = [[MetalButtonMesh alloc] initWithNextDevice:self.device];
    self.nextTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_play_advance" device:self.device];
    self.selectNextTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_play_advance_CLICK" device:self.device];
    
    // 进度条
    self.progressButtonMesh = [[MetalButtonMesh alloc] initWithProgresstDevice:self.device];
    self.progressTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_rate" device:self.device];
    self.selectProgressTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_ratebg" device:self.device];
    
    // 时间显示
    self.rightLabelMesh = [[MetalButtonMesh alloc] initWithRightLabelDevice:self.device];
//    UIImage *image = [StringToImage imageFromString:@"60:00:00" withFont:20];
//    self.rightTexture = [MetalTextureLoader texture2DWithImage:image device:self.device];
    
    //
    self.leftLabelMesh = [[MetalButtonMesh alloc] initWithLeftLabelDevice:self.device];
//    UIImage *leftImage = [StringToImage imageFromString:@"00:00:00" withFont:20];
//    self.leftTexture = [MetalTextureLoader texture2DWithImage:leftImage device:self.device];
    
    // 焦点
    self.spotMesh = [[MetalButtonMesh alloc] initWithSpotDevice:self.device];
    self.spotTexture = [MetalTextureLoader texture2DWithImageNamed:@"spot" device:self.device];

    // 设置矩阵数据
    self.uniformBuffer = [self.device newBufferWithLength:sizeof(SkyUniforms) * 2
                                                  options:MTLResourceOptionCPUCacheModeDefault];
    // 采样器设置
    MTLSamplerDescriptor *samplerDescriptor = [MTLSamplerDescriptor new];
    samplerDescriptor.minFilter = MTLSamplerMinMagFilterNearest;
    samplerDescriptor.magFilter = MTLSamplerMinMagFilterLinear;
    // 设置采样器集合
    self.samplerState = [self.device newSamplerStateWithDescriptor:samplerDescriptor];
}


- (void)buildDepthBuffer
{
    CGSize drawableSize = self.layer.drawableSize;
    MTLTextureDescriptor *depthTexDesc = [MTLTextureDescriptor
                                    texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                                                 width:drawableSize.width
                                                                height:drawableSize.height
                                                             mipmapped:NO];
    self.depthTexture = [self.device newTextureWithDescriptor:depthTexDesc];
}

// 绘制天空盒
- (void)drawSkyboxWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder
{
    // 深度缓存器
    MTLDepthStencilDescriptor *depthDescriptor = [MTLDepthStencilDescriptor new];
    depthDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    // 通过将MTLDepthStencilDescriptor的depthWriteEnabled设置为NO来禁止深度写入
    depthDescriptor.depthWriteEnabled = NO;
    id <MTLDepthStencilState> depthState = [self.device newDepthStencilStateWithDescriptor:depthDescriptor];
    
    [commandEncoder setRenderPipelineState:self.skyboxPipeline];
    [commandEncoder setDepthStencilState:depthState];
    [commandEncoder setVertexBuffer:self.skybox.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setVertexBuffer:self.uniformBuffer offset:0 atIndex:1];
//    // 在给定绑定点索引处为所有片段着色器设置全局缓冲区。
//    [commandEncoder setFragmentBuffer:self.uniformBuffer offset:0 atIndex:0];
    // 设置纹理
    [commandEncoder setFragmentTexture:self.cubeTexture atIndex:0];
    // 设置采样器
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
    
    [commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                               indexCount:[self.skybox.indexBuffer length] / sizeof(UInt16)
                                indexType:MTLIndexTypeUInt16
                              indexBuffer:self.skybox.indexBuffer
                        indexBufferOffset:0];
}

// 绘制屏幕
- (void)drawScreenWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    [commandEncoder setRenderPipelineState:self.screenPipeline];
    [commandEncoder setVertexBuffer:self.screenMesh.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
    [commandEncoder setFragmentBuffer:_vedioTexture.parametersBuffer offset:0 atIndex:1];
    [commandEncoder setVertexBuffer:self.uniformBuffer offset:0 atIndex:1];
    float dif = 0.5;

        [_vedioTexture lockGLActive];
        _screenTexture1 = _vedioTexture.texture1;
        _screenTexture2 = _vedioTexture.texture2;
        [_vedioTexture unlockGLActive];
   
    if (fabs(position.x + 0.06)<= dif && fabs(position.y - 0.45) <= dif/2 && fabs(position.z - 1) <= 0.2 && 1) {
        
        if (!_screenTexture1) {
            [commandEncoder setFragmentTexture:self.screenTexture atIndex:0];
            [commandEncoder setFragmentTexture:self.screenTexture atIndex:1];
        } else {
//            NSLog(@"Render............");
            [commandEncoder setFragmentTexture:_screenTexture1 atIndex:0];
            [commandEncoder setFragmentTexture:_screenTexture2 atIndex:1];
        }
    } else {
        if (!_screenTexture1) {
            [commandEncoder setFragmentTexture:self.screenTexture atIndex:0];
            [commandEncoder setFragmentTexture:self.screenTexture atIndex:1];
        } else {
//            NSLog(@"Render............");
            [commandEncoder setFragmentTexture:_screenTexture1 atIndex:0];
            [commandEncoder setFragmentTexture:_screenTexture2 atIndex:1];
        }
    }
    
    
//  NSLog(@"x: %f y: %f z: %f", fabs(position.x <= dif), fabs(position.y - 0.35 <= dif), fabs(position.z - 1 <= dif));
//    [commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.screenMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.screenMesh.indexBuffer indexBufferOffset:0];
}


// 绘制按钮
- (void)drawStartWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.startButtonMesh.vertexBuffer offset:0 atIndex:0];
    float dif = 0.04;
//    NSLog(@"%d", [_vedioTexture.player isPlaying]);
    if (fabs(position.x - 0.27)<= dif && fabs(position.y - 0.11) <= dif && fabs(position.z - 1) <= 0.2) {
        if (![_vedioTexture.player isPlaying]) {
            [commandEncoder setFragmentTexture:self.selectStartTexture atIndex:0];
            
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               [_vedioTexture.player play];
           });

        } else {
            [commandEncoder setFragmentTexture:self.selectStopTexture atIndex:0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [_vedioTexture.player pause];
            });
        }
//        isPlayer = !isPlayer;
    } else {
        if (![_vedioTexture.player isPlaying]) {
            [commandEncoder setFragmentTexture:self.startTexture atIndex:0];
        } else {
            [commandEncoder setFragmentTexture:self.stopTexture atIndex:0];
        }
        
    }
//  NSLog(@"x: %f y: %f z: %f", position.x, position.y, fabs(position.z - 1));
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
//    [commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.startButtonMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.startButtonMesh.indexBuffer indexBufferOffset:0];
}

- (void)drawNextWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.nextButtonMesh.vertexBuffer offset:0 atIndex:0];
    float dif = 0.04;
    if (fabs(position.x - 0.16)<= dif && fabs(position.y - 0.11) <= dif && fabs(position.z - 1) <= 0.2) {
        [commandEncoder setFragmentTexture:self.selectNextTexture atIndex:0];
    } else {
        [commandEncoder setFragmentTexture:self.nextTexture atIndex:0];
    }
//  NSLog(@"x: %f y: %f z: %f", fabs(position.x - 0.35), fabs(position.y + 0.22), fabs(position.z - 1));
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
//    [commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.nextButtonMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.nextButtonMesh.indexBuffer indexBufferOffset:0];
}

- (void)drawPreWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.preButtonMesh.vertexBuffer offset:0 atIndex:0];
    float dif = 0.04;
    if (fabs(position.x - 0.34)<= dif && fabs(position.y - 0.11) <= dif && fabs(position.z - 1) <= 0.2) {
        [commandEncoder setFragmentTexture:self.selectPreTexture atIndex:0];
    } else {
        [commandEncoder setFragmentTexture:self.preTexture atIndex:0];
    }
//  NSLog(@"x: %f y: %f z: %f", fabs(position.x - 0.5), fabs(position.y + 0.22), fabs(position.z - 1));
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
//    [commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.preButtonMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.preButtonMesh.indexBuffer indexBufferOffset:0];
}


- (void)drawProgressWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.progressButtonMesh.vertexBuffer offset:0 atIndex:0];
    float dif = 0.5;
    if (fabs(position.x + 0.06)<= dif && fabs(position.y - 0.20) <= 0.025 && fabs(position.z - 1) <= 0.2) {
        [commandEncoder setFragmentTexture:self.selectProgressTexture atIndex:0];
    } else {
        [commandEncoder setFragmentTexture:self.progressTexture atIndex:0];
    }
//    NSLog(@"x: %f y: %f z: %f", fabs(position.x - 0.15), fabs(position.y + 0.14), fabs(position.z - 1));
//    [commandEncoder setFragmentTexture:self.progressTexture atIndex:0];
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
//    [commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.progressButtonMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.progressButtonMesh.indexBuffer indexBufferOffset:0];
}

- (void)drawRightLabelWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    if ([_vedioTexture.player isPlaying] && isPlayer) {
//        NSLog(@"%@", [_vedioTexture getDuration]);
        _rightTexture = [MetalTextureLoader texture2DWithStringToImage:[_vedioTexture getDuration] device:_device withFont:20];
        isPlayer = NO;
    }
    
//     NSLog(@"%@", [_vedioTexture getCurrentTime]);
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.rightLabelMesh.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setFragmentTexture:self.rightTexture atIndex:0];
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
    //[commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.rightLabelMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.rightLabelMesh.indexBuffer indexBufferOffset:0];
}

- (void)drawLeftLabelWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    _leftTexture = [MetalTextureLoader texture2DWithStringToImage:[_vedioTexture getCurrentTime] device:_device withFont:20];
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.leftLabelMesh.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setFragmentTexture:self.leftTexture atIndex:0];
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
    //[commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.leftLabelMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.leftLabelMesh.indexBuffer indexBufferOffset:0];
}

- (void)drawSpotWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.spotPipeline];
    [commandEncoder setVertexBuffer:self.spotMesh.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setFragmentTexture:self.spotTexture atIndex:0];
    [commandEncoder setFragmentBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:0];
    [commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.spotMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.spotMesh.indexBuffer indexBufferOffset:0];
}

- (MTLRenderPassDescriptor *)renderPassForDrawable:(id<CAMetalDrawable>)drawable
{
    MTLRenderPassDescriptor *renderPass = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPass.colorAttachments[0].texture = drawable.texture;
    renderPass.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPass.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0.6, 0.3, 0.2, 1);
    renderPass.depthAttachment.texture = self.depthTexture;
    renderPass.depthAttachment.loadAction = MTLLoadActionClear;
    renderPass.depthAttachment.storeAction = MTLStoreActionDontCare;
    renderPass.depthAttachment.clearDepth = 1;
    return renderPass;
}

// 更新矩阵
- (void)updateUniforms
{
    static const vector_float4 cameraPosition = { 0, 0, -4, 1 };
    const CGSize size = self.layer.bounds.size;
    const CGFloat aspectRatio = size.width / size.height;
    const CGFloat verticalFOV = (aspectRatio > 1) ? 60 : 90;
    static const CGFloat near = 0.1;
    static const CGFloat far = 200;
    
    matrix_float4x4 projectionMatrix = matrix_perspective_projection(aspectRatio, verticalFOV * (M_PI / 180), near, far);
    matrix_float4x4 modelMatrix = matrix_identity();
    // 场景位置
    matrix_float4x4 skyboxViewMatrix = self.sceneOrientation;
    vector_float4 worldCameraPosition = matrix_multiply(matrix_invert(self.sceneOrientation), -cameraPosition);
    matrix_float4x4 spotViewMatrix = matrix_multiply(translation(cameraPosition), self.sceneOrientation);
    
    SkyUniforms skyboxUniforms;
    skyboxUniforms.modelMatrix = modelMatrix;
    skyboxUniforms.projectionMatrix = projectionMatrix;
    skyboxUniforms.normalMatrix = matrix_transpose(matrix_invert(skyboxUniforms.modelMatrix));
//    if (!isRotate) {
//        vector_float3 W = {0, 1, 0};
//        skyboxUniforms.modelMatrix = matrix_rotation(W, -90);
//        isRotate = YES;
//    }
    skyboxUniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(skyboxViewMatrix, modelMatrix));
    skyboxUniforms.worldCameraPosition = worldCameraPosition;
    memcpy(self.uniformBuffer.contents, &skyboxUniforms, sizeof(SkyUniforms));
    
    SkyUniforms spotUniforms;
    spotUniforms.modelMatrix = modelMatrix;
    spotUniforms.projectionMatrix = projectionMatrix;
    spotUniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(spotViewMatrix, modelMatrix));
//    spotUniforms.worldCameraPosition = worldCameraPosition;
    memcpy(self.uniformBuffer.contents + sizeof(SkyUniforms), &spotUniforms, sizeof(SkyUniforms));
    
    // 获取焦点spot的位置
    vector_float4 spot = {-0.1, 0.1, 0, 1};
//    vector_float4 spot = { 0, 0, -4, 1 };
    position = matrix_multiply(spot, spotUniforms.modelViewProjectionMatrix);
//    NSLog(@"%f, %f, %f", position.x, position.y, position.z);
}


- (void)draw {
    CGSize drawableSize = self.layer.drawableSize;
    if (self.depthTexture.width != drawableSize.width || self.depthTexture.height != drawableSize.height)
    {
        [self buildDepthBuffer];
    }
    
    id<CAMetalDrawable> drawable = [self.layer nextDrawable];
    if (drawable)
    {
        [self updateUniforms];
        
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        
        MTLRenderPassDescriptor *renderPass = [self renderPassForDrawable:drawable];
        
        id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPass];
        [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
        [commandEncoder setCullMode:MTLCullModeBack];
    
        MTLViewport viewport;
        
        viewport.originX = 0;
        viewport.originY = 0;
        viewport.width = SCREEN_WIDTH;
        viewport.height = SCREEN_HEIGHT / 2;
        viewport.zfar = 1.0;
        viewport.znear = 0;

        [commandEncoder setViewport:viewport];
        [self drawGraphics:commandEncoder];

        viewport.originY = SCREEN_HEIGHT / 2;
        [commandEncoder setViewport:viewport];
        [self drawGraphics:commandEncoder];
        
        // 绘制
//        [self drawSkyboxWithCommandEncoder:commandEncoder];
////        [_vedioTexture lockGLActive];
//        [self drawScreenWithCommandEncoder:commandEncoder];
////        [_vedioTexture unlockGLActive];
//        [self drawNextWithCommandEncoder:commandEncoder];
//        [self drawPreWithCommandEncoder:commandEncoder];
//        [self drawStartWithCommandEncoder:commandEncoder];
//        [self drawProgressWithCommandEncoder:commandEncoder];
//        [self drawRightLabelWithCommandEncoder:commandEncoder];
//        [self drawLeftLabelWithCommandEncoder:commandEncoder];
//        [self drawSpotWithCommandEncoder:commandEncoder];
        
        [commandEncoder endEncoding];
        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit];
    }
}

- (void)drawGraphics:(id<MTLRenderCommandEncoder>)commandEncoder {
    // 绘制
    [self drawSkyboxWithCommandEncoder:commandEncoder];
    //        [_vedioTexture lockGLActive];
    [self drawScreenWithCommandEncoder:commandEncoder];
    //        [_vedioTexture unlockGLActive];
    [self drawNextWithCommandEncoder:commandEncoder];
    [self drawPreWithCommandEncoder:commandEncoder];
    [self drawStartWithCommandEncoder:commandEncoder];
    [self drawProgressWithCommandEncoder:commandEncoder];
    [self drawRightLabelWithCommandEncoder:commandEncoder];
    [self drawLeftLabelWithCommandEncoder:commandEncoder];
    [self drawSpotWithCommandEncoder:commandEncoder];
}



@end
