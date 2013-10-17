//
//  WDSImageNamedDiskCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSImageNamedDiskCache.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "NWLCore.h"

@interface WDSDiskCache ()
- (NSString *)fileForKey:(NSString *)key;
- (BOOL)expirationOfFile:(NSString *)file;
@end


@implementation WDSImageNamedDiskCache

- (NSString *)relative:(NSString *)file
{
    return [[@"../Library/Caches" stringByAppendingPathComponent:self.name?:@"WDSDiskCache"] stringByAppendingPathComponent:file];
}

- (UIImage *)imageNamedForKey:(NSString *)key
{
    NWAssertMainThread();
    if (!key) return nil;
    NSString *file = [self fileForKey:key];
    if ([self expirationOfFile:file]) return nil;
#if TARGET_OS_IPHONE
    return [UIImage imageNamed:[self relative:file]];
#else
    return [NSImage imageNamed:[self relative:file]];
#endif
}

- (id)objectForKey:(NSString *)key dataOnly:(BOOL)dataOnly
{
    if (dataOnly) return [super objectForKey:key dataOnly:dataOnly];
    else return [self imageNamedForKey:key];
}

- (void)objectForKey:(NSString *)key dataOnly:(BOOL)dataOnly block:(void(^)(id))block
{
    if (dataOnly) [super objectForKey:key dataOnly:dataOnly block:block];
    else dispatch_async(dispatch_get_main_queue(), ^{
        id result = [self imageNamedForKey:key];
        if (block) dispatch_async(self.doneQueue, ^{ block(result); });
    });
}

@end
