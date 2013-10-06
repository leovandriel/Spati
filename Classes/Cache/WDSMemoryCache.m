//
//  WDSMemoryCache.m
//  Spati
//
//  Copyright (c) 2013 witdot. All rights reserved.
//

#import "WDSMemoryCache.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "WDSParser.h"


@implementation WDSMemoryCache

- (id)init
{
    return [self initWithParser:nil];
}

- (id)initWithParser:(WDSParser *)parser
{
    self = [super init];
    if (self) {
        _parser = parser;
        _cache = [[NSCache alloc] init];
#if TARGET_OS_IPHONE
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    }
    return self;
}

- (void)dealloc
{
#if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
}

#pragma mark Cache Cache

- (id)objectForKey:(NSString *)key
{
    if (!key) return nil;
    return [_cache objectForKey:key];
}

- (BOOL)setObject:(id)object forKey:(NSString *)key
{
    if (!key) return NO;
    if (object) [_cache setObject:object forKey:key cost:(NSUInteger)[_parser size:object]];
    else [_cache removeObjectForKey:key];
    return YES;
}

- (BOOL)removeObjectForKey:(NSString *)key
{
    if (!key) return NO;
    [_cache removeObjectForKey:key];
    return YES;
}

- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey
{
    if (!key || !toKey) return NO;
    id object = [_cache objectForKey:key];
    if (!object) return NO;
    [_cache setObject:object forKey:toKey];
    [_cache removeObjectForKey:key];
    return YES;
}

- (BOOL)removeAllObjects
{
    [_cache removeAllObjects];
    return YES;
}

@end
