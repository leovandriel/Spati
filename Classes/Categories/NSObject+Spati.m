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

- (void)objectForURL:(NSURL *)url link:(WDSHTTPLink *)link force:(BOOL)force block:(void (^)(id, BOOL))block
{
    [self objectForRequest:[NSURLRequest requestWithURL:url] link:link force:force block:block];
}

- (void)objectForRequest:(NSURLRequest *)request link:(WDSHTTPLink *)link force:(BOOL)force block:(void (^)(id, BOOL))block
{
    [self.Spati_associatedConnection cancel];
    self.Spati_associatedConnection = [link objectForRequest:request force:force block:block];
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
