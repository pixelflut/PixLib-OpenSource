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
//  PxSupport.h
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark - Callculations

typedef double_t (^PxInterpolationBlock)(double_t, double_t, double_t);


static PxInterpolationBlock lerp = ^double_t(double_t t, double_t start, double_t end) {
    return start * (1 - t) + end * t;
};

static PxInterpolationBlock cubicEaseInOut = ^double_t(double_t t, double_t start, double_t end) {
    t *= 2.;
    if (t < 1.) return end/2 * t * t * t + start;
    t -= 2;
    return end/2*(t * t * t + 2) + start;
};

static PxInterpolationBlock sinusEaseInOut = ^double_t(double_t t, double_t start, double_t end) {
    return -end/2.f * (cosf(M_PI*t) - 1.f) + start;
};

static PxInterpolationBlock cubicEaseIn = ^double_t(double_t t, double_t start, double_t end) {
    return end * t * t * t + start;
};

static PxInterpolationBlock squareEaseIn = ^double_t(double_t t, double_t start, double_t end) {
    return end * t * t + start;
};

static PxInterpolationBlock cubicEaseOut = ^double_t(double_t t, double_t start, double_t end) {
    t--;
    return end*(t * t * t + 1.f) + start;
};

static PxInterpolationBlock squareEaseOut = ^double_t(double_t t, double_t start, double_t end) {
    t--;
    return end*(t * t + 1.f) + start;
};

#pragma mark - CGRect
static inline CGRect CGRectFromSize(CGSize s) {
	return CGRectMake(0, 0, s.width, s.height);
}

static inline CGRect CGRectCenter(CGRect bounds, CGRect rect) {
    return CGRectMake((int)(bounds.size.width-rect.size.width)/2+bounds.origin.x, (int)(bounds.size.height-rect.size.height)/2+bounds.origin.y, rect.size.width, rect.size.height);
}

static inline CGRect CGRectCenterHorizontal(CGRect bounds, CGRect rect) {
    return CGRectMake((int)(bounds.size.width-rect.size.width)/2+bounds.origin.x, (int)rect.origin.y, rect.size.width, rect.size.height);
}

static inline CGRect CGRectCenterVertical(CGRect bounds, CGRect rect) {
    return CGRectMake((int)rect.origin.x, (int)(bounds.size.height-rect.size.height)/2+bounds.origin.y, rect.size.width, rect.size.height);
}

static inline CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}


#pragma mark - CGPoint
static inline CGFloat CGPointDistance(CGPoint p1, CGPoint p2) {
    CGFloat dx = p1.x-p2.x;
    CGFloat dy = p1.y-p2.y;
    return sqrtf(dx*dx+dy*dy);
}

static inline CGPoint CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}


#pragma mark - Macro Helpers

#define PxCompare(a,b) ( a<b ? NSOrderedAscending : a>b ? NSOrderedDescending : NSOrderedSame)

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

#define MAKESTRING(__VA_ARGS__) #__VA_ARGS__
#define TOSTRING(...) MAKESTRING(__VA_ARGS__)
#define PXUSE(__VAR__) static inline void pxUse##__VAR__() {ABS((int)&__VAR__);}

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)
