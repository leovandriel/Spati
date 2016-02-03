//
//  WDSAsyncStorePipe.m
//  Spati
//
//  Copyright (c) 2014 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSAsyncStorePipe.h"


@implementation WDSAsyncStorePipe

- (instancetype)initWithAsync:(id<WDSAsyncStore>)async
{
    self = [super init];
    if (self) {
        _async = async;
    }
    return self;
}

- (id<WDSCancel>)get:(id)key block:(void(^)(id, WDSStatus))block
{
    WDSMultiCancel *result = [[WDSMultiCancel alloc] init];
    id<WDSCancel> cancel = [_async objectForKey:key block:^(id object, WDSStatus status) {
        if (status != WDSStatusNotFound || !self.next) {
            if (block) block(object, status);
        } else {
            id<WDSCancel> cancel = [self.next get:key block:^(id object, WDSStatus status) {
                if (status == WDSStatusSuccess) {
                    [_async setObject:object forKey:key block:^{
                        if (block) block(object, status);
                    }];
                } else {
                    if (block) block(object, status);
                }
            }];
            if (cancel) [result addCancel:cancel];
        }
    }];
    if (cancel) {
        [result addCancel:cancel];
    }
    if (result.isEmpty) {
        return nil;
    }
    return result;
}

@end
