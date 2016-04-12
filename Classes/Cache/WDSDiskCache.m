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

- (instancetype)init
{
    return [self initWithName:@"cache"];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
        _path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:name];
        BOOL success = [self ensureDirectory];
        NWAssert(success);
    }
    return self;
}

#pragma mark File Management

- (BOOL)ensureDirectory
{
    NSError *error = nil;
    BOOL result = [NSFileManager.defaultManager createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:&error];
    NWError(error);
    return result;
}

- (BOOL)removeDirectory
{
    NSError *error = nil;
    BOOL result = [NSFileManager.defaultManager removeItemAtPath:_path error:&error];
    NWError(error);
    return result;
}

- (BOOL)removeFile:(NSString *)file
{
    if (!file) return NO;
    NSString *path = [self pathForFile:file];
    if (!path) return NO;
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) return YES;
    NSError *error = nil;
    BOOL result = [NSFileManager.defaultManager removeItemAtPath:path error:&error];
    NWError(error);
    return result;
}

- (BOOL)moveFile:(NSString *)from to:(NSString *)to
{
    if (!from || !to) return NO;
    NSString *path = [self pathForFile:from];
    NSString *toPath = [self pathForFile:to];
    if (!path || !toPath) return NO;
    NSError *error = nil;
    BOOL result = [NSFileManager.defaultManager moveItemAtPath:path toPath:toPath error:&error];
    NWError(error);
    return result;
}

- (NSArray *)files
{
    NSError *error = nil;
    NSArray *result = [NSFileManager.defaultManager contentsOfDirectoryAtPath:_path error:&error];
    NWError(error);
    return result;
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
    if (!file) return 0;
    NSString *path = [self pathForFile:file];
    if (!path) return 0;
    NSError *error = nil;
    NSDictionary *result = [NSFileManager.defaultManager attributesOfItemAtPath:path error:&error];
    NWError(error);
    return [result fileSize];
}

- (NSDate *)modifcationDateOfFile:(NSString *)file
{
    if (!file) return 0;
    NSString *path = [self pathForFile:file];
    NSError *error = nil;
    NSDictionary *result = [NSFileManager.defaultManager attributesOfItemAtPath:path error:&error];
    NWError(error);
    return [result fileModificationDate];
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
        [url getResourceValue:&directory forKey:NSURLIsDirectoryKey error:nil];
        if (directory.boolValue) continue;
        NSDate *date = nil;
        [url getResourceValue:&date forKey:NSURLContentAccessDateKey error:nil];
        NSNumber *size = nil;
        [url getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
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
        if ([manager removeItemAtURL:pair[0] error:nil]) removed += [pair[2] longLongValue];
        if (removed > slack) break;
    }
    NWAssert(removed > slack);
    return removed;
}

- (NSString *)filenamePartForKey:(NSString *)key
{
    switch (_filenameFormat) {
        case kWDSFilenameFormatSame: {
            return key;
        } break;
        case kWDSFilenameFormatMD5: {
            const char *string = key.UTF8String;
            unsigned char d[CC_MD5_DIGEST_LENGTH];
            CC_MD5(string, (CC_LONG)strlen(string), d);
            return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",d[0],d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8],d[9],d[10],d[11],d[12],d[13],d[14],d[15]];
        } break;
        case kWDSFilenameFormatAlphaNumeric: {
            return [key stringByReplacingOccurrencesOfString:@"[^A-Za-z0-9]+" withString:@"_" options:NSRegularExpressionSearch range:NSMakeRange(0, key.length)];
        } break;
        case kWDSFilenameFormatURLEncoded: {
            return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)key, NULL, CFSTR("*'();:@&=+$,/?!%#[]"), kCFStringEncodingUTF8));
        } break;
    }
    return nil;
}

#pragma mark Cache Cache

- (NSString *)filenameForKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@%@%@", [self filenamePartForKey:key], _extension ? @"." : @"", _extension?:@""];
}

- (NSString *)pathForFile:(NSString *)file
{
    return file.length ? [_path stringByAppendingPathComponent:file] : nil;
}

- (NSString *)pathForKey:(NSString *)key
{
    return key ? [self pathForFile:[self filenameForKey:key]] : nil;
}

- (id)objectForKey:(NSString *)key
{
    if (!key) return nil;
    NSString *file = [self filenameForKey:key];
    if ([self expirationOfFile:file]) {
        NWLogInfo(@"[%@] miss: expired", self.name);
        return nil;
    }
    NSString *path = [self pathForFile:file];
    if (!path) return nil;
    id result = nil;
    if (_pathInsteadOfData) {
        BOOL exists = [NSFileManager.defaultManager fileExistsAtPath:path];
        result = exists ? path : nil;
    } else {
        result = [NSData dataWithContentsOfFile:path];
    }
    if (result) {
        NWLogInfo(@"[%@] hit: %@ = %@", self.name, key, [result class]);
    } else {
        NWLogInfo(@"[%@] miss: %@", self.name, key);
    }
    return result;
}

- (id)setObject:(id)object forKey:(NSString *)key
{
    if (!key) return nil;
    NSString *file = [self filenameForKey:key];
    id result = nil;
    if (object) {
        NSString *path = [self pathForFile:file];
        if (!path) return nil;
        NSError *error = nil;
        BOOL written = [object writeToFile:path options:NSDataWritingAtomic error:&error];
        NWError(error);
        if (_pathInsteadOfData) {
            result = written ? path : nil;
        } else {
            result = written ? object : nil;
        }
        NWLogInfo(@"[%@] set: %@ = %@  file: %@ = %@", self.name, key, [object class], file, result ? @"success" : @"failed");
    } else {
        BOOL removed = [self removeFile:file];
        NWLogInfo(@"[%@] unset: %@  file: %@ = %@", self.name, key, file, removed ? @"success" : @"failed");
    }
    return result;
}

- (BOOL)removeObjectForKey:(NSString *)key
{
    if (!key) return NO;
    NSString *file = [self filenameForKey:key];
    BOOL result = [self removeFile:file];
    NWLogInfo(@"[%@] remove: %@  file: %@ = %@", self.name, key, file, result ? @"success" : @"failed");
    return result;
}

- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey
{
    if (!key || !toKey) return NO;
    NSString *file = [self filenameForKey:key];
    NSString *toFile = [self filenameForKey:toKey];
    BOOL result = [self moveFile:file to:toFile];
    NWLogInfo(@"[%@] move: %@ -> %@  file: %@ -> %@ = %@", self.name, key, toKey, file, toFile, result ? @"success" : @"failed");
    return result;
}

- (BOOL)removeAllObjects
{
    NWLogInfo(@"[%@] remove-all", self.name);
    return [self removeDirectory] & [self ensureDirectory];
}

@end
