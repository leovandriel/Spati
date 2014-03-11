//
//  WDSImageTransform.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSTransformPipe.h"


@interface WDSImageTransform : NSObject<WDSTransform>

- (WDSTransformPipe *)newPipe;

@end
