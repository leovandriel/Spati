//
//  WDSHTTPLink.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSAsyncStorePipe.h"


@protocol WDSHTTPSession <NSObject>
- (id<WDSCancel>)startWithRequest:(NSURLRequest *)request block:(void(^)(NSData *data, BOOL isCancelled))block;
@end


@interface WDSHTTPLink : NSObject<WDSAsyncStore>

@property (nonatomic, readonly) id<WDSHTTPSession> session;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, assign) BOOL ignoreHTTPCache;

- (instancetype)initWithSession:(id<WDSHTTPSession>)session baseURL:(NSURL *)baseURL;
- (WDSAsyncStorePipe *)newPipe;

- (NSURL *)urlForKey:(NSString *)key;

@end
