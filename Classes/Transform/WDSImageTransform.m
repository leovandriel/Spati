//
//  WDSImageTransform.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSImageTransform.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif


@implementation WDSImageTransform

- (instancetype)init
{
    return [self initWithScale:0];
}

- (instancetype)initWithScale:(CGFloat)scale
{
    self = [super init];
    if (self) {
        _scale = scale;
        _jpegQuality = 1;
    }
    return self;
}

- (id)transform:(id)object key:(id)key
{
    if (!object) return nil;
    if (_mode == kWDSImageTransformModeDataToImage) {
#if TARGET_OS_IPHONE
        return [UIImage imageWithData:object scale:_scale];
#else
        return [[NSImage alloc] initWithData:object];
#endif
    } else {
        switch (_mode) {
#if TARGET_OS_IPHONE
            case kWDSImageTransformModeImageToPNG: return UIImagePNGRepresentation(object);
            case kWDSImageTransformModeImageToJPEG: return UIImageJPEGRepresentation(object, _jpegQuality);
#else
            case kWDSImageTransformModeImageToPNG: return [[object representations][0] representationUsingType:NSPNGFileType properties:nil];
            case kWDSImageTransformModeImageToJPEG: return [[object representations][0] representationUsingType:NSJPEGFileType properties:@{NSImageCompressionFactor:@(_jpegQuality)}];
#endif
            case kWDSImageTransformModeDataToImage: break;
        }
    }
    return nil;
}

- (WDSTransformPipe *)newPipe
{
    return [[WDSTransformPipe alloc] initWithTransform:self];
}

@end
