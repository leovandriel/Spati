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
        [cache objectForKey:@"k" dataOnly:YES];
    });
    
    it(@"forwards sets to the internal cache", ^{
        [[[data should] receive] writeToFile:any() atomically:NO];
        [cache setObject:data forKey:@"k" dataOnly:YES];
    });
    
    it(@"retrieves data after storing", ^{
        [cache setObject:data forKey:@"k" dataOnly:YES];
        [[[cache objectForKey:@"k" dataOnly:YES] should] equal:data];
    });
    
    it(@"returns nil for nil key", ^{
        [[[cache objectForKey:nil dataOnly:YES] should] beNil];
    });
    
    it(@"allows setting nil", ^{
        [cache setObject:data forKey:@"k" dataOnly:YES];
        [cache setObject:nil forKey:@"k" dataOnly:YES];
        [[[cache objectForKey:nil dataOnly:YES] should] beNil];
    });
    
    it(@"returns YES iff valid key", ^{
        [[theValue((int)[cache setObject:data forKey:@"k" dataOnly:YES]) should] beYes];
        [[theValue((int)[cache removeObjectForKey:@"k"]) should] beYes];
        [[theValue((int)[cache setObject:data forKey:nil dataOnly:YES]) should] beNo];
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
        [cache setObject:data forKey:@"k" dataOnly:YES];
        [cache removeObjectForKey:@"k"];
        [[[cache objectForKey:@"k" dataOnly:YES] should] beNil];
    });
    
    it(@"moved data after storing", ^{
        [cache setObject:data forKey:@"k" dataOnly:YES];
        [cache moveObjectForKey:@"k" toKey:@"l"];
        [[[cache objectForKey:@"k" dataOnly:YES] should] beNil];
        [[[cache objectForKey:@"l" dataOnly:YES] should] equal:data];
    });
    
    it(@"removed all data after storing", ^{
        [cache setObject:data forKey:@"k" dataOnly:YES];
        [cache setObject:[@"p" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"l" dataOnly:YES];
        [cache removeAllObjects];
        [[[cache objectForKey:@"k" dataOnly:YES] should] beNil];
        [[[cache objectForKey:@"l" dataOnly:YES] should] beNil];
    });

    it(@"returns YES iff valid key", ^{
        [cache setObject:data forKey:@"k" dataOnly:YES];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:@"l"]) should] beYes];
        [[theValue((int)[cache moveObjectForKey:nil toKey:@"l"]) should] beNo];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:nil]) should] beNo];
        [cache setObject:nil forKey:@"k" dataOnly:YES];
        [[theValue((int)[cache moveObjectForKey:@"k" toKey:@"l"]) should] beNo];
        [[theValue((int)[cache removeAllObjects]) should] beYes];
        [[theValue((int)[cache removeObjectForKey:nil]) should] beNo];
    });
});

SPEC_END
