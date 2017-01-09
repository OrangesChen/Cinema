//
//  GetVedioTexture.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/26.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface GetVedioTexture : NSObject
@property (nonatomic, retain) id<IJKMediaPlayback> player;
@property (nonatomic, strong) id<MTLBuffer> parametersBuffer;
@property (nonatomic, strong) id<MTLTexture> texture1;
@property (nonatomic, strong) id<MTLTexture> texture2;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *currentTime;
@property(atomic,strong) NSRecursiveLock *glActiveLock;

- (void)setVideoTexture:(id<MTLDevice>)device;
- (void) InitPlayer:(int)mode filePath:(NSString *)filePath device:(id<MTLDevice>)device;
- (NSString *)getCurrentTime;
- (NSString *)getDuration;
- (void) lockGLActive;
- (void) unlockGLActive;
- (BOOL) tryLockGLActive;

@end
