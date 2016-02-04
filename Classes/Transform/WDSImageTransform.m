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
        _maxImageSize = 4096;
    }
    return self;
}

- (id)transform:(id)object key:(id)key
{
    if (!object) return nil;
    if (_mode == kWDSImageTransformModeDataToImage) {
#if TARGET_OS_IPHONE
        UIImage *image = [UIImage imageWithData:object scale:_scale];
#else
        NSImage *image = [[NSImage alloc] initWithData:object];
#endif
        if (image.size.width > _maxImageSize || image.size.height > _maxImageSize) {
            image = nil;
        }
        return image;
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

- (WDSTransformPipe *)newPipeOnBackground
{
    return [[WDSTransformPipe alloc] initWithTransform:self onBackground:true];
}

@end
