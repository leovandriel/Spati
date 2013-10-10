//
//  NSObject+Spati.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSHTTPLink;


@interface NSObject (Spati)

- (void)objectForURL:(NSURL *)url link:(WDSHTTPLink *)link force:(BOOL)force block:(void (^)(id, BOOL))block;
- (void)objectForRequest:(NSURLRequest *)request link:(WDSHTTPLink *)link force:(BOOL)force block:(void (^)(id, BOOL))block;
- (void)cancelObjectFetch;

@end

