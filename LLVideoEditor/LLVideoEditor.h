//
//  VideoEditor.h
//  LLVideEditor
//
//  Created by Ömer Faruk Gül on 22/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface LLVideoEditor : NSObject

/**
 * Initialize the vide with the video URL.
 */
- (instancetype)initWithVideoURL:(NSURL *)videoURL;

/**
 * Rotate the video 90 degrees.
 */
- (void)rotate90Degrees;

/**
 * Add a lyer to the video.
 */
- (void)addLayer:(CALayer *)aLayer;

/**
 * Crop the video with the given frame.
 */
- (void)crop:(CGRect)cropFrame;


/**
 * Export the edited video.
 */
- (void)exportToUrl:(NSURL *)exportUrl
    completionBlock:(void (^)(AVAssetExportSession *session))completionBlock;

/**
 * Export the edited video with more options.
 */
- (void)exportToUrl:(NSURL *)exportUrl
         presetName:(NSString *)presetName optimizeForNetworkUse:(BOOL)optimizeForNetworkUse
     outputFileType:(NSString*)outputFileType completionBlock:(void (^)(AVAssetExportSession *session))completionBlock;

/**
 * Final size of the vdeo after every operation.
 */
@property (nonatomic, readonly) CGSize videoSize;

@end
