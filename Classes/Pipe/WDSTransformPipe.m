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

- (id<WDSCancel>)get:(id)key block:(void(^)(id, BOOL))block
{
    return [self.next get:key block:^(id object, BOOL cancelled) {
        id transformed = [_transform transform:object key:key];
        if (block) block(transformed, cancelled);
    }];
}

@end
