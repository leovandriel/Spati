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
- (BOOL)hasEqualKey:(id)key pipe:(WDSPipe *)pipe;
- (void)setupWithKey:(id)key pipe:(WDSPipe *)pipe cancel:(id<WDSCancel>)cancel block:(void (^)(id, WDSStatus))block;
- (void)replaceBlock:(void (^)(id, WDSStatus))block;
- (void)clear;
- (void)cancelAndClear;
@end


@implementation NSObject (Spati)

- (id<WDSCancel>)objectForKey:(id)key pipe:(WDSPipe *)pipe block:(void (^)(id, WDSStatus))block
{
    WDSAssociatedContainer *container = self.Spati_associatedContainer;
    if ([container hasEqualKey:key pipe:pipe] && container.cancel) {
        [container replaceBlock:block];
        return container.cancel;
    }
    [container setupWithKey:key pipe:pipe cancel:nil block:block];
    id<WDSCancel> result = [pipe get:key block:^(id object, WDSStatus status) {
        void (^b)(id, WDSStatus) = container.block;
        [container clear];
        if (b) b(object, status);
    }];
    if (result) container.cancel = result;
    return result;
}

- (void)cancelObjectFetch
{
    [self.Spati_associatedContainer cancelAndClear];
}

- (BOOL)isObjectFetchCancelled
{
    return [self.Spati_associatedContainer.cancel isCancelled];
}

- (WDSAssociatedContainer *)Spati_associatedContainer {
    WDSAssociatedContainer *result = (WDSAssociatedContainer *)objc_getAssociatedObject(self, &kSpatiAssociatedObjectKey);
    if (!result) {
        result = [[WDSAssociatedContainer alloc] init];
        objc_setAssociatedObject(self, &kSpatiAssociatedObjectKey, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

@end

@implementation WDSAssociatedContainer

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

- (void)setupWithKey:(id)key pipe:(WDSPipe *)pipe cancel:(id<WDSCancel>)cancel block:(void (^)(id, WDSStatus))block
{
    [_cancel cancel];
    _key = key;
    _pipe = pipe;
    _cancel = cancel;
    _block = block;
}

- (void)replaceBlock:(void (^)(id, WDSStatus))block
{
    void (^b)(id, WDSStatus) = _block;
    _block = block;
    if (b) b(nil, WDSStatusCancelled);
}

- (void)cancelAndClear
{
    [_cancel cancel];
    [self clear];
}

- (void)clear
{
    _key = nil;
    _pipe = nil;
    _cancel = nil;
    _block = nil;
}

@end
