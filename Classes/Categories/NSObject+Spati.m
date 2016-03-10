//
//  NSObject+Spati.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "NSObject+Spati.h"
#import <objc/runtime.h>
#import "WDSPipe.h"


static char kSpatiAssociatedObjectKey;


@interface WDSAssociatedContainer : NSObject
@property (nonatomic, strong) id<WDSCancel> cancel;
@property (nonatomic, strong) id key;
@property (nonatomic, weak) WDSPipe *pipe;
@property (nonatomic, copy) void (^block)(id object, WDSStatus status);
- (instancetype)initWithKey:(id)key pipe:(WDSPipe *)pipe block:(void (^)(id, WDSStatus))block;
- (BOOL)hasEqualKey:(id)key pipe:(WDSPipe *)pipe;
- (void)replaceBlock:(void (^)(id, WDSStatus))block;
@end


@implementation NSObject (Spati)

- (id<WDSCancel>)objectForKey:(id)key pipe:(WDSPipe *)pipe block:(void (^)(id, WDSStatus))block
{
    WDSAssociatedContainer *container = self.Spati_associatedContainer;
    if (container.cancel && [container hasEqualKey:key pipe:pipe]) {
        [container replaceBlock:block];
        return container.cancel;
    }
    [container.cancel cancel];
    container = [[WDSAssociatedContainer alloc] initWithKey:key pipe:pipe block:block];
    [self Spati_setAssociatedContainer:container];
    id<WDSCancel> result = [pipe get:key block:^(id object, WDSStatus status) {
        void (^b)(id, WDSStatus) = container.block;
        [self Spati_setAssociatedContainer:nil];
        if (b) b(object, status);
    }];
    container.cancel = result;
    return result;
}

- (void)cancelObjectFetch
{
    WDSAssociatedContainer *container = self.Spati_associatedContainer;
    [container.cancel cancel];
}

- (BOOL)isObjectFetchCancelled
{
    WDSAssociatedContainer *container = self.Spati_associatedContainer;
    return [container.cancel isCancelled];
}

- (WDSAssociatedContainer *)Spati_associatedContainer
{
    return (WDSAssociatedContainer *)objc_getAssociatedObject(self, &kSpatiAssociatedObjectKey);
}

- (void)Spati_setAssociatedContainer:(WDSAssociatedContainer *)container
{
    objc_setAssociatedObject(self, &kSpatiAssociatedObjectKey, container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation WDSAssociatedContainer

- (instancetype)initWithKey:(id)key pipe:(WDSPipe *)pipe block:(void (^)(id, WDSStatus))block
{
    self = [super init];
    if (self) {
        _key = key;
        _pipe = pipe;
        _block = [block copy];
    }
    return self;
}

- (BOOL)hasEqualKey:(id)key pipe:(WDSPipe *)pipe
{
    if (key != _key && (key || _key) && !([key isKindOfClass:NSString.class] ? [key isEqualToString:_key] : [key isEqual:_key])) {
        return NO;
    }
    if (pipe != _pipe && (pipe || _pipe) && ![pipe isEqual:_pipe]) {
        return NO;
    }
    return YES;
}

- (void)replaceBlock:(void (^)(id, WDSStatus))block
{
    void (^b)(id, WDSStatus) = _block;
    _block = block;
    if (b) b(nil, WDSStatusCancelled);
}

@end
