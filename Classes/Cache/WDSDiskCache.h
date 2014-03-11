//
//  WDSDiskCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSCache.h"

typedef enum {
    kWDSFilenameFormatSame = 0,
    kWDSFilenameFormatMD5 = 1,
    kWDSFilenameFormatAlphaNumeric = 2,
    kWDSFilenameFormatURLEncoded = 3,
} WDSFilenameFormat;

@interface WDSDiskCache : WDSCache

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *extension;
@property (nonatomic, assign) NSTimeInterval expires;
@property (nonatomic, assign) BOOL pathInsteadOfData;
@property (nonatomic, assign) WDSFilenameFormat filenameFormat;

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) unsigned long long size;

- (instancetype)init;
- (instancetype)initWithName:(NSString *)name;

- (unsigned long long)trimToSize:(unsigned long long)size;

- (NSString *)path:(NSString *)key;

@end
