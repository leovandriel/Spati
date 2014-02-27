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
#import "NWLCore.h"

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

- (NSString *)name
{
    return _cache.name;
}

#pragma mark Cache Cache

- (id)objectForKey:(NSString *)key dataOnly:(BOOL)dataOnly
{
    if (!key) return nil;
    if (dataOnly) {
        NWLogInfo(@"[%@] miss: memory-only", self.name);
        return nil;
    }
    id result = [_cache objectForKey:key];;
    if (result) {
        NWLogInfo(@"[%@] hit: %@ = %@", self.name, key, [result class]);
    } else {
        NWLogInfo(@"[%@] miss: %@", self.name, key);
    }
    return result;
}

- (BOOL)setObject:(id)object forKey:(NSString *)key dataOnly:(BOOL)dataOnly
{
    if (!key) return NO;
    if (dataOnly) {
        NWLogInfo(@"[%@] noset: memory-only", self.name);
        return NO;
    }
    if (object) {
        [_cache setObject:object forKey:key cost:(_costBlock ? _costBlock(object) : 0)];
        NWLogInfo(@"[%@] set: %@ = %@", self.name, key, [object class]);
    } else {
        [_cache removeObjectForKey:key];
        NWLogInfo(@"[%@] unset: %@", self.name, key);
    }
    return YES;
}

- (BOOL)removeObjectForKey:(NSString *)key
{
    if (!key) return NO;
    NWLogInfo(@"[%@] remove: %@", self.name, key);
    [_cache removeObjectForKey:key];
    return YES;
}

- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey
{
    if (!key || !toKey) return NO;
    id object = [_cache objectForKey:key];
    if (!object) {
        NWLogInfo(@"[%@] nomove: %@ -> %@", self.name, key, toKey);
        return NO;
    }
    NWLogInfo(@"[%@] move: %@ -> %@ = %@", self.name, key, toKey, [object class]);
    [_cache setObject:object forKey:toKey];
    [_cache removeObjectForKey:key];
    return YES;
}

- (BOOL)removeAllObjects
{
    NWLogInfo(@"[%@] remove-all", self.name);
    [_cache removeAllObjects];
    return YES;
}

@end
