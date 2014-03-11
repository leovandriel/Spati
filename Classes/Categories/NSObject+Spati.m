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


@implementation NSObject (Spati)

- (id<WDSCancel>)objectForKey:(id)key pipe:(WDSPipe *)pipe block:(void (^)(id, BOOL))block
{
    [self.Spati_associatedCancel cancel];
    id<WDSCancel> result = [pipe get:key block:block];
    if (result) self.Spati_associatedCancel = result;
    return result;
}

- (void)cancelObjectFetch
{
    [self.Spati_associatedCancel cancel];
    self.Spati_associatedCancel = nil;
}

- (BOOL)isObjectFetchCancelled
{
    return [self.Spati_associatedCancel isCancelled];
}

- (id<WDSCancel>)Spati_associatedCancel {
    return (id<WDSCancel>)objc_getAssociatedObject(self, &kSpatiAssociatedObjectKey);
}

- (void)setSpati_associatedCancel:(id<WDSCancel>)cancel {
    objc_setAssociatedObject(self, &kSpatiAssociatedObjectKey, cancel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
