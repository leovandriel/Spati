//
//  WDSURLSession.m
//  Spati
//
//  Created by Jorn van Dijk on 16-09-15.
//  Copyright © 2015 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSURLSession.h"


@interface WDSURLSessionConnection : NSObject<WDSCancel>

@property (nonatomic, readonly) NSURLSessionTask *task;
@property (nonatomic, assign) BOOL didCancel;

- (instancetype)initWithTask:(NSURLSessionTask *)task;

@end


@interface WDSURLSession () <NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *URLSession;

@end


@implementation WDSURLSession

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (self) {
        self.URLSession = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (id<WDSCancel>)startWithRequest:(NSURLRequest *)request block:(void (^)(NSData *, WDSStatus))block
{
    NSURLSessionTask *task = [self.URLSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        if (block) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            WDSStatus status = [self.class statusWithHTTPStatus:httpResponse.statusCode];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(data, status);
            });
        }
    }];
    
    WDSURLSessionConnection *result = [[WDSURLSessionConnection alloc] initWithTask:task];
    [task resume];
    return result;
}

+ (WDSStatus)statusWithHTTPStatus:(NSUInteger)statusCode
{
    switch (statusCode) {
        case 200: return WDSStatusSuccess;
        case 403: return WDSStatusNotFound;
        case 404: return WDSStatusNotFound;
    }
    return WDSStatusFailed;
}

@end


@implementation WDSURLSessionConnection

- (instancetype)initWithTask:(NSURLSessionTask *)task;
{
    self = [super init];
    if (self) {
        _task = task;
    }
    return self;
}

- (void)cancel
{
    [self.task cancel];
    _didCancel = YES;
}

- (BOOL)isCancelled
{
    return _didCancel;
}

@end
