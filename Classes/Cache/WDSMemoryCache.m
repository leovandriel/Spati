//
//  WDSMemoryCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSMemoryCache.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "WDSParser.h"


@implementation WDSMemoryCache

- (id)init
{
    return [self initWithName:@"WDSMemoryCache"];
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
        _cache.name = name;
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

- (id)objectForKey:(NSString *)key dataOnly:(BOOL)dataOnly
{
    if (!key || dataOnly) return nil;
    return [_cache objectForKey:key];
}

- (BOOL)setObject:(id)object forKey:(NSString *)key dataOnly:(BOOL)dataOnly
{
    if (!key || dataOnly) return NO;
    if (object) [_cache setObject:object forKey:key cost:(_costBlock ? _costBlock(object) : 0)];
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
