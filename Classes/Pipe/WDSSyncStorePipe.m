//
//  WDSSyncStorePipe.m
//  Spati
//
//  Copyright (c) 2014 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSSyncStorePipe.h"


@implementation WDSSyncStorePipe

- (instancetype)initWithSync:(id<WDSSyncStore>)sync
{
    return [self initWithSync:sync queue:nil];
}

- (instancetype)initWithSync:(id<WDSSyncStore>)sync onBackground:(BOOL)background
{
    dispatch_queue_t queue = background ? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) : nil;
    return [self initWithSync:sync queue:queue];
}

- (instancetype)initWithSync:(id<WDSSyncStore>)sync queue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        _sync = sync;
        _queue = queue;
    }
    return self;
}

- (id<WDSCancel>)get:(id)key block:(void(^)(id, WDSStatus))block
{
    if (_queue) {
        WDSMultiCancel *result = [[WDSMultiCancel alloc] init];
        dispatch_async(_queue, ^{
            if (result.isCancelled) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block(nil, WDSStatusCancelled);
                });
            } else {
                id object = [_sync objectForKey:key];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (result.isCancelled) {
                        if (block) block(nil, WDSStatusCancelled);
                    } else {
                        id<WDSCancel> cancel = [self get:key object:object block:block];
                        if (cancel) {
                            [result addCancel:cancel];
                        }
                    }
                });
            }
        });
        return result;
    } else {
        id object = [_sync objectForKey:key];
        return [self get:key object:object block:block];
    }
}

- (id<WDSCancel>)get:(id)key object:(id)object block:(void(^)(id, WDSStatus))block
{
    if (object) {
        if (block) block(object, WDSStatusSuccess);
        return nil;
    }
    if (!self.next) {
        if (block) block(object, WDSStatusNotFound);
        return nil;
    }
    return [self.next get:key block:^(id object, WDSStatus status) {
        if (status == WDSStatusSuccess) {
            id stored = [_sync setObject:object forKey:key];
            if (block) block(stored, status);
        } else {
            if (block) block(nil, status); // TODO: why nil; shouldn't we just return the object?
        }
    }];
}

@end
