//
//  UIImageView+Spati.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "UIImageView+Spati.h"
#import "NSObject+Spati.h"


@implementation UIImageView (Spati)

- (id<WDSCancel>)setImageWithKey:(id)key pipe:(WDSPipe *)pipe placeholder:(UIImage *)placeholder block:(void(^)(UIImage *, WDSStatus))block
{
    __weak __typeof(self)weakSelf = self;
    id result = [self objectForKey:key pipe:pipe block:^(id object, WDSStatus status) {
        __strong __typeof(weakSelf)_self = weakSelf;
        if (status != WDSStatusCancelled) {
            if (object) _self.image = object;
            else _self.image = placeholder;
        }
        if (block) block(object, status);
    }];
    if (result) self.image = placeholder;
    return result;
}

@end
