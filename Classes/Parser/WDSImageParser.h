//
//  WDSImageParser.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSParser.h"


typedef enum {
    kWDSParserImageTypeNone = 0,
    kWDSParserImageTypePNG = 1,
    kWDSParserImageTypeJPEG = 2,
} WDSParserImageType;


@interface WDSImageParser : WDSParser

@property (nonatomic, readonly) WDSParserImageType type;

- (id)init;
- (id)initWithType:(WDSParserImageType)type;

@end
