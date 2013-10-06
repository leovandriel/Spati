//
//  UIButton+Spati.h
//  Spati
//
//  Copyright (c) 2013 witdot. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDSHTTPCache;


@interface UIButton (Spati)

- (void)setImageWithURL:(NSURL *)url cache:(WDSHTTPCache *)cache force:(BOOL)force placeholder:(UIImage *)placeholder block:(void(^)(UIImage *image))block;

@end
