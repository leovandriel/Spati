//
//  WDSScaleTransform.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSScaleTransform.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@implementation WDSScaleTransform

- (instancetype)initWithSize:(CGSize)size
{
    return [self initWithSize:size mode:UIViewContentModeScaleAspectFill];
}

- (instancetype)initWithSize:(CGSize)size mode:(UIViewContentMode)mode
{
    self = [super init];
    if (self) {
        _size = size;
        _mode = mode;
    }
    return self;
}

- (id)transform:(UIImage *)image key:(id)key
{
    if (!image) return nil;
    
    CGRect rect = [self rectForCropScaleWithSize:image.size];
    if (CGSizeEqualToSize(rect.size, image.size)) return image;
    
    CGSize realSize = CGSizeMake(_size.width * image.scale, _size.height * image.scale);

    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, realSize.width, realSize.height, 8, realSize.width * 4, space, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(space);
    
    CGRect realRect = CGRectMake(rect.origin.x * image.scale, rect.origin.y * image.scale, rect.size.width * image.scale, rect.size.height * image.scale);
    CGContextDrawImage(context, realRect, image.CGImage);
    
    CGImageRef i = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *result = [UIImage imageWithCGImage:i scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(i);
    
    return result;
}

- (CGRect)rectForCropScaleWithSize:(CGSize)s
{
    switch (_mode) {
        case UIViewContentModeScaleToFill: return CGRectMake(0.0f, 0.0f, _size.width, _size.height);
        case UIViewContentModeScaleAspectFit: return (_size.width * s.height <= _size.height * s.width) ? CGRectMake(0.0f, (_size.height - _size.width * s.height / s.width) / 2.0f, _size.width, _size.width * s.height / s.width) : CGRectMake((_size.width - _size.height * s.width / s.height) / 2.0f, 0.0f, _size.height * s.width / s.height, _size.height);
        case UIViewContentModeScaleAspectFill: return (_size.width * s.height >= _size.height * s.width) ? CGRectMake(0.0f, (_size.height - _size.width * s.height / s.width) / 2.0f, _size.width, _size.width * s.height / s.width) : CGRectMake((_size.width - _size.height * s.width / s.height) / 2.0f, 0.0f, _size.height * s.width / s.height, _size.height);
        case UIViewContentModeRedraw: return CGRectMake(0.0f, 0.0f, _size.width, _size.height);
        case UIViewContentModeCenter: return CGRectMake((_size.width - s.width) / 2.0f, (_size.height - s.height) / 2.0f, s.width, s.height);
        case UIViewContentModeTop: return CGRectMake((_size.width - s.width) / 2.0f, 0.0f, s.width, s.height);
        case UIViewContentModeBottom: return CGRectMake((_size.width - s.width) / 2.0f, _size.height - s.height, s.width, s.height);
        case UIViewContentModeLeft: return CGRectMake(0.0f, (_size.height - s.height) / 2.0f, s.width, s.height);
        case UIViewContentModeRight: return CGRectMake(_size.width - s.width, (_size.height - s.height) / 2.0f, s.width, s.height);
        case UIViewContentModeTopLeft: return CGRectMake(0.0f, 0.0f, s.width, s.height);
        case UIViewContentModeTopRight: return CGRectMake(_size.width - s.width, 0.0f, s.width, s.height);
        case UIViewContentModeBottomLeft: return CGRectMake(0.0f, _size.height - s.height, s.width, s.height);
        case UIViewContentModeBottomRight: return CGRectMake(_size.width - s.width, _size.height - s.height, s.width, s.height);
    }
    return CGRectNull;
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

#endif // TARGET_OS_IPHONE
