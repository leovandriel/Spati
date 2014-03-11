//
//  UIButton+Spati.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDSPipe;
@protocol WDSCancel;


@interface UIButton (Spati)

- (id<WDSCancel>)setImageWithKey:(id)key pipe:(WDSPipe *)pipe placeholder:(UIImage *)placeholder block:(void(^)(UIImage *image, BOOL cancelled))block;

@end
