//
//  LLAddLayerCommand.h
//  LLVideoEditorExample
//
//  Created by Ömer Faruk Gül on 31/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLVideoEditor.h"
#import "LLVideoData.h"

@interface LLAddLayerCommand : NSObject <LLCommandProtocol>
// disable the basic initializer
- (instancetype)init NS_UNAVAILABLE;
// default initializer
- (instancetype)initWithVideoData:(LLVideoData *)videoData layer:(CALayer *)layer;
@end
