//
//  NSObject+Spati.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSPipe.h"


@interface NSObject (Spati)

- (id<WDSCancel>)objectForKey:(id)key pipe:(WDSPipe *)pipe block:(void (^)(id object, WDSStatus status))block;
- (void)cancelObjectFetch;
- (BOOL)isObjectFetchCancelled;

@end

