//
//  WDSDiskImageNamedCache.m
//  Spati
//
//  Copyright (c) 2013 witdot. All rights reserved.
//

#import "WDSDiskImageNamedCache.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif


@interface WDSDiskCache ()
- (NSString *)fileForKey:(NSString *)key;
- (BOOL)expirationOfFile:(NSString *)file;
@end


@implementation WDSDiskImageNamedCache

- (NSString *)relative:(NSString *)file
{
    return [[@"../Library/Caches" stringByAppendingPathComponent:self.name?:@"spati"] stringByAppendingPathComponent:file];
}

- (id)objectForKey:(NSString *)key
{
    if (!key) return nil;
    NSString *file = [self fileForKey:key];
    if ([self expirationOfFile:file]) return nil;
#if TARGET_OS_IPHONE
    return [UIImage imageNamed:[self relative:file]];
#else
    return [NSImage imageNamed:[self relative:file]];
#endif
}

@end
