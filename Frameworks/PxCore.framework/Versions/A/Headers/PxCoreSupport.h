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
#import "PxPair.h"

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

static inline CGFloat cubeInterp(CGFloat t, CGFloat p0, CGFloat p1, CGFloat p2, CGFloat p3) {
    return powf(1-t, 3)*p0 + 3*powf(1-t, 2)*t*p1 + 3*(1-t)*powf(t, 2)*p2 + powf(t, 3)*p3;
}

static inline CGFloat quadInterp(CGFloat t, CGFloat p0, CGFloat p1, CGFloat p2) {
    return powf(1-t, 2)*p0 + 2*(1-t)*t*p1 + powf(t, 2)*p2;
}

typedef double_t (^PxTimingFunction)(double_t t);

static PxTimingFunction PxEaseLinear = ^double_t(double_t t) {
    return t;
};

static PxTimingFunction PxEaseInQuad = ^double_t(double_t t) {
    return t*t;
};

static PxTimingFunction PxEaseOutQuad = ^double_t(double_t t) {
    return -1*t*(t-2);
};

static PxTimingFunction PxEaseInOutQuad = ^double_t(double_t t) {
    t *= 2.;
    if (t < 1) return 0.5*t*t;
    --t;
    return -0.5 * (t*(t-2) - 1);
};

static PxTimingFunction PxEaseInCubic = ^double_t(double_t t) {
    return t*t*t;
};

static PxTimingFunction PxEaseOutCubic = ^double_t(double_t t) {
    --t;
    return t*t*t + 1;
};

static PxTimingFunction PxEaseInOutCubic = ^double_t(double_t t) {
    t *= 2.;
    if (t < 1) return 0.5*t*t*t;
    t -=2;
    return 0.5*(t*t*t + 2);
};

static PxTimingFunction PxEaseInQuart = ^double_t(double_t t) {
    return t*t*t*t;
};

static PxTimingFunction PxEaseOutQuart = ^double_t(double_t t) {
    --t;
    return -1 * (t*t*t*t - 1);
};

static PxTimingFunction PxEaseInOutQuart = ^double_t(double_t t) {
    t *= 2.0;
    if (t < 1) return 0.5*t*t*t*t;
    t -= 2;
    return -0.5 * (t*t*t*t - 2);
};

static PxTimingFunction PxEaseInQuint = ^double_t(double_t t) {
    return t*t*t*t*t;
};

static PxTimingFunction PxEaseOutQuint = ^double_t(double_t t) {
    --t;
    return t*t*t*t*t + 1;
};

static PxTimingFunction PxEaseInOutQuint = ^double_t(double_t t) {
    t *= 2.0;
    if (t < 1) return 0.5*t*t*t*t*t;
    t-=2;
    return 0.5*(t*t*t*t*t + 2);
};

static PxTimingFunction PxEaseInSine = ^double_t(double_t t) {
    return -1 * cos(t * (M_PI_2)) + 1;
};

static PxTimingFunction PxEaseOutSine = ^double_t(double_t t) {
    return sin(t * (M_PI_2));
};

static PxTimingFunction PxEaseInOutSine = ^double_t(double_t t) {
    return -0.5 * (cos(M_PI*t) - 1);
};

static PxTimingFunction PxEaseInExpo = ^double_t(double_t t) {
    return (t==0) ? 0 : pow(2, 10 * (t - 1));
};

static PxTimingFunction PxEaseOutExpo = ^double_t(double_t t) {
    return (t==1) ? 1 : (-pow(2, -10 * t) + 1);
};

static PxTimingFunction PxEaseInOutExpo = ^double_t(double_t t) {
    if (t==0) return 0;
    if (t==1) return 1;
    t *= 2.0;
    if (t < 1) return 0.5 * pow(2, 10 * (t - 1));
    return 0.5 * (-pow(2, -10 * --t) + 2);
};

static PxTimingFunction PxEaseInCirc = ^double_t(double_t t) {
    return -1 * (sqrt(1 - t*t) - 1);
};

static PxTimingFunction PxEaseOutCirc = ^double_t(double_t t) {
    --t;
    return sqrt(1 - t*t);
};

static PxTimingFunction PxEaseInOutCirc = ^double_t(double_t t) {
    t *= 2.0;
    if (t < 1) return -0.5 * (sqrt(1 - t*t) - 1);
    t -= 2;
    return 0.5 * (sqrt(1 - t*t) + 1);
};

static PxTimingFunction PxEaseInElastic = ^double_t(double_t t) {
    double_t s = 1.70158; double_t p=0; double_t a=1;
    
    if (t==0) return 0;  if (t==1) return 1;  if (!p) p=.3;
    if (a < 1) { a=1; s=p/4; }
    else s = p/(2*M_PI) * asin (1.0/a);
    return -(a*pow(2,10*(t-=1)) * sin( (t-s)*(2*M_PI)/p ));
};

static PxTimingFunction PxEaseOutElastic = ^double_t(double_t t) {
    double_t s=1.70158, p=0, a=1;
    
    if (t==0) return 0;  if (t==1) return 1;  if (!p) p=.3;
    if (a < 1) { a=1; s=p/4; }
    else s = p/(2*M_PI) * asin (1.0/a);
    return a*pow(2,-10*t) * sin( (t-s)*(2*M_PI)/p ) + 1;
};

static PxTimingFunction PxEaseInOutElastic = ^double_t(double_t t) {
    double_t s=1.70158, p=0, a=1;
    t *= 2.0;
    if (t==0) return 0;  if (t==2) return 1;  if (!p) p=(.3*1.5);
    if (a < 1) { a=1; s=p/4; }
    else s = p/(2*M_PI) * asin(1.0/a);
    if (t < 1) return -.5*(a*pow(2,10*(t-=1)) * sin( (t-s)*(2*M_PI)/p ));
    return a*pow(2,-10*(t-=1)) * sin( (t-s)*(2*M_PI)/p )*.5 + 1;
};

static PxTimingFunction PxEaseInBack = ^double_t(double_t t) {
    const double_t s = 1.70158;
    return t*t*((s+1)*t - s);
};

static PxTimingFunction PxEaseOutBack = ^double_t(double_t t) {
    const double_t s = 1.70158;
    t--;
    return (t*t*((s+1)*t + s) + 1);
};

static PxTimingFunction PxEaseInOutBack = ^double_t(double_t t) {
    double_t s = 1.70158 * 1.525;
    t *= 2.0;
    
    if (t < 1) return 0.5*(t*t*((s+1)*t - s));
    t -= 2;
    return 0.5*(t*t*((s+1)*t + s) + 2);
};

static PxTimingFunction PxEaseOutBounce = ^double_t(double_t t) {
    if (t < (1/2.75)) {
        return (7.5625*t*t);
    } else if (t < (2/2.75)) {
        t-=(1.5/2.75);
        return (7.5625*t*t + .75);
    } else if (t < (2.5/2.75)) {
        t-=(2.25/2.75);
        return (7.5625*t*t + .9375);
    } else {
        t-=(2.625/2.75);
        return (7.5625*t*t + .984375);
    }
};

static PxTimingFunction PxEaseInBounce = ^double_t(double_t t) {
    return 1 - PxEaseOutBounce(1-t);
};

static PxTimingFunction PxEaseInOutBounce = ^double_t(double_t t) {
    if (t < 0.5)
        return PxEaseInBounce(t*2) * .5;
    else
        return PxEaseOutBounce(t*2-1) * .5 + .5;
};

typedef struct _PxTimingRange {
    CGFloat start;
    CGFloat end;
} PxTimingRange;

NS_INLINE PxTimingRange PxMakeTimingRange(CGFloat start, CGFloat end) {
    PxTimingRange r;
    r.start = start;
    r.end = end;
    return r;
}

static inline CGFloat pxMapTimingExtended(CGFloat t, PxTimingRange src, PxTimingRange dst) {
    return ((t - src.start) / (src.end - src.start)) * (dst.end - dst.start) + dst.start;
};

static inline CGFloat pxMapTiming(CGFloat t, PxTimingRange src) {
    return pxMapTimingExtended(t, src, PxMakeTimingRange(0, 1));
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

#define PxTimingRangeMake(start, end) PxMakeTimingRange(start, end)

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
