//
//  NSObject+Spati.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSHTTPCache;


@interface NSObject (Spati)

- (void)objectForKey:(NSString *)key cache:(WDSHTTPCache *)cache force:(BOOL)force block:(void (^)(id object, BOOL cancelled))block;
- (void)cancelObjectFetch;

@end

