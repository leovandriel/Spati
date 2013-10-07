//
//  NSObject+Spati.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "NSObject+Spati.h"
#import <objc/runtime.h>
#import "WDSHTTPCache.h"


static char kSpatiAssociatedObjectKey;


@implementation NSObject (Spati)

- (void)objectForKey:(NSString *)key cache:(WDSHTTPCache *)cache force:(BOOL)force block:(void (^)(id, BOOL))block
{
    [self.Spati_associatedConnection cancel];
    self.Spati_associatedConnection = [cache objectForKey:key force:force block:block];
}

- (void)cancelObjectFetch
{
    [self.Spati_associatedConnection cancel];
    self.Spati_associatedConnection = nil;
}

- (id)Spati_associatedConnection {
    return (id)objc_getAssociatedObject(self, &kSpatiAssociatedObjectKey);
}

- (void)setSpati_associatedConnection:(id)connection {
    objc_setAssociatedObject(self, &kSpatiAssociatedObjectKey, connection, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
