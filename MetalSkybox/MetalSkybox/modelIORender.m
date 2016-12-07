//
//  modelIORender.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/7.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "modelIORender.h"
@import Metal;
@import simd;

@import GLKit;
#import "MetalBall.h"
#import "MetalTextureLoader.h"

@interface modelIORender()

@property (nonatomic, strong)MetalBall *ballMesh;
@property (nonatomic, strong)id<MTLTexture> ballTexture;
@property (nonatomic, strong)id<MTLRenderPipelineState> ballPipelineState;
@property (nonatomic, strong)id<MTLDepthStencilState> depthStencilState;
@property (nonatomic, strong)id<MTLCommandQueue> commandQueue;

@end

@implementation modelIORender

- (void)init:(MTKView *)view device:(id<MTLDevice>)device {
    
    self.delegate = self;
    id<MTLLibrary> library = [device newDefaultLibrary];
    self.ballMesh = [[MetalBall alloc] init];
    [self.ballMesh initWithDevice:device xExtent:10 yExtent:10 zExtent:10 uTesselation:16 vTesselation:16];
    
    self.ballTexture = [MetalTextureLoader texture2DWithImageNamed:@"px" device:device];
    self.ballPipelineState = [device newRenderPipelineStateWithDescriptor:[self makeWithView:view library:library vertexShaderName:@"showMIOVertexShader" fragShaderName:@"showMIOFragmentShader" isIncludeDepthAttachment:NO vertexDescriptor:self.ballMesh.metalVertexDescriptor] error:nil];
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    [depthStencilDescriptor setDepthCompareFunction:(MTLCompareFunctionLess)];
    [depthStencilDescriptor setDepthWriteEnabled:YES];
    
    self.depthStencilState = [device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    
    self.commandQueue = [device newCommandQueue];

}

- (MTLRenderPipelineDescriptor *)makeWithView:(MTKView *)view
                                      library:(id<MTLLibrary>)library
                             vertexShaderName:(NSString *)vertexShaderName
                               fragShaderName:(NSString *)fragShaderName
                     isIncludeDepthAttachment:(BOOL)isIncludeDepthAttachment
                             vertexDescriptor:(MTLVertexDescriptor *)vertexDescriptor{
    MTLRenderPipelineDescriptor *pipeline = [[MTLRenderPipelineDescriptor alloc] init];
    pipeline.vertexFunction = [library newFunctionWithName:vertexShaderName];
    pipeline.fragmentFunction = [library newFunctionWithName:fragShaderName];
    pipeline.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    [pipeline.colorAttachments[ 0 ] setBlendingEnabled:YES];
    [pipeline.colorAttachments[ 0 ] setRgbBlendOperation:(MTLBlendOperationAdd)];
    [pipeline.colorAttachments[ 0 ] setAlphaBlendOperation:(MTLBlendOperationAdd)];
    [pipeline.colorAttachments[ 0 ] setSourceRGBBlendFactor:(MTLBlendFactorOne)];
    [pipeline.colorAttachments[ 0 ] setSourceAlphaBlendFactor:(MTLBlendFactorOne)];
    [pipeline.colorAttachments[ 0 ] setDestinationRGBBlendFactor:(MTLBlendFactorOneMinusSourceAlpha)];
    [pipeline.colorAttachments[ 0 ] setDestinationAlphaBlendFactor:(MTLBlendFactorOneMinusSourceAlpha)];
    if (isIncludeDepthAttachment == true) {
        pipeline.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    }
    if (vertexDescriptor != nil) {
        pipeline.vertexDescriptor = vertexDescriptor;
    }
    
    return pipeline;
    
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

/*!
 @method drawInMTKView:
 @abstract Called on the delegate when it is asked to render into the view
 @discussion Called on the delegate when it is asked to render into the view
 */
- (void)drawInMTKView:(nonnull MTKView *)view {
     MTLRenderPassDescriptor *finalPassDescriptor = view.currentRenderPassDescriptor;
    finalPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 1, 1);
    if (finalPassDescriptor) {
        id <MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        id <MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:finalPassDescriptor];
        id<CAMetalDrawable> drawable = view.currentDrawable;
        [renderCommandEncoder setDepthStencilState:self.depthStencilState];
        [renderCommandEncoder setCullMode:(MTLCullModeNone)];
        [renderCommandEncoder setFrontFacingWinding:(MTLWindingCounterClockwise)];
        [renderCommandEncoder setRenderPipelineState:self.ballPipelineState];
        [renderCommandEncoder setVertexBuffer:self.ballMesh.vertexBuffer offset:0 atIndex:0];
        [renderCommandEncoder setFragmentTexture:self.ballTexture atIndex:0];

        [renderCommandEncoder drawIndexedPrimitives:self.ballMesh.primitiveType indexCount:self.ballMesh.indexCount indexType:self.ballMesh.indexType indexBuffer:self.ballMesh.indexBuffer indexBufferOffset:0];
        [renderCommandEncoder endEncoding];
        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit];
        
    }
    
}


@end


