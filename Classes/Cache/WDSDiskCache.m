//
//  WDSDiskCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSDiskCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "NWLCore.h"


@implementation WDSDiskCache

- (id)init
{
    return [self initWithName:@"WDSDiskCache"];
}

- (id)initWithName:(NSString *)name
{
    return [self initWithName:name expires:0];
}

- (id)initWithName:(NSString *)name expires:(NSTimeInterval)expires
{
    self = [super init];
    if (self) {
        _name = name;
        _expires = expires;
        _path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:name?:@"spati"];
        BOOL success = [self ensureDirectory];
        NWAssert(success);
    }
    return self;
}

#pragma mark File Management

- (BOOL)ensureDirectory
{
    return [NSFileManager.defaultManager createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (BOOL)removeDirectory
{
    return [NSFileManager.defaultManager removeItemAtPath:_path error:nil];
}

- (BOOL)removeFile:(NSString *)file
{
    return [NSFileManager.defaultManager removeItemAtPath:[_path stringByAppendingPathComponent:file] error:nil];
}

- (NSArray *)files
{
    return [NSFileManager.defaultManager contentsOfDirectoryAtPath:_path error:nil];
}

- (NSUInteger)count
{
    return self.files.count;
}

- (unsigned long long)size
{
    unsigned long long result = 0;
    for (NSString *file in self.files) {
        result += [self sizeOfFile:file];
    }
    return result;
}

- (unsigned long long)sizeOfFile:(NSString *)file
{
    return [NSFileManager.defaultManager attributesOfItemAtPath:[_path stringByAppendingPathComponent:file] error:nil].fileSize;
}

- (NSDate *)modifcationDateOfFile:(NSString *)file
{
    return [NSFileManager.defaultManager attributesOfItemAtPath:[_path stringByAppendingPathComponent:file] error:nil].fileModificationDate;
}

- (BOOL)expirationOfFile:(NSString *)file
{
    return _expires > 0 && -[[self modifcationDateOfFile:file] timeIntervalSinceNow] > _expires;
}

- (void)trimToSize:(unsigned long long)size
{
    NSMutableArray *pairs = @[].mutableCopy;
    unsigned long long slack = 0;
    for (NSString *file in self.files) {
        unsigned long long s = [self sizeOfFile:file];
        [pairs addObject:@[file, ([self modifcationDateOfFile:file] ?: NSDate.date), @(s)]];
        slack += s;
    }
    if (slack <= size) return;
    [pairs sortUsingComparator:^NSComparisonResult(NSArray *a, NSArray *b) { return [b[1] compare:a[1]]; }];
    slack -= size;
    unsigned long long removed = 0;
    for (NSArray *pair in pairs) {
        if ([self removeFile:pair[0]]) removed += [pair[2] longLongValue];
        if (removed > slack) break;
    }
    NWAssert(removed > slack);
}


#pragma mark Cache Cache

- (NSString *)fileForKey:(NSString *)key
{
    const char *string = key.UTF8String;
    unsigned char d[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, (CC_LONG)strlen(string), d);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",d[0],d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8],d[9],d[10],d[11],d[12],d[13],d[14],d[15]];
}

- (NSString *)path:(NSString *)key
{
    return [_path stringByAppendingPathComponent:[self fileForKey:key]];
}

- (NSData *)dataForKey:(NSString *)key
{
    if (!key) return nil;
    NSString *file = [self fileForKey:key];
    if ([self expirationOfFile:file]) return nil;
    return [NSData dataWithContentsOfFile:[_path stringByAppendingPathComponent:file]];
}

- (BOOL)setData:(NSData *)data forKey:(NSString *)key
{
    if (!key) return NO;
    return [data writeToFile:[self path:key] atomically:NO];
}

- (BOOL)removeObjectForKey:(NSString *)key
{
    if (!key) return NO;
    return [NSFileManager.defaultManager removeItemAtPath:[self path:key] error:nil];
}

- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey
{
    if (!key || !toKey) return NO;
    return [NSFileManager.defaultManager moveItemAtPath:[self path:key] toPath:[self path:toKey] error:nil];
}

- (BOOL)removeAllObjects
{
    return [self removeDirectory] & [self ensureDirectory];
}

@end
