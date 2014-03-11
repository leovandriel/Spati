//
//  WDSTransformPipe
//  Spati
//
//  Copyright (c) 2014 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSPipe.h"


@protocol WDSTransform <NSObject>
- (id)transform:(id)object;
@end


@interface WDSTransformPipe : WDSPipe

@property (nonatomic, readonly) id<WDSTransform> transform;

- (instancetype)initWithTransform:(id<WDSTransform>)transform;

@end
