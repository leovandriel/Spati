//
//  WDSAsyncStorePipe.m
//  Spati
//
//  Copyright (c) 2014 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSAsyncStorePipe.h"


@interface WDSMultiCancel : NSObject<WDSCancel>
- (void)addCancel:(id<WDSCancel>)cancel;
@end


@implementation WDSAsyncStorePipe

- (instancetype)initWithAsync:(id<WDSAsyncStore>)async
{
    self = [super init];
    if (self) {
        _async = async;
    }
    return self;
}

- (id<WDSCancel>)get:(id)key block:(void(^)(id, BOOL))block
{
    WDSMultiCancel *result = [[WDSMultiCancel alloc] init];
    id<WDSCancel> cancel = [_async objectForKey:key block:^(id object, BOOL cancelled) {
        if (object || cancelled || !self.next) {
            if (block) block(object, cancelled);
        } else {
            id<WDSCancel> cancel = [self.next get:key block:^(id object, BOOL cancelled) {
                [_async setObject:object forKey:key block:^{
                    if (block) block(object, cancelled);
                }];
            }];
            if (cancel) [result addCancel:cancel];
        }
    }];
    if (cancel) [result addCancel:cancel];
    return result;
}

@end


@implementation WDSMultiCancel {
    NSMutableArray *_cancels;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cancels = @[].mutableCopy;
    }
    return self;
}

- (void)addCancel:(id<WDSCancel>)cancel
{
    if (_cancels) {
        [_cancels addObject:cancel];
    } else {
        [cancel cancel];
    }
}

- (void)cancel
{
    for (id<WDSCancel> cancel in _cancels) {
        [cancel cancel];
    }
    _cancels = nil;
}

- (BOOL)isCancelled
{
    if (!_cancels) return YES;
    for (id<WDSCancel> cancel in _cancels) {
        if ([cancel isCancelled]) {
            return YES;
        }
    }
    return NO;
}

@end
