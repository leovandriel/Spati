//
//  WDSCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSCache.h"


@implementation WDSCache

- (void)objectForKey:(NSString *)key block:(void(^)(id))block
{
    if (block) block(nil);
}

- (void)dataForKey:(NSString *)key block:(void (^)(NSData *))block
{
    if (block) block(nil);
}

- (void)setObject:(id)object forKey:(NSString *)key block:(void(^)(BOOL))block
{
    if (block) block(NO);
}

- (void)setData:(NSData *)data forKey:(NSString *)key block:(void (^)(BOOL))block
{
    if (block) block(NO);
}

- (void)removeObjectForKey:(NSString *)key block:(void(^)(BOOL))block
{
    if (block) block(YES);
}

- (void)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey block:(void(^)(BOOL))block
{
    if (block) block(YES);
}

- (void)removeAllObjectsWithBlock:(void (^)(BOOL))block
{
    if (block) block(YES);
}

@end
