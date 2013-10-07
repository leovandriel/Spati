//
//  WDSCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSCache.h"
#import "WDSParser.h"


@implementation WDSCache

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (dispatch_queue_t)workQueueOrDefault
{
    return _workQueue ?: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (dispatch_queue_t)doneQueueOrDefault
{
    return _doneQueue ?: dispatch_get_main_queue();
}

- (id)objectForKey:(NSString *)key
{
    return NO;
}

- (id)dataForKey:(NSString *)key
{
    return NO;
}

- (BOOL)setObject:(id)object forKey:(NSString *)key
{
    return NO;
}

- (BOOL)setData:(NSData *)data forKey:(NSString *)key
{
    return NO;
}

- (BOOL)removeObjectForKey:(NSString *)key
{
    return YES;
}

- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey
{
    return YES;
}

- (BOOL)removeAllObjects
{
    return YES;
}

- (void)objectForKey:(NSString *)key block:(void(^)(id))block
{
    dispatch_async(self.workQueueOrDefault, ^{
        id result = [self objectForKey:key];
        if (block) dispatch_async(self.doneQueueOrDefault, ^{ block(result); });
    });
}

- (void)dataForKey:(NSString *)key block:(void (^)(NSData *))block
{
    dispatch_async(self.workQueueOrDefault, ^{
        id result = [self dataForKey:key];
        if (block) dispatch_async(self.doneQueueOrDefault, ^{ block(result); });
    });
}

- (void)setObject:(id)object forKey:(NSString *)key block:(void(^)(BOOL))block
{
    dispatch_async(self.workQueueOrDefault, ^{
        BOOL result = [self setObject:object forKey:key];
        if (block) dispatch_async(self.doneQueueOrDefault, ^{ block(result); });
    });
}

- (void)setData:(NSData *)data forKey:(NSString *)key block:(void (^)(BOOL))block
{
    dispatch_async(self.workQueueOrDefault, ^{
        BOOL result = [self setData:data forKey:key];
        if (block) dispatch_async(self.doneQueueOrDefault, ^{ block(result); });
    });
}

- (void)removeObjectForKey:(NSString *)key block:(void(^)(BOOL))block
{
    dispatch_async(self.workQueueOrDefault, ^{
        BOOL result = [self removeObjectForKey:key];
        if (block) dispatch_async(self.doneQueueOrDefault, ^{ block(result); });
    });
}

- (void)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey block:(void(^)(BOOL))block
{
    dispatch_async(self.workQueueOrDefault, ^{
        BOOL result = [self moveObjectForKey:key toKey:toKey];
        if (block) dispatch_async(self.doneQueueOrDefault, ^{ block(result); });
    });
}

- (void)removeAllObjectsWithBlock:(void (^)(BOOL))block
{
    dispatch_async(self.workQueueOrDefault, ^{
        BOOL result = [self removeAllObjects];
        if (block) dispatch_async(self.doneQueueOrDefault, ^{ block(result); });
    });
}

@end
