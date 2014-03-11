//
//  WDSAFNetworkingHTTPSession.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSHTTPLink.h"

@interface WDSAFNetworkingHTTPSession : NSObject<WDSHTTPSession>

@property (nonatomic, readonly) NSOperationQueue *queue;

- (instancetype)initWithConcurrent:(NSUInteger)concurrent;
- (instancetype)initWithQueue:(NSOperationQueue *)queue;

@end
