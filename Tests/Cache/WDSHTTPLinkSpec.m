//
//  WDSHTTPLinkSpec.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "Kiwi.h"
#import "WDSHTTPLink.h"
#import "WDSMemoryCache.h"


SPEC_BEGIN(WDSHTTPLinkSpec)

describe(@"force set", ^{
    __block WDSHTTPLink *link;
    beforeEach(^{
        link = [[WDSHTTPLink alloc] init];
    });
    
    it(@"adds key to force set", ^{
        [link forceURL:[NSURL URLWithString:@"k"]];
        [[link.forceSet should] contain:@"k"];
    });
    
    it(@"remove key upon fetching", ^{
        [link forceKey:@"k"];
        [link objectForRequest:[NSURLRequest mock] key:@"k" force:NO block:nil];
        [[link.forceSet shouldNot] contain:@"k"];
    });
    
    it(@"remove key upon forced fetching", ^{
        [link forceKey:@"k"];
        [link objectForRequest:[NSURLRequest mock] key:@"k" force:YES block:nil];
        [[link.forceSet shouldNot] contain:@"k"];
    });
});

describe(@"forced fetching", ^{
    __block WDSHTTPLink *link;
    beforeEach(^{
        link = [[WDSHTTPLink alloc] initWithSession:[WDSHTTPSession mock] cache:[[WDSMemoryCache alloc] init] parser:nil];
    });
    
//    it(@"uses cached object if not forced", ^{
//        [(WDSSyncCache *)link.cache setObject:@"o" forKey:@"k"];
//        __block id o = nil;
//        [[o shouldEventually] equal:@"o"];
//        [[[link.session shouldNot] receive] startWithRequest:nil block:nil];
//        [link objectForRequest:[NSURLRequest mock] key:@"k" force:NO block:^(id object, BOOL isCancelled) {
//            o = object;
//        }];
//    });
//    
//    it(@"uses session object if forced", ^{
//        [(WDSSyncCache *)link.cache setObject:@"o" forKey:@"k"];
//        [[link.session should] receive:@selector(startWithRequest:block:)];
//        [link objectForRequest:[NSURLRequest mock] key:@"k" force:YES block:nil];
//    });
//    
//    it(@"uses session object if forced indirectly", ^{
//        [(WDSSyncCache *)link.cache setObject:@"o" forKey:@"k"];
//        [link forceKey:@"k"];
//        [[link.session should] receive:@selector(startWithRequest:block:)];
//        [link objectForRequest:[NSURLRequest mock] key:@"k" force:NO block:nil];
//    });
});

SPEC_END