//
//  UIButton+Spati.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDSPipe.h"


@interface UIButton (Spati)

- (id<WDSCancel>)setImageWithKey:(id)key pipe:(WDSPipe *)pipe placeholder:(UIImage *)placeholder block:(void(^)(UIImage *image, WDSStatus status))block;

@end
