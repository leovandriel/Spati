//
//  WDSPipe.h
//  Spati
//
//  Copyright (c) 2014 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WDSStatus) {
    WDSStatusNone = 0,
    WDSStatusSuccess = 1,
    WDSStatusFailed = 2,
    WDSStatusCancelled = 3,
    WDSStatusNotFound = 4,
};

@protocol WDSCancel <NSObject>
- (void)cancel;
- (BOOL)isCancelled;
@end


@interface WDSMultiCancel : NSObject<WDSCancel>
- (void)addCancel:(id<WDSCancel>)cancel;
- (BOOL)isEmpty;
@end


@interface WDSPipe : NSObject

@property (nonatomic, strong) WDSPipe *next;
@property (nonatomic, copy) NSString *name;

- (instancetype)initWithName:(NSString *)name;

- (id<WDSCancel>)get:(id)key block:(void(^)(id object, WDSStatus status))block;

- (void)appendPipe:(WDSPipe *)pipe;
- (void)insertPipe:(WDSPipe *)pipe afterPipe:(WDSPipe *)after;
- (void)insertPipe:(WDSPipe *)pipe beforePipe:(WDSPipe *)before;

@end
