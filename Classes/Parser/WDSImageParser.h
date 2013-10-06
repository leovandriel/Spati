//
//  WDSImageParser.h
//  Spati
//
//  Copyright (c) 2013 witdot. All rights reserved.
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

- (id)initWithType:(WDSParserImageType)type;

@end
