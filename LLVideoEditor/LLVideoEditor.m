//
//  VideoEditor.m
//  LLVideEditor
//
//  Created by Ömer Faruk Gül on 22/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import "LLVideoEditor.h"
@import UIKit;

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

@interface LLVideoEditor()
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVMutableComposition *composition;
@property (strong, nonatomic) AVAssetTrack *assetVideoTrack;
@property (strong, nonatomic) AVAssetTrack *assetAudioTrack;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) AVMutableVideoComposition *videoComposition;
@property (strong, nonatomic) AVMutableCompositionTrack *videoCompositionTrack;
@property (strong, nonatomic) AVMutableCompositionTrack *audioCompositionTrack;
@property (strong, nonatomic) NSMutableArray *layerInstructionArr;
@property (nonatomic) CGSize newSize;
@end

@implementation LLVideoEditor
- (instancetype)initWithVideoURL:(NSURL *)videoURL {
   self = [super init];
    if(self) {
        _asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        _layerInstructionArr = [NSMutableArray array];
        
        [self loadAsset:_asset];
    }
    
    return self;
}


- (void)loadAsset:(AVAsset *)asset {
    
    // Check if the asset contains video and audio tracks
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count != 0) {
        _assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([asset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
        _assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    // Check if a composition already exists, else create a composition using the input asset
    self.composition = [AVMutableComposition composition];
    
    CMTime insertionPoint = kCMTimeZero;
    NSError *error = nil;
    
    // Insert the video and audio tracks from AVAsset
    if (_assetVideoTrack != nil) {
        _videoCompositionTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                              preferredTrackID:kCMPersistentTrackID_Invalid];
        [_videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                            ofTrack:_assetVideoTrack
                             atTime:insertionPoint error:&error];
        
        NSLog(@"Asset initialized with natural size: %@", NSStringFromCGSize(_assetVideoTrack.naturalSize));
        
        //CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI_2);
        //videoTrack.preferredTransform = rotationTransform;
        //[videoTrack setPreferredTransform:[_assetVideoTrack preferredTransform]];
    }
    if (_assetAudioTrack != nil) {
        _audioCompositionTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                              preferredTrackID:kCMPersistentTrackID_Invalid];
        [_audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                            ofTrack:_assetAudioTrack
                             atTime:insertionPoint error:&error];
    }
    
    _videoSize = [_assetVideoTrack naturalSize];
    _newSize = [_assetVideoTrack naturalSize];
}

- (void)rotate90Degrees {
    
    AVMutableVideoCompositionInstruction *instruction = nil;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
    
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(self.newSize.height, 0.0);
    CGAffineTransform t2 = CGAffineTransformRotate(t1, degreesToRadians(90.0));
    
    self.newSize = CGSizeMake(self.newSize.height, self.newSize.width);
    
    if (!self.videoComposition) {
        // Create a new video composition
        self.videoComposition = [AVMutableVideoComposition videoComposition];
        self.videoComposition.frameDuration = CMTimeMake(1, 30);
    }

    self.videoComposition.renderSize = self.newSize;
    
    // The rotate transform is set on a layer instruction
    instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [self.composition duration]);
    
    layerInstruction = [AVMutableVideoCompositionLayerInstruction
                        videoCompositionLayerInstructionWithAssetTrack:_videoCompositionTrack];
    [layerInstruction setTransform:t2 atTime:kCMTimeZero];
    
    [self.layerInstructionArr addObject:layerInstruction];
    
    instruction.layerInstructions = [self.layerInstructionArr copy];
    self.videoComposition.instructions = @[instruction];
}


- (void)crop:(CGRect)cropFrame {
    
    AVMutableVideoCompositionInstruction *instruction = nil;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
    
    if (!self.videoComposition) {
        self.videoComposition = [AVMutableVideoComposition videoComposition];
        self.videoComposition.frameDuration = CMTimeMake(1, 30);
    }
    
    // The rotate transform is set on a layer instruction
    instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [self.composition duration]);
    
    layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:_videoCompositionTrack];
    //[layerInstruction setTransform:t2 atTime:kCMTimeZero];
    [layerInstruction setCropRectangle:cropFrame atTime:CMTimeMake(1, 30)];
    
    // set new size (final render size)
    _newSize = cropFrame.size;
    self.videoComposition.renderSize = _newSize;
    
    // add to final layer instructions
    [self.layerInstructionArr addObject:layerInstruction];
    
    instruction.layerInstructions = [self.layerInstructionArr copy];
    self.videoComposition.instructions = @[instruction];
}


- (void)addLayer:(CALayer *)aLayer {
    
    CGSize videoSize = _newSize;
    
    AVMutableVideoCompositionInstruction *instruction = nil;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
    
//    NSLog(@"The video size is: %@", NSStringFromCGSize(videoSize));
//    NSLog(@"Asset natural size adding layer: %@", NSStringFromCGSize(_assetVideoTrack.naturalSize));
    
    CALayer *parentLayer = [CALayer layer];

    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:aLayer];
    
    if (!self.videoComposition) {
        self.videoComposition = [AVMutableVideoComposition videoComposition];
        self.videoComposition.frameDuration = CMTimeMake(1, 30);
    }
    
    _videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool      videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [self.composition duration]);

    layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:_videoCompositionTrack];
    
    // add to final layer instructions
    [self.layerInstructionArr addObject:layerInstruction];
    
    instruction.layerInstructions = [self.layerInstructionArr copy];
    self.videoComposition.instructions = @[instruction];
}

- (void)exportToUrl:(NSURL *)exportUrl completionBlock:(void (^)(AVAssetExportSession *session))completionBlock {
        [self exportToUrl:exportUrl
               presetName:AVAssetExportPreset1280x720
    optimizeForNetworkUse:YES
           outputFileType:AVFileTypeQuickTimeMovie
          completionBlock:completionBlock];
}

- (void)exportToUrl:(NSURL *)exportUrl
         presetName:(NSString *)presetName optimizeForNetworkUse:(BOOL)optimizeForNetworkUse
     outputFileType:(NSString*)outputFileType completionBlock:(void (^)(AVAssetExportSession *session))completionBlock {
    
    NSLog(@"Starting export.");
    _exportSession = [[AVAssetExportSession alloc] initWithAsset:[self.composition copy]
                                                      presetName:presetName];
    
    if(self.videoComposition) {
        _exportSession.videoComposition = self.videoComposition;
    }
    
    NSError *error = nil;
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:exportUrl.path]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:exportUrl.path error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
    
    _exportSession.outputFileType = outputFileType;
    _exportSession.outputURL = exportUrl;
    _exportSession.shouldOptimizeForNetworkUse = optimizeForNetworkUse;
    
    [_exportSession exportAsynchronouslyWithCompletionHandler:^(void ) {
        
        if(completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _asset = [[AVURLAsset alloc] initWithURL:exportUrl options:nil];
                [self loadAsset:_asset];
                completionBlock(_exportSession);
            });
        }
    }];
}

@end
