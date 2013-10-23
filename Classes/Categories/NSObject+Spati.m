//
//  NSObject+Spati.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "NSObject+Spati.h"
#import <objc/runtime.h>
#import "WDSHTTPLink.h"


static char kSpatiAssociatedObjectKey;


@implementation NSObject (Spati)

- (id)objectForURL:(NSURL *)url link:(WDSHTTPLink *)link force:(BOOL)force block:(void (^)(id, BOOL))block
{
    return [self objectForRequest:[NSURLRequest requestWithURL:url] link:link force:force block:block];
}

- (id)objectForRequest:(NSURLRequest *)request link:(WDSHTTPLink *)link force:(BOOL)force block:(void (^)(id, BOOL))block
{
    return [self objectAndFetchForRequest:request link:link force:force block:^(id object, WDSHTTPFetch *fetch) {
        if (block) block(object, [fetch isCancelled]);
    }];
}

- (WDSHTTPFetch *)objectAndFetchForRequest:(NSURLRequest *)request link:(WDSHTTPLink *)link force:(BOOL)force block:(void (^)(id, WDSHTTPFetch *))block
{
    [self.Spati_associatedConnection cancel];
    id result = [link objectForRequest:request force:force block:block];
    if (result) self.Spati_associatedConnection = result;
    return result;
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
