//
//  UIImageView+Spati.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "UIImageView+Spati.h"
#import "NSObject+Spati.h"


@implementation UIImageView (Spati)

- (void)setImageWithURL:(NSURL *)url cache:(WDSHTTPCache *)cache force:(BOOL)force placeholder:(UIImage *)placeholder block:(void(^)(UIImage *, BOOL))block
{
    self.image = placeholder;
    __weak __typeof(self)weakSelf = self;
    [self objectForKey:url.absoluteString cache:cache force:NO block:^(id object, BOOL cancelled) {
        __strong __typeof(weakSelf)_self = weakSelf;
        if (!cancelled && object) _self.image = object;
        if (block) block(object, cancelled);
    }];
}

@end
