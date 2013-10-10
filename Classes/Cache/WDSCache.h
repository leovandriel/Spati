//
//  WDSCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WDSCache : NSObject

- (void)objectForKey:(NSString *)key block:(void(^)(id object))block;
- (void)dataForKey:(NSString *)key block:(void(^)(NSData *data))block;
- (void)setObject:(id)object forKey:(NSString *)key block:(void(^)(BOOL done))block;
- (void)setData:(NSData *)data forKey:(NSString *)key block:(void(^)(BOOL done))block;
- (void)removeObjectForKey:(NSString *)key block:(void(^)(BOOL done))block;
- (void)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey block:(void(^)(BOOL done))block;
- (void)removeAllObjectsWithBlock:(void(^)(BOOL done))block;

@end
