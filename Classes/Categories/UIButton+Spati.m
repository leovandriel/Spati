//
//  UIButton+Spati.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "UIButton+Spati.h"
#import "NSObject+Spati.h"


@implementation UIButton (Spati)

- (void)setImageWithURL:(NSURL *)url link:(WDSHTTPLink *)link force:(BOOL)force placeholder:(UIImage *)placeholder block:(void(^)(UIImage *, BOOL))block
{
    [self setImage:placeholder forState:UIControlStateNormal];
    __weak __typeof(self)weakSelf = self;
    [self objectForKey:url.absoluteString link:link force:NO block:^(id object, BOOL cancelled) {
        __strong __typeof(weakSelf)_self = weakSelf;
        if (!cancelled && object) [_self setImage:object forState:UIControlStateNormal];
        if (block) block(object, cancelled);
    }];
}

@end
