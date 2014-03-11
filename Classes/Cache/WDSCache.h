//
//  WDSCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSSyncStorePipe.h"


@interface WDSCache : NSObject<WDSSyncStore>

- (id)objectForKey:(NSString *)key;
- (id)setObject:(id)object forKey:(NSString *)key;
- (BOOL)removeObjectForKey:(NSString *)key;
- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey;
- (BOOL)removeAllObjects;

- (NSString *)name;
- (WDSSyncStorePipe *)newPipe;

@end
