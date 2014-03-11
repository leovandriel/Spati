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

- (instancetype)initWithSync:(id<WDSSyncStore>)sync;

@end
