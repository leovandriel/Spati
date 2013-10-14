//
//  UIImageView+Spati.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "UIImageView+Spati.h"
#import "NSObject+Spati.h"


@implementation UIImageView (Spati)

- (id)setImageWithURL:(NSURL *)url link:(WDSHTTPLink *)link force:(BOOL)force placeholder:(UIImage *)placeholder block:(void(^)(UIImage *, BOOL))block
{
    return [self setImageWithRequest:[NSURLRequest requestWithURL:url] link:link force:force placeholder:placeholder block:block];
}

- (id)setImageWithRequest:(NSURLRequest *)request link:(WDSHTTPLink *)link force:(BOOL)force placeholder:(UIImage *)placeholder block:(void(^)(UIImage *, BOOL))block
{
    __weak __typeof(self)weakSelf = self;
    id result = [self objectForRequest:request link:link force:NO block:^(id object, BOOL cancelled) {
        __strong __typeof(weakSelf)_self = weakSelf;
        if (!cancelled && object) _self.image = object;
        if (block) block(object, cancelled);
    }];
    if (result) self.image = placeholder;
    return result;
}

@end
