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
    self = [super init];
    if (self) {
        _transform = transform;
    }
    return self;
}

- (id<WDSCancel>)get:(id)key block:(void(^)(id, WDSStatus))block
{
    return [self.next get:key block:^(id object, WDSStatus status) {
        if (status == WDSStatusSuccess) {
            id transformed = [_transform transform:object key:key];
            if (block) block(transformed, status);
        } else {
            if (block) block(object, status);
        }
    }];
}

@end
