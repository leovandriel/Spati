//
//  WDSCache.h
//  Spati
//
//  Copyright (c) 2013 witdot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSParser;


@interface WDSCache : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) dispatch_queue_t workQueue;
@property (nonatomic, readonly) dispatch_queue_t doneQueue;

- (id)initWithName:(NSString *)name;

- (id)objectForKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;
- (BOOL)setObject:(id)object forKey:(NSString *)key;
- (BOOL)setData:(NSData *)data forKey:(NSString *)key;
- (BOOL)removeObjectForKey:(NSString *)key;
- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey;
- (BOOL)removeAllObjects;

- (void)objectForKey:(NSString *)key block:(void(^)(id object))block;
- (void)dataForKey:(NSString *)key block:(void(^)(NSData *data))block;
- (void)setObject:(id)object forKey:(NSString *)key block:(void(^)(BOOL done))block;
- (void)setData:(NSData *)data forKey:(NSString *)key block:(void(^)(BOOL done))block;
- (void)removeObjectForKey:(NSString *)key block:(void(^)(BOOL done))block;
- (void)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey block:(void(^)(BOOL done))block;
- (void)removeAllObjectsWithBlock:(void(^)(BOOL done))block;

@end
