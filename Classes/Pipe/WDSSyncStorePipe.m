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

- (id<WDSCancel>)get:(id)key block:(void(^)(id, WDSStatus))block
{
    id object = [_sync objectForKey:key];
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
            if (block) block(nil, status);
        }
    }];
}

@end
