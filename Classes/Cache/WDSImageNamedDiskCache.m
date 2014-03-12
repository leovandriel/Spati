//
//  WDSImageNamedDiskCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSImageNamedDiskCache.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "NWLCore.h"

@interface WDSDiskCache ()
- (NSString *)filenameForKey:(NSString *)key;
- (BOOL)expirationOfFile:(NSString *)file;
@end


@implementation WDSImageNamedDiskCache

- (NSString *)relative:(NSString *)file
{
    return [[@"../Library/Caches" stringByAppendingPathComponent:self.name] stringByAppendingPathComponent:file];
}

- (UIImage *)imageNamedForKey:(NSString *)key
{
    NWAssertMainThread();
    if (!key) return nil;
    NSString *file = [self filenameForKey:key];
    if ([self expirationOfFile:file]) return nil;
#if TARGET_OS_IPHONE
    return [UIImage imageNamed:[self relative:file]];
#else
    return [NSImage imageNamed:[self relative:file]];
#endif
}

- (id)objectForKey:(NSString *)key
{
    return [self imageNamedForKey:key];
}

@end
