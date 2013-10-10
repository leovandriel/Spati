//
//  WDSSyncCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSSyncCache.h"
#import "WDSParser.h"


@implementation WDSSyncCache

- (id)init
{
    return [self initWithWorkQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) doneQueue:dispatch_get_main_queue()];
}

- (id)initWithWorkQueue:(dispatch_queue_t)workQueue doneQueue:(dispatch_queue_t)doneQueue
{
    self = [super init];
    if (self) {
        _workQueue = workQueue;
        _doneQueue = doneQueue;
    }
    return self;
}

- (id)objectForKey:(NSString *)key
{
    return nil;
}

- (id)dataForKey:(NSString *)key
{
    return nil;
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
    dispatch_async(self.workQueue, ^{
        id result = [self objectForKey:key];
        if (block) dispatch_async(self.doneQueue, ^{ block(result); });
    });
}

- (void)dataForKey:(NSString *)key block:(void (^)(NSData *))block
{
    dispatch_async(self.workQueue, ^{
        id result = [self dataForKey:key];
        if (block) dispatch_async(self.doneQueue, ^{ block(result); });
    });
}

- (void)setObject:(id)object forKey:(NSString *)key block:(void(^)(BOOL))block
{
    dispatch_async(self.workQueue, ^{
        BOOL result = [self setObject:object forKey:key];
        if (block) dispatch_async(self.doneQueue, ^{ block(result); });
    });
}

- (void)setData:(NSData *)data forKey:(NSString *)key block:(void (^)(BOOL))block
{
    dispatch_async(self.workQueue, ^{
        BOOL result = [self setData:data forKey:key];
        if (block) dispatch_async(self.doneQueue, ^{ block(result); });
    });
}

- (void)removeObjectForKey:(NSString *)key block:(void(^)(BOOL))block
{
    dispatch_async(self.workQueue, ^{
        BOOL result = [self removeObjectForKey:key];
        if (block) dispatch_async(self.doneQueue, ^{ block(result); });
    });
}

- (void)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey block:(void(^)(BOOL))block
{
    dispatch_async(self.workQueue, ^{
        BOOL result = [self moveObjectForKey:key toKey:toKey];
        if (block) dispatch_async(self.doneQueue, ^{ block(result); });
    });
}

- (void)removeAllObjectsWithBlock:(void (^)(BOOL))block
{
    dispatch_async(self.workQueue, ^{
        BOOL result = [self removeAllObjects];
        if (block) dispatch_async(self.doneQueue, ^{ block(result); });
    });
}

@end
