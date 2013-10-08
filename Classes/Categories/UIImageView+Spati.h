//
//  UIImageView+Spati.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDSHTTPCache;


@interface UIImageView (Spati)

- (void)setImageWithURL:(NSURL *)url cache:(WDSHTTPCache *)cache force:(BOOL)force placeholder:(UIImage *)placeholder block:(void(^)(UIImage *image, BOOL cancelled))block;

@end
