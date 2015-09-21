//
//  WDSURLSession.h
//  Spati
//
//  Created by Jorn van Dijk on 16-09-15.
//  Copyright © 2015 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSHTTPLink.h"

@interface WDSURLSession : NSObject<WDSHTTPSession>

@property (nonatomic, readonly) NSURLSession *URLSession;

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration;

@end
