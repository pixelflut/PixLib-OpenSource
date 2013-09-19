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
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <objc/message.h>
#import <objc/runtime.h>

static inline CGFloat PxDeviceScale();
static inline CGFloat CGFloatNormalizeForDevice(CGFloat f);
static inline CGPoint CGPointNormalizeForDevice(CGPoint point);
static inline CGSize CGSizeNormalizeForDevice(CGSize size);


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

static inline UIEdgeInsets UIEdgeInsetsFlipHorizontal(UIEdgeInsets insets) {
	float tmp = insets.left;
	insets.left = insets.right;
	insets.right = tmp;
	return insets;
}

static inline UIEdgeInsets UIEdgeInsetsFlipVertical(UIEdgeInsets insets) {
	float tmp = insets.top;
	insets.top = insets.bottom;
	insets.bottom = tmp;
	return insets;
}

static inline CGRect CGRectNormalizeForDevice(CGRect rect) {
	return CGRectMake(CGFloatNormalizeForDevice(rect.origin.x), CGFloatNormalizeForDevice(rect.origin.y), CGFloatNormalizeForDevice(rect.size.width), CGFloatNormalizeForDevice(rect.size.height));
}

#pragma mark - CGSize
static inline CGSize CGSizeNormalizeForDevice(CGSize size) {
	return CGSizeMake(CGFloatNormalizeForDevice(size.width), CGFloatNormalizeForDevice(size.height));
}

#pragma mark - CGPoint
static inline CGFloat CGPointDistance(CGPoint p1, CGPoint p2) {
    CGFloat dx = p1.x-p2.x;
    CGFloat dy = p1.y-p2.y;
    return sqrtf(dx*dx+dy*dy);
}

static inline CGPoint CGPointNormalizeForDevice(CGPoint point) {
	return CGPointMake(CGFloatNormalizeForDevice(point.x), CGFloatNormalizeForDevice(point.y));
}

#pragma mark - CGFloat
static inline CGFloat CGFloatNormalizeForDevice(CGFloat f) {
	return roundf(f * PxDeviceScale()) / PxDeviceScale();
}

#pragma mark - Device
static inline CGFloat PxDeviceScale() {
	static float scale = 0;
	if (!scale) {
		scale = [[UIScreen mainScreen] scale];
	}
	return scale;
}

static inline BOOL PxDeviceIsScale2() {
	return PxDeviceScale() == 2.0;
}

static inline CGSize PxScreenSize() {
	static CGSize screen = {0,0};
	if (screen.width == 0 && screen.height == 0) {
		screen = [[UIScreen mainScreen] bounds].size;
	}
	return screen;
}

static inline CGRect PxApplicationFrame() {
	static CGRect appFrame = {{0,0},{0,0}};
	if (CGRectIsEmpty(appFrame)) {
		appFrame = [[UIScreen mainScreen] applicationFrame];
	}
	return appFrame;
}

static inline BOOL PxDeviceIsLandscape() {
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	return (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight);
}

static inline BOOL PxDeviceIsWide() {
	return PxScreenSize().height == 568;
}

static inline BOOL PxDeviceIsPad() {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

static inline BOOL PxOSAvailable(int os) {
	switch (os) {
		case (__IPHONE_6_0)...(INT_MAX):
			return [[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)];
			break;
		default:
			return NO;
			break;
	}
}

static inline BOOL PxOSIsVersion(int osVersion) {
    return [[[UIDevice currentDevice] systemVersion] intValue] == osVersion;
}

static inline NSString* PxImageName(NSString *imageName) {
	if (PxDeviceIsWide()) {
		NSString *extension = [imageName pathExtension];
		if(extension && ![extension isEqualToString:@""]) {
			NSString *basename = [[imageName lastPathComponent] stringByDeletingPathExtension];
			return [basename stringByAppendingFormat:@"-568h.%@", extension];
		}else {
			return [imageName stringByAppendingString:@"-568h"];
		}
	}
	return imageName;
}

static inline void PxBeginImageContextWithOptions(CGSize size, BOOL opaque) {
    UIGraphicsBeginImageContextWithOptions(size, opaque, PxDeviceScale());
}

static inline void PxBeginImageContext(CGSize size){
    PxBeginImageContextWithOptions(size, NO);
}

#define PxCompare(a,b) ( a<b ? NSOrderedAscending : a>b ? NSOrderedDescending : NSOrderedSame)

#pragma mark - Callculations

typedef CGFloat (^PxInterpolationBlock)(CGFloat, CGFloat, CGFloat);


static PxInterpolationBlock lerp = ^CGFloat(CGFloat t, CGFloat start, CGFloat end) {
    return start * (1 - t) + end * t;
};

static PxInterpolationBlock cubicEaseInOut = ^CGFloat(CGFloat t, CGFloat start, CGFloat end) {
    t *= 2.;
    if (t < 1.) return end/2 * t * t * t + start;
    t -= 2;
    return end/2*(t * t * t + 2) + start;
};

static PxInterpolationBlock sinusEaseInOut = ^CGFloat(CGFloat t, CGFloat start, CGFloat end) {
    return -end/2.f * (cosf(M_PI*t) - 1.f) + start;
};

static PxInterpolationBlock cubicEaseIn = ^CGFloat(CGFloat t, CGFloat start, CGFloat end) {
    return end * t * t * t + start;
};

static PxInterpolationBlock squareEaseIn = ^CGFloat(CGFloat t, CGFloat start, CGFloat end) {
    return end * t * t + start;
};

static PxInterpolationBlock cubicEaseOut = ^CGFloat(CGFloat t, CGFloat start, CGFloat end) {
    t--;
    return end*(t * t * t + 1.f) + start;
};

static PxInterpolationBlock squareEaseOut = ^CGFloat(CGFloat t, CGFloat start, CGFloat end) {
    t--;
    return end*(t * t + 1.f) + start;
};

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

#pragma mark - Macro Helpers

#define MAKESTRING(__VA_ARGS__) #__VA_ARGS__
#define TOSTRING(...) MAKESTRING(__VA_ARGS__)

#define PXUSE(__VAR__) static inline void pxUse##__VAR__() {ABS((int)&__VAR__);}


#pragma mark - ARC Fuckup Helpers
static inline unsigned char *pointerFromObject(void *object) {
    return (unsigned char *)object;
}

static inline void *pointerToInstanceVariable(id object, char *variableName) {
    Ivar instanceVar = class_getInstanceVariable([object class], variableName);
    if (!instanceVar) {
        return nil;
    }
    return (__bridge void *)object + ivar_getOffset(instanceVar);
//    return pointerFromObject((__bridge void *)(object)) + ivar_getOffset(instanceVar);
}

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#pragma mark - CLLocationCoordinate2D
static inline BOOL CLLocationCoordinate2DIsEqual(CLLocationCoordinate2D first, CLLocationCoordinate2D second) {
    return first.latitude == second.latitude && first.longitude == second.longitude;
}
