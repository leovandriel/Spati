//
//  WDSCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WDSCache : NSObject

- (void)objectForKey:(NSString *)key dataOnly:(BOOL)dataOnly block:(void(^)(id object))block;
- (void)setObject:(id)object forKey:(NSString *)key dataOnly:(BOOL)dataOnly block:(void(^)(BOOL done))block;
- (void)removeObjectForKey:(NSString *)key block:(void(^)(BOOL done))block;
- (void)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey block:(void(^)(BOOL done))block;
- (void)removeAllObjectsWithBlock:(void(^)(BOOL done))block;

@end
