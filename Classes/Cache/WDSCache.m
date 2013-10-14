//
//  WDSCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSCache.h"


@implementation WDSCache

- (void)objectForKey:(NSString *)key dataOnly:(BOOL)dataOnly block:(void(^)(id))block
{
    if (block) block(nil);
}

- (void)setObject:(id)object forKey:(NSString *)key dataOnly:(BOOL)dataOnly block:(void(^)(BOOL))block
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
