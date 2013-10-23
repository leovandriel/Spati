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
    id result = [self objectAndFetchForRequest:request link:link force:NO block:^(id object, id fetch) {
        __strong __typeof(weakSelf)_self = weakSelf;
        BOOL isCancelled = [fetch isCancelled];
        if (!isCancelled) {
            if (object) _self.image = object;
            else if (!fetch) _self.image = placeholder;
        }
        if (block) block(object, isCancelled);
    }];
    if (result) self.image = placeholder;
    return result;
}

@end
