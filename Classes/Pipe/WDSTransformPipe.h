//
//  WDSTransformPipe
//  Spati
//
//  Copyright (c) 2014 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSPipe.h"


@protocol WDSTransform <NSObject>
- (id)transform:(id)object key:(id)key;
@end


@interface WDSTransformPipe : WDSPipe

@property (nonatomic, readonly) id<WDSTransform> transform;
@property (nonatomic, strong) dispatch_queue_t queue;

- (instancetype)initWithTransform:(id<WDSTransform>)transform;
- (instancetype)initWithTransform:(id<WDSTransform>)transform background:(BOOL)background;
- (instancetype)initWithTransform:(id<WDSTransform>)transform queue:(dispatch_queue_t)queue;

@end
