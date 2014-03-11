//
//  WDSAsyncStorePipe
//  Spati
//
//  Copyright (c) 2014 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSPipe.h"


@protocol WDSAsyncStore <NSObject>
- (id<WDSCancel>)objectForKey:(id)key block:(void(^)(id object, BOOL cancelled))block;
- (void)setObject:(id)object forKey:(id)key block:(void(^)(void))block;
@end


@interface WDSAsyncStorePipe : WDSPipe

@property (nonatomic, readonly) id<WDSAsyncStore> async;

- (instancetype)initWithAsync:(id<WDSAsyncStore>)async;

@end
