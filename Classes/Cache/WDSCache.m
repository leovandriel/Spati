//
//  WDSCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSCache.h"
#import "WDSSyncStorePipe.h"


@implementation WDSCache

- (id)objectForKey:(NSString *)key
{
    return nil;
}

- (id)setObject:(id)object forKey:(NSString *)key
{
    return nil;
}

- (BOOL)removeObjectForKey:(NSString *)key
{
    return NO;
}

- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey
{
    return NO;
}

- (BOOL)removeAllObjects
{
    return NO;
}

- (NSString *)name
{
    return self.class.description;
}

- (WDSSyncStorePipe *)newPipe
{
    return [[WDSSyncStorePipe alloc] initWithSync:self];
}

#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p name:%@>", self.class, self, self.name];
}

@end
