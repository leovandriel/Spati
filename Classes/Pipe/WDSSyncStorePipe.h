//
//  WDSSyncStorePipe.h
//  Spati
//
//  Copyright (c) 2014 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSPipe.h"


@protocol WDSSyncStore <NSObject>
- (id)objectForKey:(id)key;
- (id)setObject:(id)object forKey:(id)key;
@end


@interface WDSSyncStorePipe : WDSPipe

@property (nonatomic, readonly) id<WDSSyncStore> sync;
@property (nonatomic, strong) dispatch_queue_t queue;

- (instancetype)initWithSync:(id<WDSSyncStore>)sync;
- (instancetype)initWithSync:(id<WDSSyncStore>)sync onBackground:(BOOL)background;
- (instancetype)initWithSync:(id<WDSSyncStore>)sync queue:(dispatch_queue_t)queue;

@end
