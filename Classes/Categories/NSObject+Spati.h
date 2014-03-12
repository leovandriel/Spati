//
//  NSObject+Spati.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSPipe;
@protocol WDSCancel;


@interface NSObject (Spati)

- (id<WDSCancel>)objectForKey:(id)key pipe:(WDSPipe *)pipe block:(void (^)(id object, BOOL isCancelled))block;
- (void)cancelObjectFetch;
- (BOOL)isObjectFetchCancelled;

@end

