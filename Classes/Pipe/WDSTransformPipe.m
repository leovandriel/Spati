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

- (instancetype)initWithTransform:(id<WDSTransform>)transform background:(BOOL)background
{
    dispatch_queue_t queue = background ? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) : nil;
    return [self initWithTransform:transform queue:queue];
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
    WDSMultiCancel *result = [[WDSMultiCancel alloc] init];
    id<WDSCancel> cancel = [self.next get:key block:^(id object, WDSStatus status) {
        if (status == WDSStatusSuccess) {
            if (_queue) {
                [result addCancel:[[WDSMultiCancel alloc] init]]; // HACK: so there's something in it
                dispatch_async(_queue, ^{
                    if (result.isCancelled) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (block) block(nil, WDSStatusCancelled);
                        });
                    } else {
                        id transformed = [_transform transform:object key:key];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (result.isCancelled) {
                                if (block) block(nil, WDSStatusCancelled);
                            } else {
                                if (block) block(transformed, status);
                            }
                        });
                    }
                });
            } else {
                id transformed = [_transform transform:object key:key];
                if (block) block(transformed, status);
            }
        } else {
            if (block) block(object, status);
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
