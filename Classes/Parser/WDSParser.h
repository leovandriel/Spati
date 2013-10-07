//
//  WDSParser.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WDSParser : NSObject

- (id)parse:(NSData *)data;
- (NSData *)serialize:(id)value;
- (unsigned long long)size:(id)value;

@end
