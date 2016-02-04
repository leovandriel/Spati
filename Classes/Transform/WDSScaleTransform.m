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
    self = [super init];
    if (self) {
        _size = size;
    }
    return self;
}

- (id)transform:(UIImage *)image key:(id)key
{
    if (!image) return nil;
    
    CGSize newSize = _size;
    if (_percentScale) {
        newSize.width *= image.size.width;
        newSize.height *= image.size.height;
    }
    
    if (CGSizeEqualToSize(newSize, image.size)) return image;
    
    CGSize realSize = CGSizeMake(newSize.width * image.scale, newSize.height * image.scale);
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, realSize.width, realSize.height, 8, realSize.width * 4, space, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(space);
    
    CGContextDrawImage(context, CGRectMake(0, 0, realSize.width, realSize.height), image.CGImage);
    
    CGImageRef i = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *result = [UIImage imageWithCGImage:i scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(i);
    
    return result;
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
