//
//  WDSHTTPLink.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSHTTPLink.h"
#import "NWLCore.h"


@interface WDSHTTPFetch : NSObject<WDSCancel>
@property (nonatomic, strong) id<WDSCancel> connection;
@property (nonatomic, copy) void(^block)(NSData *data, WDSHTTPFetch *fetch);
- (void)callBlockWithData:(NSData *)data isCancelled:(BOOL)isCancelled;
- (void)nilBlock;
@end


@implementation WDSHTTPLink

- (instancetype)initWithSession:(id<WDSHTTPSession>)session baseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        _session = session;
        _baseURL = baseURL;
    }
    return self;
}

- (id<WDSCancel>)objectForKey:(id)key block:(void (^)(id, BOOL))block
{
    if (!key) { if (block) block(nil, NO); return nil; }
    NSURL *url = [_baseURL URLByAppendingPathComponent:key];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    WDSHTTPFetch *result = [[WDSHTTPFetch alloc] init];
    result.block = ^(NSData *data, WDSHTTPFetch *fetch) {
        if (block) block(data, fetch.isCancelled);
    };
    NWLogInfo(@"fetching %@ ..", request.URL);
    result.connection = [_session startWithRequest:request block:^(NSData *data, BOOL cancelled) {
        NWLogInfo(@".. fetched %@", request.URL);
        [result callBlockWithData:data isCancelled:cancelled];
    }];
    return result;
}

- (void)setObject:(id)object forKey:(id)key block:(void (^)(void))block
{
    // set not supported
    if (block) block();
}

- (WDSAsyncStorePipe *)newPipe
{
    return [[WDSAsyncStorePipe alloc] initWithAsync:self];
}

#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p base:%@>", self.class, self, [self.baseURL absoluteString]];
}

@end


@implementation WDSHTTPFetch {
    BOOL _isCancelled;
}

- (void)cancel
{
    [self markCancelled];
    [_connection cancel];
    [self callBlockWithData:nil isCancelled:YES];
}

- (void)callBlockWithData:(NSData *)data isCancelled:(BOOL)cancelled
{
    if (cancelled) [self markCancelled];
    void(^b)(NSData *, WDSHTTPFetch *) = _block; _block = nil;
    if (b) b(data, self);
}

- (void)nilBlock
{
    _block = nil;
}

- (void)markCancelled
{
    if (!_isCancelled) _isCancelled = YES;
}

- (BOOL)isCancelled
{
    return _isCancelled || _connection.isCancelled;
}

@end

