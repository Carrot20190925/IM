//
//  NSTimer+dy_extension.m
//  ID贷
//
//  Created by apple on 2019/7/2.
//  Copyright © 2019 hansen. All rights reserved.
//

#import "NSTimer+dy_extension.h"

@interface DYTimerWeakOBJC : NSObject
@property (nonatomic,weak) id target;
@property (nonatomic,assign) SEL selector;
@property (nonatomic,weak) NSTimer *timer;

- (void)fire;

@end


@implementation NSTimer (dy_extension)

+ (NSTimer *)dy_scheduledWeakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    
    DYTimerWeakOBJC *obj = [DYTimerWeakOBJC new];
    
    obj.selector = aSelector;
    obj.target = aTarget;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ti target:obj selector:@selector(fire) userInfo:userInfo repeats:yesOrNo];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    obj.timer = timer;
    return timer;
    
}
@end


@implementation DYTimerWeakOBJC


- (void)fire {
    
    if (self.target == nil) {
        [self.timer invalidate];
        self.timer = nil;
        return;
    }
    
    if ([self.target respondsToSelector:self.selector]) {
        
        [self.target performSelector:self.selector withObject:self.timer.userInfo];
        
    }
    
}


@end
