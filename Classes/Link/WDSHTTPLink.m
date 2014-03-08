//
//  WDSHTTPLink.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSHTTPLink.h"
#import "WDSParser.h"
#import "WDSSyncCache.h"
#import "NWLCore.h"


@interface WDSHTTPFetch ()
@property (nonatomic, strong) WDSHTTPConnection *connection;
@property (nonatomic, copy) void(^block)(NSData *data, WDSHTTPFetch *fetch);
@property (nonatomic, assign) BOOL isCancelled;
- (void)callBlockWithData:(NSData *)data isCancelled:(BOOL)isCancelled;
- (void)nilBlock;
@end


@implementation WDSHTTPLink {
    NSMutableSet *_forceSet;
}

- (id)initWithSession:(WDSHTTPSession *)session cache:(WDSCache *)cache parser:(WDSParser *)parser
{
    return [self initWithSession:session readCache:cache writeCache:cache hasSyncCache:NO parser:parser];
}

- (id)initWithSession:(WDSHTTPSession *)session syncCache:(WDSSyncCache *)syncCache parser:(WDSParser *)parser
{
    return [self initWithSession:session readCache:syncCache writeCache:syncCache hasSyncCache:YES parser:parser];
}

- (id)initWithSession:(WDSHTTPSession *)session readCache:(WDSCache *)readCache writeCache:(WDSCache *)writeCache parser:(WDSParser *)parser
{
    return [self initWithSession:session readCache:readCache writeCache:writeCache hasSyncCache:NO parser:parser];
}

- (id)initWithSession:(WDSHTTPSession *)session readSyncCache:(WDSSyncCache *)readSyncCache writeCache:(WDSCache *)writeCache parser:(WDSParser *)parser
{
    return [self initWithSession:session readCache:readSyncCache writeCache:writeCache hasSyncCache:YES parser:parser];
}

- (id)initWithSession:(WDSHTTPSession *)session readCache:(WDSCache *)readCache writeCache:(WDSCache *)writeCache hasSyncCache:(BOOL)hasSyncCache parser:(WDSParser *)parser
{
    self = [super init];
    if (self) {
        _readCache = readCache;
        _writeCache = writeCache;
        _parser = parser;
        _session = session;
        _hasSyncCache = hasSyncCache;
    }
    return self;
}

- (void)forceRequest:(NSURLRequest *)request
{
    [self forceURL:request.URL];
}

- (void)forceURL:(NSURL *)url
{
    [self forceKey:url.absoluteString];
}

- (void)forceKey:(NSString *)key
{
    if (!_forceSet) _forceSet = [NSMutableSet set];
    [_forceSet addObject:key];
}

- (BOOL)removeForceForKey:(NSString *)key
{
    if (!key) return NO;
    BOOL result = [_forceSet containsObject:key];
    if (result) [_forceSet removeObject:key];
    return result;
}

#pragma mark - Retrieval

- (WDSHTTPFetch *)objectForURL:(NSURL *)url force:(BOOL)force block:(void (^)(id, WDSHTTPFetch *))block
{
    return [self objectForRequest:[NSURLRequest requestWithURL:url] key:url.absoluteString force:force dataOnly:NO block:block];
}

- (WDSHTTPFetch *)objectForRequest:(NSURLRequest *)request force:(BOOL)force block:(void(^)(id, WDSHTTPFetch *))block
{
    return [self objectForRequest:request key:request.URL.absoluteString force:force dataOnly:NO block:block];
}

- (WDSHTTPFetch *)objectForRequest:(NSURLRequest *)request key:(NSString *)key force:(BOOL)force block:(void(^)(id, WDSHTTPFetch *))block
{
    return [self objectForRequest:request key:key force:force dataOnly:NO block:block];
}

- (WDSHTTPFetch *)dataForURL:(NSURL *)url force:(BOOL)force block:(void (^)(NSData *, WDSHTTPFetch *))block
{
    return [self objectForRequest:[NSURLRequest requestWithURL:url] key:url.absoluteString force:force dataOnly:YES block:block];
}

- (WDSHTTPFetch *)dataForRequest:(NSURLRequest *)request force:(BOOL)force block:(void(^)(NSData *, WDSHTTPFetch *))block
{
    return [self objectForRequest:request key:request.URL.absoluteString force:force dataOnly:YES block:block];
}

- (WDSHTTPFetch *)dataForRequest:(NSURLRequest *)request key:(NSString *)key force:(BOOL)force block:(void(^)(NSData *, WDSHTTPFetch *))block
{
    return [self objectForRequest:request key:key force:force dataOnly:YES block:block];
}

- (WDSHTTPFetch *)objectForRequest:(NSURLRequest *)request key:(NSString *)key force:(BOOL)force dataOnly:(BOOL)dataOnly block:(void(^)(id, WDSHTTPFetch *))block
{
    WDSHTTPFetch *result = [[WDSHTTPFetch alloc] init];
    if ([self removeForceForKey:key] || force) {
        [self fetchObjectForRequest:request key:key process:result dataOnly:dataOnly block:block];
    } else {
        if (_hasSyncCache) {
            NSData *data = [(WDSSyncCache *)_readCache objectForKey:key dataOnly:dataOnly];
            if (data) { if (block) block(data, nil); return nil; }
            [self fetchObjectForRequest:request key:key process:result dataOnly:dataOnly block:block];
        } else {
            [_readCache objectForKey:key dataOnly:dataOnly block:^(NSData *data) {
                if (data || result.isCancelled) { [result nilBlock]; if (block) block(data, result); return; }
                [self fetchObjectForRequest:request key:key process:result dataOnly:dataOnly block:block];
            }];
        }
    }
    return result;
}

- (void)fetchObjectForRequest:(NSURLRequest *)request key:(NSString *)key process:(WDSHTTPFetch *)fetch dataOnly:(BOOL)dataOnly block:(void(^)(id, WDSHTTPFetch *))block
{
    fetch.block = ^(NSData *data, WDSHTTPFetch *fetch) {
        if (data && !fetch.isCancelled) {
            WDSParser *parser = _parser;
            WDSCache *cache = _writeCache;
            [_writeCache setObject:data forKey:key dataOnly:YES block:^(BOOL done) {
                NWAssert(done);
                id object = [parser parse:data];
                if (parser) [cache setObject:object forKey:key dataOnly:dataOnly block:^(BOOL done) { NWAssert(done); }];
                if (block) block(dataOnly ? data : object, fetch);
            }];
        } else {
            NWAssert(fetch.isCancelled);
            if (block) block(nil, fetch);
        }
    };
    NWLogInfo(@"fetching %@ ..", request.URL);
    fetch.connection = [_session startWithRequest:request block:^(NSData *data, BOOL isCancelled) {
        NWLogInfo(@".. fetched %@", request.URL);
        [fetch callBlockWithData:data isCancelled:isCancelled];
    }];
}

@end


@implementation WDSHTTPFetch

- (void)cancel
{
    [self markCancelled];
    [_connection cancel];
    [self callBlockWithData:nil isCancelled:YES];
}

- (void)callBlockWithData:(NSData *)data isCancelled:(BOOL)isCancelled
{
    if (isCancelled) [self markCancelled];
    void(^b)(NSData *, WDSHTTPFetch *) = _block; _block = nil;
    if (b) b(data, self);
}

- (void)nilBlock
{
    _block = nil;
}

- (void)markCancelled
{
    if (!_isCancelled) self.isCancelled = YES;
}

@end


@implementation WDSHTTPConnection

- (void)cancel
{
}

@end


@implementation WDSHTTPSession

- (WDSHTTPConnection *)startWithRequest:(NSURLRequest *)request block:(void(^)(NSData *, BOOL))block
{
    if (block) block(nil, NO);
    return nil;
}

@end
