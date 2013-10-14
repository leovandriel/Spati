//
//  WDSMemoryCacheSpec.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "Kiwi.h"
#import "WDSMemoryCache.h"


SPEC_BEGIN(WDSMemoryCacheSpec)

describe(@"accessing objects", ^{
    __block WDSMemoryCache *cache;
    beforeEach(^{
        cache = [[WDSMemoryCache alloc] init];
    });
    
    it(@"forwards gets to the internal cache", ^{
        [[[[cache cache] should] receive] objectForKey:@"k"];
        [cache objectForKey:@"k" dataOnly:NO];
    });
    
    it(@"forwards sets to the internal cache", ^{
        [(NSCache *)[[[cache cache] should] receive] setObject:@"o" forKey:@"k" cost:0];
        [cache setObject:@"o" forKey:@"k" dataOnly:NO];
    });
    
    it(@"retrieves object after storing", ^{
        [cache setObject:@"o" forKey:@"k" dataOnly:NO];
        [[[cache objectForKey:@"k" dataOnly:NO] should] equal:@"o"];
    });
    
    it(@"returns nil for nil key", ^{
        [[[cache objectForKey:nil dataOnly:NO] should] beNil];
    });
    
    it(@"allows setting nil", ^{
        [cache setObject:@"o" forKey:@"k" dataOnly:NO];
        [cache setObject:nil forKey:@"k" dataOnly:NO];
        [[[cache objectForKey:nil dataOnly:NO] should] beNil];
    });
    
    it(@"returns YES iff valid key", ^{
        [[theValue((int)[cache setObject:@"o" forKey:@"k" dataOnly:NO]) should] beYes];
        [[theValue((int)[cache removeObjectForKey:@"k"]) should] beYes];
        [[theValue((int)[cache setObject:@"o" forKey:nil dataOnly:NO]) should] beNo];
    });
});

describe(@"(re)moving objects", ^{
    __block WDSMemoryCache *cache;
    beforeEach(^{
        cache = [[WDSMemoryCache alloc] init];
    });
    
    it(@"forwards removes to the internal cache", ^{
        [(NSCache *)[[[cache cache] should] receive] removeObjectForKey:@"k"];
        [cache removeObjectForKey:@"k"];
    });
    
    it(@"forwards remove alls to the internal cache", ^{
        [(NSCache *)[[[cache cache] should] receive] removeAllObjects];
        [cache removeAllObjects];
    });
    
    it(@"removed object after storing", ^{
        [cache setObject:@"o" forKey:@"k" dataOnly:NO];
        [cache removeObjectForKey:@"k"];
        [[[cache objectForKey:@"k" dataOnly:NO] should] beNil];
    });
    
    it(@"moved object after storing", ^{
        [cache setObject:@"o" forKey:@"k" dataOnly:NO];
        [cache moveObjectForKey:@"k" toKey:@"l"];
        [[[cache objectForKey:@"k" dataOnly:NO] should] beNil];
        [[[cache objectForKey:@"l" dataOnly:NO] should] equal:@"o"];
    });
    
    it(@"removed all objects after storing", ^{
        [cache setObject:@"o" forKey:@"k" dataOnly:NO];
        [cache setObject:@"p" forKey:@"l" dataOnly:NO];
        [cache removeAllObjects];
        [[[cache objectForKey:@"k" dataOnly:NO] should] beNil];
        [[[cache objectForKey:@"l" dataOnly:NO] should] beNil];
    });

    it(@"returns YES iff valid key", ^{
        [cache setObject:@"o" forKey:@"k" dataOnly:NO];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:@"l"]) should] beYes];
        [[theValue((int)[cache moveObjectForKey:nil toKey:@"l"]) should] beNo];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:nil]) should] beNo];
        [cache setObject:nil forKey:@"k" dataOnly:NO];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:@"l"]) should] beNo];
        [[theValue((int)[cache removeAllObjects]) should] beYes];
        [[theValue((int)[cache removeObjectForKey:nil]) should] beNo];
    });
});

SPEC_END
