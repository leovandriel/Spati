//
//  UIButton+Spati.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "UIButton+Spati.h"
#import "NSObject+Spati.h"


@implementation UIButton (Spati)

- (id<WDSCancel>)setImageWithKey:(id)key pipe:(WDSPipe *)pipe placeholder:(UIImage *)placeholder block:(void(^)(UIImage *, WDSStatus))block
{
    __weak __typeof(self)weakSelf = self;
    id result = [self objectForKey:key pipe:pipe block:^(id object, WDSStatus status) {
        __strong __typeof(weakSelf)_self = weakSelf;
        if (status != WDSStatusCancelled) {
            if (object) [_self setImage:object forState:UIControlStateNormal];
            else [_self setImage:placeholder forState:UIControlStateNormal];
        }
        if (block) block(object, status);
    }];
    if (result) [self setImage:placeholder forState:UIControlStateNormal];
    return result;
}

@end
