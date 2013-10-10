//
//  UIImageView+Spati.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDSHTTPLink;


@interface UIImageView (Spati)

- (void)setImageWithURL:(NSURL *)url link:(WDSHTTPLink *)link force:(BOOL)force placeholder:(UIImage *)placeholder block:(void(^)(UIImage *image, BOOL cancelled))block;
- (void)setImageWithRequest:(NSURLRequest *)request link:(WDSHTTPLink *)link force:(BOOL)force placeholder:(UIImage *)placeholder block:(void(^)(UIImage *, BOOL))block;

@end
