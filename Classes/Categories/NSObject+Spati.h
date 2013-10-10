//
//  NSObject+Spati.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSHTTPLink;


@interface NSObject (Spati)

- (void)objectForKey:(NSString *)key link:(WDSHTTPLink *)link force:(BOOL)force block:(void (^)(id object, BOOL cancelled))block;
- (void)cancelObjectFetch;

@end

