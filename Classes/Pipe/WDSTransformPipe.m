//
//  WDSTransformPipe.m
//  Spati
//
//  Copyright (c) 2014 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSTransformPipe.h"


@implementation WDSTransformPipe

- (instancetype)initWithTransform:(id<WDSTransform>)transform
{
    return [self initWithTransform:transform queue:nil];
}

- (instancetype)initWithTransform:(id<WDSTransform>)transform queue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        _transform = transform;
        _queue = queue;
    }
    return self;
}

- (id<WDSCancel>)get:(id)key block:(void(^)(id, WDSStatus))block
{
    return [self.next get:key block:^(id object, WDSStatus status) {
        if (status == WDSStatusSuccess) {
            if (_queue) {
                dispatch_async(_queue, ^{
                    id transformed = [_transform transform:object key:key];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) block(transformed, status);
                    });
                });
            } else {
                id transformed = [_transform transform:object key:key];
                if (block) block(transformed, status);
            }
        } else {
            if (block) block(object, status);
        }
    }];
}

@end
