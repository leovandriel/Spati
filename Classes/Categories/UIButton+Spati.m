//
//  UIButton+Spati.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "UIButton+Spati.h"
#import "NSObject+Spati.h"


@implementation UIButton (Spati)

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
            if (object) [_self setImage:object forState:UIControlStateNormal];
            else if (!fetch) [_self setImage:placeholder forState:UIControlStateNormal];
        }
        if (block) block(object, isCancelled);
    }];
    if (result) [self setImage:placeholder forState:UIControlStateNormal];
    return result;
}

@end
