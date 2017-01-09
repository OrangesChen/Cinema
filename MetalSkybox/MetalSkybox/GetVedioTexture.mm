//
//  GetVedioTexture.m
//  MetalSkybox
//
//  Created by cfq on 2016/12/26.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import "GetVedioTexture.h"
#import <simd/simd.h>

struct ColorParameters
{
    simd::float3x3 yuvToRGB;
};

@interface GetVedioTexture() {
    Dvr_SDL_VoutOverlay DvrVoutOverlay;
    DvrIJKFFMoviePlayerController *dvrplayer;
    CVMetalTextureCacheRef _videoTextureCache;
}

@end

@implementation GetVedioTexture

- (void)InitPlayer:(int)mode filePath:(NSString *)filePath device:(id<MTLDevice>)device{

    self.glActiveLock = [[NSRecursiveLock alloc] init];
    [self setVideoTexture:device];
    [self setColorParameters:device];
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setPlayerOptionIntValue:1      forKey:@"videotoolbox"];
    [options setPlayerOptionIntValue:4096    forKey:@"videotoolbox-max-frame-width"];
    //[options setPlayerOptionIntValue:-1 forKey:@"loop"];
    //@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"
    NSURL *url = [NSURL URLWithString:filePath];
    //NSURL *url1 = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"]];
    dvrplayer= [[DvrIJKFFMoviePlayerController alloc] initWithContentURL: url withOptions:options];
    self.player = dvrplayer;
    self.player.shouldAutoplay = YES;
    [self.player prepareToPlay];
    //弱引用
    __weak __typeof(&*self)weakSelf = self;
    [dvrplayer setOverlay:&DvrVoutOverlay];
    [dvrplayer setDvrBlock:^(Dvr_SDL_VoutOverlay * overlay) {
        [weakSelf display:overlay];
    }];
}

- (void) lockGLActive
{
    [self.glActiveLock lock];
}

- (void) unlockGLActive
{
    @synchronized(self) {
        [self.glActiveLock unlock];
    }
}

- (BOOL) tryLockGLActive
{
    if (![self.glActiveLock tryLock])
        return NO;
    
    
    return YES;
}

- (void)display:(Dvr_SDL_VoutOverlay *)overlay {
    if (!overlay) {
        return;
    }
    
    if (!_videoTextureCache) {
        NSLog(@"No video texture cache");
        return;
    }

        [self lockGLActive];
        //    NSLog(@"Texture............");
        [self makeYUVTexture:overlay];
        [self unlockGLActive];

   
}

- (void)makeYUVTexture:(Dvr_SDL_VoutOverlay *)overlay {
    if (self.texture1) {
        self.texture1 = nil;
        self.texture2 = nil;
    }
    CVMetalTextureRef y_texture ;
    CVPixelBufferRef pixelBuffer = overlay->pixel_buffer;
    float y_width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    float y_height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, nil, MTLPixelFormatR8Unorm, y_width, y_height, 0, &y_texture);
    
    CVMetalTextureRef uv_texture;
    float uv_width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    float uv_height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, nil, MTLPixelFormatRG8Unorm, uv_width, uv_height, 1, &uv_texture);
    
    id<MTLTexture> luma = CVMetalTextureGetTexture(y_texture);
    id<MTLTexture> chroma = CVMetalTextureGetTexture(uv_texture);
    
//    _videoTexture[0] = luma;
//    _videoTexture[1] = chroma;
    self.texture1 = luma;
    self.texture2 = chroma;
    
    CVBufferRelease(y_texture);
    CVBufferRelease(uv_texture);
}

- (void)setVideoTexture:(id<MTLDevice>)device {
    CVMetalTextureCacheFlush(_videoTextureCache, 0);
    CVReturn err = CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, device, NULL, &_videoTextureCache);
    if (err) {
        NSLog(@">> ERROR: Could not create a texture cache");
        assert(0);
    }
}

- (void)setColorParameters:(id<MTLDevice>)device {
    _parametersBuffer = [device newBufferWithLength:sizeof(ColorParameters) * 2 options:MTLResourceOptionCPUCacheModeDefault];
    ColorParameters matrix;
    simd::float3 A;
    simd::float3 B;
    simd::float3 C;

    // 1
    //    A.x = 1;
    //    A.y = 1;
    //    A.z = 1;
    //
    //    B.x = 0;
    //    B.y = -0.343;
    //    B.z = 1.765;
    //
    //    C.x = 1.4;
    //    C.y = -0.765;
    //    C.z = 0;
    
    // 2
        A.x = 1.164;
        A.y = 1.164;
        A.z = 1.164;
    
        B.x = 0;
        B.y = -0.392;
        B.z = 2.017;
    
        C.x = 1.596;
        C.y = -0.813;
        C.z = 0;
    
    // 3
//    A.x = 1.164;
//    A.y = 1.164;
//    A.z = 1.164;
//    
//    B.x = 0;
//    B.y = -0.231;
//    B.z = 2.112;
//    
//    C.x = 1.793;
//    C.y = -0.533;
//    C.z = 0;
    
    matrix.yuvToRGB = simd::float3x3{A, B, C};
    memcpy(self.parametersBuffer.contents, &matrix, sizeof(ColorParameters));
}

- (NSString *)getDuration {
    
    int min = [self.player duration] / 60;
    int second = [self.player duration] - min * 60;
    int hour = min / 60;
    min = min % 60;
    return  [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, second];
}

- (NSString *)getCurrentTime {
    int min = [self.player currentPlaybackTime] / 60;
    int second = [self.player currentPlaybackTime] - min * 60;
    int hour = min / 60;
    min = min % 60;
    return  [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, second];
}

@end
