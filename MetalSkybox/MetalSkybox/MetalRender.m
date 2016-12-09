//
//  MetalRender.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "MetalRender.h"
#import "MetalTextureLoader.h"
#import "MetalSkyMesh.h"
#import "MetalMatrixUtilities.h"
#import "Types.h"
#import "MetalButtonMesh.h"
#import "StringToImage.h"

@interface MetalRender()
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLLibrary> library;
@property (nonatomic, strong) id<MTLRenderPipelineState> skyboxPipeline;
@property (nonatomic, strong) id<MTLRenderPipelineState> screenPipeline;
@property (nonatomic, strong) id<MTLRenderPipelineState> buttonPipeline;
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer;
@property (nonatomic, strong) id<MTLTexture> depthTexture;
@property (nonatomic, strong) id<MTLTexture> cubeTexture;

// TODO
@property (nonatomic, strong) id<MTLTexture> screenTexture;
@property (nonatomic, strong) id<MTLTexture> nextTexture;
@property (nonatomic, strong) id<MTLTexture> startTexture;
@property (nonatomic, strong) id<MTLTexture> preTexture;
@property (nonatomic, strong) id<MTLTexture> progressTexture;
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
    }
    return self;
}

// Metal设置
- (void)buildMetal {
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    _library = [_device newDefaultLibrary];
}

- (id<MTLRenderPipelineState>)pipelineForVertexFunctionNamed:(NSString *)vertexFunctionName
                                       fragmentFunctionNamed:(NSString *)fragmentFunctionName
{
    MTLVertexDescriptor *vertexDescriptor = [MTLVertexDescriptor new];
    vertexDescriptor.attributes[0].bufferIndex = 0;
    vertexDescriptor.attributes[0].offset = 0;
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat4;
    
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
    self.screenPipeline = [self pipeline2DForVertexFunction:@"texture_vertex" fragmentFunction:@"texture_fragment"];
    
    self.buttonPipeline = [self pipeline2DForVertexFunction:@"texture_vertex" fragmentFunction:@"button_fragment"];

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
    
    // TODO
    // 屏幕
    self.screenMesh = [[MetalButtonMesh alloc] initWithDevice:self.device];
    self.screenTexture = [MetalTextureLoader texture2DWithImageNamed:@"py" device:self.device];
    
    // 开始
    self.startButtonMesh = [[MetalButtonMesh alloc] initWithStartDevice:self.device];
    self.startTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_player_play" device:self.device];
    
    // 上一首
    self.preButtonMesh = [[MetalButtonMesh alloc] initWithPretDevice:self.device];
    self.preTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_play_rewind" device:self.device];
    
    // 下一首
    self.nextButtonMesh = [[MetalButtonMesh alloc] initWithNextDevice:self.device];
    self.nextTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_play_advance_CLICK" device:self.device];
    
    // 进度条
    self.progressButtonMesh = [[MetalButtonMesh alloc] initWithProgresstDevice:self.device];
    self.progressTexture = [MetalTextureLoader texture2DWithImageNamed:@"movie_rate" device:self.device];
    // 时间显示
    self.rightLabelMesh = [[MetalButtonMesh alloc] initWithRightLabelDevice:self.device];
    UIImage *image = [StringToImage imageFromString:@"09:58:60" withFont:20];
    self.rightTexture = [MetalTextureLoader texture2DWithImage:image device:self.device];
    
    //
    self.leftLabelMesh = [[MetalButtonMesh alloc] initWithLeftLabelDevice:self.device];
    UIImage *leftImage = [StringToImage imageFromString:@"00:00:00" withFont:20];
    self.leftTexture = [MetalTextureLoader texture2DWithImage:leftImage device:self.device];
    
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
    // 在给定绑定点索引处为所有片段着色器设置全局缓冲区。
    [commandEncoder setFragmentBuffer:self.uniformBuffer offset:0 atIndex:0];
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
    // TODO
    [commandEncoder setFragmentTexture:self.screenTexture atIndex:0];
    //[commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.screenMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.screenMesh.indexBuffer indexBufferOffset:0];
}


// 绘制按钮
- (void)drawStartWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.startButtonMesh.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setFragmentTexture:self.startTexture atIndex:0];
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
//  [commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.startButtonMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.startButtonMesh.indexBuffer indexBufferOffset:0];
}

- (void)drawNextWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.nextButtonMesh.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setFragmentTexture:self.nextTexture atIndex:0];
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
    //[commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.nextButtonMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.nextButtonMesh.indexBuffer indexBufferOffset:0];
}

- (void)drawPreWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.preButtonMesh.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setFragmentTexture:self.preTexture atIndex:0];
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
    //[commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.preButtonMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.preButtonMesh.indexBuffer indexBufferOffset:0];
}


- (void)drawProgressWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
    [commandEncoder setCullMode:(MTLCullModeNone)];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.progressButtonMesh.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setFragmentTexture:self.progressTexture atIndex:0];
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
    //[commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.progressButtonMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.progressButtonMesh.indexBuffer indexBufferOffset:0];
}

- (void)drawRightLabelWithCommandEncoder:(id<MTLRenderCommandEncoder>)commandEncoder {
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
    [commandEncoder setRenderPipelineState:self.buttonPipeline];
    [commandEncoder setVertexBuffer:self.leftLabelMesh.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setFragmentTexture:self.leftTexture atIndex:0];
    [commandEncoder setFragmentSamplerState:self.samplerState atIndex:0];
    //[commandEncoder setVertexBuffer:self.uniformBuffer offset:sizeof(SkyUniforms) atIndex:1];
    [commandEncoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangle) indexCount:[self.leftLabelMesh.indexBuffer length] / sizeof(UInt16) indexType:MTLIndexTypeUInt16 indexBuffer:self.leftLabelMesh.indexBuffer indexBufferOffset:0];
}

- (MTLRenderPassDescriptor *)renderPassForDrawable:(id<CAMetalDrawable>)drawable
{
    MTLRenderPassDescriptor *renderPass = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPass.colorAttachments[0].texture = drawable.texture;
    renderPass.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPass.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
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
    
    SkyUniforms skyboxUniforms;
    skyboxUniforms.modelMatrix = modelMatrix;
    skyboxUniforms.projectionMatrix = projectionMatrix;
    skyboxUniforms.normalMatrix = matrix_transpose(matrix_invert(skyboxUniforms.modelMatrix));
    skyboxUniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(skyboxViewMatrix, modelMatrix));
    skyboxUniforms.worldCameraPosition = worldCameraPosition;
    memcpy(self.uniformBuffer.contents, &skyboxUniforms, sizeof(SkyUniforms));
    
//    SkyUniforms screenUniform;
//    screenUniform.modelMatrix = modelMatrix;
//    screenUniform.projectionMatrix = projectionMatrix;
//    screenUniform.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, modelMatrix);
//    memcpy(self.uniformBuffer.contents, &screenUniform, sizeof(screenUniform));
    
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
        
        [self drawSkyboxWithCommandEncoder:commandEncoder];
        [self drawScreenWithCommandEncoder:commandEncoder];
        [self drawNextWithCommandEncoder:commandEncoder];
        [self drawPreWithCommandEncoder:commandEncoder];
        [self drawStartWithCommandEncoder:commandEncoder];
        [self drawProgressWithCommandEncoder:commandEncoder];
        [self drawRightLabelWithCommandEncoder:commandEncoder];
        [self drawLeftLabelWithCommandEncoder:commandEncoder];
        [self drawSpotWithCommandEncoder:commandEncoder];
        
        [commandEncoder endEncoding];
        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit];
    }
}

@end
