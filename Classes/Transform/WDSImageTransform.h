//
//  WDSImageTransform.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSTransformPipe.h"

typedef enum {
    kWDSImageTransformModeDataToImage,
    kWDSImageTransformModeImageToJPEG,
    kWDSImageTransformModeImageToPNG,
} WDSImageTransformMode;


@interface WDSImageTransform : NSObject<WDSTransform>

@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) WDSImageTransformMode mode;
@property (nonatomic, assign) CGFloat jpegQuality;
@property (nonatomic, assign) NSUInteger maxImageSize;

- (instancetype)initWithScale:(CGFloat)scale;

- (WDSTransformPipe *)newPipe;
- (WDSTransformPipe *)newPipeOnBackground;

@end
