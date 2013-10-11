//
//  WDSDiskCacheSpec.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "Kiwi.h"
#import "WDSDiskCache.h"


SPEC_BEGIN(WDSDiskCacheSpec)

describe(@"accessing data", ^{
    __block WDSDiskCache *cache;
    NSData *data = [@"o" dataUsingEncoding:NSUTF8StringEncoding];
    beforeEach(^{
        cache = [[WDSDiskCache alloc] init];
    });
    
    it(@"forwards gets to the internal cache", ^{
        [[[NSData should] receive] dataWithContentsOfFile:any()];
        [cache dataForKey:@"k"];
    });
    
    it(@"forwards sets to the internal cache", ^{
        [[[data should] receive] writeToFile:any() atomically:NO];
        [cache setData:data forKey:@"k"];
    });
    
    it(@"retrieves data after storing", ^{
        [cache setData:data forKey:@"k"];
        [[[cache dataForKey:@"k"] should] equal:data];
    });
    
    it(@"returns nil for nil key", ^{
        [[[cache dataForKey:nil] should] beNil];
    });
    
    it(@"allows setting nil", ^{
        [cache setData:data forKey:@"k"];
        [cache setData:nil forKey:@"k"];
        [[[cache dataForKey:nil] should] beNil];
    });
    
    it(@"returns YES iff valid key", ^{
        [[theValue((int)[cache setData:data forKey:@"k"]) should] beYes];
        [[theValue((int)[cache removeObjectForKey:@"k"]) should] beYes];
        [[theValue((int)[cache setData:data forKey:nil]) should] beNo];
    });
});

describe(@"(re)moving data", ^{
    __block WDSDiskCache *cache;
    NSData *data = [@"o" dataUsingEncoding:NSUTF8StringEncoding];
    beforeEach(^{
        cache = [[WDSDiskCache alloc] init];
    });
    
    it(@"forwards removes to the internal cache", ^{
        [[[NSFileManager.defaultManager should] receive] removeItemAtPath:any() error:nil];
        [cache removeObjectForKey:@"k"];
    });
    
    it(@"forwards remove alls to the internal cache", ^{
        [[[NSFileManager.defaultManager should] receive] removeItemAtPath:any() error:nil];
        [cache removeAllObjects];
    });
    
    it(@"removed data after storing", ^{
        [cache setData:data forKey:@"k"];
        [cache removeObjectForKey:@"k"];
        [[[cache dataForKey:@"k"] should] beNil];
    });
    
    it(@"moved data after storing", ^{
        [cache setData:data forKey:@"k"];
        [cache moveObjectForKey:@"k" toKey:@"l"];
        [[[cache dataForKey:@"k"] should] beNil];
        [[[cache dataForKey:@"l"] should] equal:data];
    });
    
    it(@"removed all data after storing", ^{
        [cache setData:data forKey:@"k"];
        [cache setData:[@"p" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"l"];
        [cache removeAllObjects];
        [[[cache dataForKey:@"k"] should] beNil];
        [[[cache dataForKey:@"l"] should] beNil];
    });

    it(@"returns YES iff valid key", ^{
        [cache setData:data forKey:@"k"];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:@"l"]) should] beYes];
        [[theValue((int)[cache moveObjectForKey:nil toKey:@"l"]) should] beNo];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:nil]) should] beNo];
        [cache setData:nil forKey:@"k"];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:@"l"]) should] beNo];
        [[theValue((int)[cache removeAllObjects]) should] beYes];
        [[theValue((int)[cache removeObjectForKey:nil]) should] beNo];
    });
});

SPEC_END
