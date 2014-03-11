//
//  WDSPipe.m
//  Spati
//
//  Copyright (c) 2014 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSPipe.h"
#import "NWLCore.h"

@implementation WDSPipe

- (instancetype)init
{
    return [self initWithName:self.class.description];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = [name copy];
    }
    return self;
}

- (id<WDSCancel>)get:(id)key block:(void(^)(id, BOOL))block
{
    if (self.next) {
        return [self.next get:key block:block];
    } else {
        NWLogWarn(@"Expecting non-nil next on pipe");
    }
    return nil;
}

#pragma mark - Linked list

- (void)appendPipe:(WDSPipe *)pipe
{
    if (!self.next) {
        self.next = pipe;
    } else {
        [self.next appendPipe:pipe];
    }
}

- (void)insertPipe:(WDSPipe *)pipe afterPipe:(WDSPipe *)after
{
    if ([self isEqual:after]) {
        [self insertPipe:pipe];
    } else {
        [self.next insertPipe:pipe afterPipe:after];
    }
}

- (void)insertPipe:(WDSPipe *)pipe beforePipe:(WDSPipe *)before
{
    if ([self.next isEqual:before]) {
        [self insertPipe:pipe];
    } else {
        [self.next insertPipe:pipe beforePipe:before];
    }
}

- (void)insertPipe:(WDSPipe *)pipe
{
    [pipe appendPipe:self.next];
    self.next = pipe;
}

#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p name:%@>", self.class, self, self.name];
}

@end
