//
//  WDSImageParser.m
//  Spati
//
//  Copyright (c) 2013 witdot. All rights reserved.
//

#import "WDSImageParser.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif


@implementation WDSImageParser

- (id)initWithType:(WDSParserImageType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

#pragma mark Cache Parser

- (id)parse:(NSData *)data
{
    if (!data.length) return nil;
#if TARGET_OS_IPHONE
    return [UIImage imageWithData:data];
#else
    return [[NSImage  alloc] initWithData:data];
#endif
}

- (NSData *)serialize:(id)value
{
    if (!value) return nil;
    switch (_type) {
#if TARGET_OS_IPHONE
        case kWDSParserImageTypePNG: return UIImagePNGRepresentation(value);
        case kWDSParserImageTypeJPEG: return UIImageJPEGRepresentation(value, 1.0);
#else
        case kWDSParserImageTypePNG: return [[value representations][0] representationUsingType:NSPNGFileType properties:nil];
        case kWDSParserImageTypeJPEG: return [[value representations][0] representationUsingType:NSJPEGFileType properties:@{NSImageCompressionFactor:@1.f}];
#endif
        case kWDSParserImageTypeNone: break;
    }
    return nil;
}

- (unsigned long long)size:(id)value
{
    CGSize size = [value size];
#if TARGET_OS_IPHONE
    CGFloat scale = [(UIImage *)value scale];
#else
    CGFloat scale = 1.f;
#endif
    return (unsigned long long)(size.width * size.height * scale * scale);
}

@end
