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

- (instancetype)initWithScale:(CGFloat)scale
{
    self = [super init];
    if (self) {
        _scale = scale;
    }
    return self;
}

- (id)transform:(NSData *)data
{
    if (!data.length) return nil;
#if TARGET_OS_IPHONE
    return [UIImage imageWithData:data scale:_scale];
#else
    return [[NSImage alloc] initWithData:data];
#endif
}

- (WDSTransformPipe *)newPipe
{
    return [[WDSTransformPipe alloc] initWithTransform:self];
}

@end
