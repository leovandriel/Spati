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
    self = [super init];
    if (self) {
        _sync = sync;
    }
    return self;
}

- (id<WDSCancel>)get:(id)key block:(void(^)(id, BOOL))block
{
    id object = [_sync objectForKey:key];
    if (object || !self.next) {
        if (block) block(object, NO);
        return nil;
    }
    return [self.next get:key block:^(id object, BOOL cancelled) {
        id stored = [_sync setObject:object forKey:key];
        if (block) block(stored, cancelled);
    }];
}

@end
