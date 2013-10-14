//
//  NSObject+Spati.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSHTTPLink;


@interface NSObject (Spati)

- (id)objectForURL:(NSURL *)url link:(WDSHTTPLink *)link force:(BOOL)force block:(void (^)(id, BOOL))block;
- (id)objectForRequest:(NSURLRequest *)request link:(WDSHTTPLink *)link force:(BOOL)force block:(void (^)(id, BOOL))block;
- (void)cancelObjectFetch;

@end

