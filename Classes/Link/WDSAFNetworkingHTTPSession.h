//
//  WDSAFNetworkingHTTPSession.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSHTTPLink.h"

@interface WDSAFNetworkingHTTPSession : WDSHTTPSession

@property (nonatomic, readonly) NSOperationQueue *queue;

- (id)initWithConcurrent:(NSUInteger)concurrent;
- (id)initWithQueue:(NSOperationQueue *)queue;

@end
