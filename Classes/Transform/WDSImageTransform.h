//
//  WDSImageTransform.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSTransformPipe.h"


@interface WDSImageTransform : NSObject<WDSTransform>

@property (nonatomic, assign) CGFloat scale;

- (instancetype)initWithScale:(CGFloat)scale;

- (WDSTransformPipe *)newPipe;

@end
