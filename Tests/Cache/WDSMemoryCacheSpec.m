//
//  WDSMemoryCacheSpec.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "Kiwi.h"
#import "WDSMemoryCache.h"


SPEC_BEGIN(MemoryCacheSpec)

describe(@"accessing objects", ^{
    __block WDSMemoryCache *cache;
    beforeEach(^{
        cache = [[WDSMemoryCache alloc] init];
    });
    
    it(@"forwards gets to the internal cache", ^{
        [[[[cache cache] should] receive] objectForKey:@"k"];
        [cache objectForKey:@"k"];
    });
    
    it(@"forwards sets to the internal cache", ^{
        [(NSCache *)[[[cache cache] should] receive] setObject:@"o" forKey:@"k" cost:0];
        [cache setObject:@"o" forKey:@"k"];
    });
    
    it(@"retrieves object after storing", ^{
        [cache setObject:@"o" forKey:@"k"];
        [[[cache objectForKey:@"k"] should] equal:@"o"];
    });
    
    it(@"returns nil for nil key", ^{
        [[[cache objectForKey:nil] should] beNil];
    });
    
    it(@"allows setting nil", ^{
        [cache setObject:@"o" forKey:@"k"];
        [cache setObject:nil forKey:@"k"];
        [[[cache objectForKey:nil] should] beNil];
    });
    
    it(@"returns YES iff valid key", ^{
        [[theValue((int)[cache setObject:@"o" forKey:@"k"]) should] beYes];
        [[theValue((int)[cache removeObjectForKey:@"k"]) should] beYes];
        [[theValue((int)[cache setObject:@"o" forKey:nil]) should] beNo];
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
        [cache setObject:@"o" forKey:@"k"];
        [cache removeObjectForKey:@"k"];
        [[[cache objectForKey:@"k"] should] beNil];
    });
    
    it(@"moved object after storing", ^{
        [cache setObject:@"o" forKey:@"k"];
        [cache moveObjectForKey:@"k" toKey:@"l"];
        [[[cache objectForKey:@"k"] should] beNil];
        [[[cache objectForKey:@"l"] should] equal:@"o"];
    });
    
    it(@"removed all objects after storing", ^{
        [cache setObject:@"o" forKey:@"k"];
        [cache setObject:@"p" forKey:@"l"];
        [cache removeAllObjects];
        [[[cache objectForKey:@"k"] should] beNil];
        [[[cache objectForKey:@"l"] should] beNil];
    });

    it(@"returns YES iff valid key", ^{
        [cache setObject:@"o" forKey:@"k"];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:@"l"]) should] beYes];
        [[theValue((int)[cache moveObjectForKey:nil toKey:@"l"]) should] beNo];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:nil]) should] beNo];
        [cache setObject:nil forKey:@"k"];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:@"l"]) should] beNo];
        [[theValue((int)[cache removeAllObjects]) should] beYes];
        [[theValue((int)[cache removeObjectForKey:nil]) should] beNo];
    });
});

SPEC_END
