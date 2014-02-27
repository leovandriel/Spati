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

- (unsigned long long)trimToSize:(unsigned long long)size
{
    NSFileManager *manager = NSFileManager.defaultManager;
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtURL:[NSURL fileURLWithPath:_path] includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLContentAccessDateKey, NSURLFileSizeKey] options:0 errorHandler:^BOOL(NSURL *url, NSError *error) {
        if (url) NWError(error);
        return YES;
    }];
    NSMutableArray *pairs = @[].mutableCopy;
    unsigned long long slack = 0;
    for (NSURL *url in enumerator) {
        NSNumber *directory = nil;
        [url getResourceValue:&directory forKey:NSURLIsDirectoryKey error:NULL];
        if (directory.boolValue) continue;
        NSDate *date = nil;
        [url getResourceValue:&date forKey:NSURLContentAccessDateKey error:NULL];
        NSNumber *size = nil;
        [url getResourceValue:&size forKey:NSURLFileSizeKey error:NULL];
        [pairs addObject:@[url, date ?: NSDate.date, size ?: @(0)]];
        slack += size.longLongValue;
        //NWLog(@"found: %@ %@ %@", url.lastPathComponent, date, size);
    }
    if (slack <= size) return 0;
    [pairs sortUsingComparator:^NSComparisonResult(NSArray *a, NSArray *b) { return [a[1] compare:b[1]]; }];
    slack -= size;
    unsigned long long removed = 0;
    for (NSArray *pair in pairs) {
        //NWLog(@"removing %@ %@ %@", [pair[0] lastPathComponent], pair[1], pair[2]);
        if ([manager removeItemAtURL:pair[0] error:NULL]) removed += [pair[2] longLongValue];
        if (removed > slack) break;
    }
    NWAssert(removed > slack);
    return removed;
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

- (id)objectForKey:(NSString *)key dataOnly:(BOOL)dataOnly
{
    if (!key) return nil;
    if (!dataOnly) {
        NWLogInfo(@"[%@] miss: data-only", self.name);
        return nil;
    }
    NSString *file = [self fileForKey:key];
    if ([self expirationOfFile:file]) {
        NWLogInfo(@"[%@] miss: expired", self.name);
        return nil;
    }
    id result = [NSData dataWithContentsOfFile:[_path stringByAppendingPathComponent:file]];
    if (result) {
        NWLogInfo(@"[%@] hit: %@ = %@", self.name, key, [result class]);
    } else {
        NWLogInfo(@"[%@] miss: %@", self.name, key);
    }
    return result;
}

- (BOOL)setObject:(id)object forKey:(NSString *)key dataOnly:(BOOL)dataOnly
{
    if (!key) return NO;
    if (!dataOnly) {
        NWLogInfo(@"[%@] noset: data-only", self.name);
        return NO;
    }
    NSString *file = [self fileForKey:key];
    BOOL result = NO;
    if (object) {
        result = [object writeToFile:[_path stringByAppendingPathComponent:file] atomically:NO];
        NWLogInfo(@"[%@] set: %@ = %@  file: %@ = %@", self.name, key, [object class], file, result ? @"success" : @"failed");
    } else {
        result = [NSFileManager.defaultManager removeItemAtPath:[_path stringByAppendingPathComponent:file] error:nil];
        NWLogInfo(@"[%@] unset: %@  file: %@ = %@", self.name, key, file, result ? @"success" : @"failed");
    }
    return result;
}

- (BOOL)removeObjectForKey:(NSString *)key
{
    if (!key) return NO;
    NSString *file = [self fileForKey:key];
    BOOL result = [NSFileManager.defaultManager removeItemAtPath:[_path stringByAppendingPathComponent:file] error:nil];
    NWLogInfo(@"[%@] remove: %@  file: %@ = %@", self.name, key, file, result ? @"success" : @"failed");
    return result;
}

- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey
{
    if (!key || !toKey) return NO;
    NSString *file = [self fileForKey:key];
    NSString *toFile = [self fileForKey:toKey];
    BOOL result = [NSFileManager.defaultManager moveItemAtPath:[_path stringByAppendingPathComponent:file] toPath:[_path stringByAppendingPathComponent:toFile] error:nil];
    NWLogInfo(@"[%@] move: %@ -> %@  file: %@ = %@", self.name, key, toKey, file, result ? @"success" : @"failed");
    return result;
}

- (BOOL)removeAllObjects
{
    NWLogInfo(@"[%@] remove-all", self.name);
    return [self removeDirectory] & [self ensureDirectory];
}

@end
