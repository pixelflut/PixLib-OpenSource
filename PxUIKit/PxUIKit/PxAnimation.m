/*
 * Copyright (c) 2013 pixelflut GmbH, http://pixelflut.net
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 */

//
//  PxAnimation.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 26.03.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxAnimation.h"
#import <PxCore/PxCore.h>

static inline CGFloat overBounceValue(NSUInteger step, NSUInteger n, CGFloat overbounce) {
    CGFloat stepTime = (CGFloat)step/((CGFloat)n);
    CGFloat valueDelta = overbounce * (1-cubicEaseOut(stepTime, 0, 1));
    if (step%2 == 1) {
        return 1.0 - (valueDelta*1.0);
    } else {
        return 1.0 + (valueDelta*1.0);
    }
}

CGFloat oscilattedInterpolation(CGFloat t, NSUInteger numberOffRipples, CGFloat overbounce) {
    if (numberOffRipples < 1 || overbounce > 1) {
        return sinusEaseInOut(t, 0, 1);
    } else {
        CGFloat stepsize = 1.0/(numberOffRipples+1.0);
        NSInteger currentStep = t/stepsize;
        CGFloat minValue = 0;
        if (currentStep > 0) {
            minValue = overBounceValue(currentStep-1, numberOffRipples, overbounce);
        }
        
        CGFloat maxValue = overBounceValue(currentStep, numberOffRipples, overbounce);
        
        CGFloat stepInTime = (t-stepsize*currentStep)/stepsize;
        
        CGFloat val = sinusEaseInOut(stepInTime, 0, 1);
        
        return lerp(val, minValue, maxValue);
    }
    return 0;
}

@interface PxAnimation () {
    NSTimeInterval currentBlockTime;
}

@property (nonatomic, assign, readonly) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableArray *animationBlocks;
@property (nonatomic, copy) PxTimingFunction timingFunction;
@property (nonatomic, copy) void (^completion)(BOOL finished);

- (instancetype)initWithTimingFunction:(PxTimingFunction)function;

- (void)addAnimations:(void (^)(NSTimeInterval time))animations;
- (void)startLinkedAnimation;

- (void)applyAnimationSteps:(CGFloat)time;

- (NSTimeInterval)maxTime;


@end

@interface PxOscilattionAnimator : PxAnimation {
    NSUInteger numberOfOscilattions;
    CGFloat overBounceFactor;
}

- (instancetype)initWithTimingFunction:(PxTimingFunction)function numberOfOscilattions:(NSUInteger)numberOfOscilattions overBounceFactor:(CGFloat)overBounceFactor;

@end


@implementation PxAnimation

+ (NSMutableArray *)pxAnimationStack {
    static NSMutableArray *__animationStack = nil;
    if (!__animationStack) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            __animationStack = [[NSMutableArray alloc] init];
        });
    }
    return __animationStack;
}

+ (PxAnimation *)pxAnimationCurrent {
    return [[self pxAnimationStack] lastObject];
}

+ (void)pxAnimationPush:(PxAnimation *)animation {
    [[self pxAnimationStack] addObject:animation];
}

+ (void)pxAnimationPop {
    [[self pxAnimationStack] removeLastObject];
}


+ (instancetype)pxAnimatePercentDriven:(NSTimeInterval)duration
                         timingFunction:(PxTimingFunction)timingFunction
                             animations:(void (^)(void))animations
                             completion:(void (^)(BOOL finished))completion {
    
    PxAnimation *animator = [[PxAnimation alloc] initWithTimingFunction:timingFunction];
    animator.completion = completion;
    animator.duration = duration;
    [self pxAnimationPush:animator];
    
    if (animations) {
        animations();
    }
    
    [self pxAnimationPop];
    [animator startLinkedAnimation];
    
    return animator;
}


+ (instancetype)pxAnimatePercentDriven:(NSTimeInterval)duration
                         timingFunction:(PxTimingFunction)timingFunction
                   numberOfOscilattions:(NSUInteger)numberOfOscilattions
                       overBounceFactor:(CGFloat)overBounceFactor
                             animations:(void (^)(void))animations
                             completion:(void (^)(BOOL finished))completion {
    
    PxOscilattionAnimator *animator = [[PxOscilattionAnimator alloc] initWithTimingFunction:timingFunction numberOfOscilattions:numberOfOscilattions overBounceFactor:overBounceFactor];
    animator.completion = completion;
    animator.duration = duration;
    [self pxAnimationPush:animator];
    
    if (animations) {
        animations();
    }
    
    [self pxAnimationPop];
    [animator startLinkedAnimation];
    
    return animator;
}

+ (void)pxAddPercentAnimations:(void (^)(NSTimeInterval percent))animations {
    
    [[self pxAnimationCurrent] addAnimations:animations];
}


- (instancetype)initWithTimingFunction:(PxTimingFunction)function {
    self = [super init];
    if (self) {
        if (!function) {
            function = PxEaseInOutCubic;
        }
        self.timingFunction = function;
        
        self.animationBlocks = [[NSMutableArray alloc] init];
        currentBlockTime = NAN;
    }
    return self;
}

- (void)addAnimations:(void (^)(NSTimeInterval time))animations {
    if (animations) {
        if (currentBlockTime == currentBlockTime) {
            animations(currentBlockTime);
        } else if (!self.displayLink) {
            [self.animationBlocks addObject:animations];
        }
    }
}

- (void)startLinkedAnimation {
    if (self.duration > 0) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimation:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    } else {
        [self applyAnimationSteps:1];
        if (self.completion) {
            self.completion(YES);
        }
    }
}

- (void)cancelAnimation {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)updateAnimation:(CADisplayLink *)link {
    if (_startTime == 0) {
        _startTime = link.timestamp;
    }
    
    CFTimeInterval time = link.timestamp - self.startTime;
    
    BOOL finished = NO;
    if (time >= self.duration) {
        [self cancelAnimation];
        time = self.duration;
        finished = YES;
    }
    
    CGFloat t = time/self.duration;
    [self applyAnimationSteps:self.timingFunction(t)];
    
    if (finished && self.completion) {
        self.completion(finished);
    }
}

- (void)applyAnimationSteps:(CGFloat)time {
    [PxAnimation pxAnimationPush:self];
    currentBlockTime = time;
    for (void (^block)(NSTimeInterval) in self.animationBlocks) {
        block(time);
    }
    [PxAnimation pxAnimationPop];
    currentBlockTime = NAN;
}

- (NSTimeInterval)maxTime {
    return 1;
}

@end


@implementation PxOscilattionAnimator

- (instancetype)initWithTimingFunction:(PxTimingFunction)function numberOfOscilattions:(NSUInteger)n overBounceFactor:(CGFloat)o {
    self = [super initWithTimingFunction:function];
    if (self) {
        numberOfOscilattions = n;
        overBounceFactor = o;
    }
    return self;
}

- (void)applyAnimationSteps:(CGFloat)time {
    [super applyAnimationSteps:oscilattedInterpolation(time, numberOfOscilattions, overBounceFactor)];
}

- (NSTimeInterval)maxTime {
    return overBounceFactor;
}

@end
