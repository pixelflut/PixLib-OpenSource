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
//  PxUIKitSupport.h
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//


#import <UIKit/UIKit.h>

#ifndef PixLib_PxUIkitSupport_h
#define PixLib_PxUIkitSupport_h

typedef struct {
    __unsafe_unretained UIFont *font;
    CGFloat minimumScaleFactor;
    NSLineBreakMode lineBreakMode;
    BOOL adjustsFontSizeToFitWidth;
    NSInteger numberOfLines;
	CGFloat amountOfKerning;
} PxFontConfig;

static inline PxFontConfig
PxFontConfigMake(UIFont *font, CGFloat minimumScaleFactor, NSLineBreakMode lineBreakMode, BOOL adjustsFontSizeToFitWidth, NSInteger numberOfLines, CGFloat amountOfKerning) {
    PxFontConfig config;
    config.font = font;
    config.minimumScaleFactor = minimumScaleFactor;
    config.lineBreakMode = lineBreakMode;
    config.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth;
    config.numberOfLines = numberOfLines;
    config.amountOfKerning = amountOfKerning;
    return config;
}

// Statusbar
#define STATUS_BAR_STYLE_BLACK_TRANSLUCENT_OPACITY 0.6
#define STATUS_BAR_STYLE_BLACK_TRANSLUCENT_FONT_OPACITY 0.75
#define STATUS_BAR_ANIMATION_FADE_IN_DURATION 0.35
#define STATUS_BAR_ANIMATION_FADE_OUT_DURATION 0.35

static inline CGFloat PxDeviceScale();
static inline CGFloat CGFloatNormalizeForDevice(CGFloat f);
static inline CGPoint CGPointNormalizeForDevice(CGPoint point);
static inline CGSize CGSizeNormalizeForDevice(CGSize size);


#pragma mark - UIEdgeInsets
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

#pragma mark - CGRect
static inline CGRect CGRectNormalizeForDevice(CGRect rect) {
	return CGRectMake(CGFloatNormalizeForDevice(rect.origin.x), CGFloatNormalizeForDevice(rect.origin.y), CGFloatNormalizeForDevice(rect.size.width), CGFloatNormalizeForDevice(rect.size.height));
}

static inline CGRect UIEdgeInsetsInsetRectHorizontal(CGRect rect, UIEdgeInsets insets) {
	insets.top = 0;
	insets.bottom = 0;
	return UIEdgeInsetsInsetRect(rect, insets);
}

static inline CGRect UIEdgeInsetsInsetRectVertical(CGRect rect, UIEdgeInsets insets) {
	insets.left = 0;
	insets.right = 0;
	return UIEdgeInsetsInsetRect(rect, insets);
}

static inline UIEdgeInsets UIEdgeInsetsInsideOut(UIEdgeInsets insets) {
	insets.top = -insets.top;
    insets.left = -insets.left;
	insets.bottom = -insets.bottom;
    insets.right = -insets.right;
	return insets;
}

#pragma mark - CGSize
static inline CGSize CGSizeNormalizeForDevice(CGSize size) {
	return CGSizeMake(CGFloatNormalizeForDevice(size.width), CGFloatNormalizeForDevice(size.height));
}

#pragma mark - CGPoint
static inline CGPoint CGPointNormalizeForDevice(CGPoint point) {
	return CGPointMake(CGFloatNormalizeForDevice(point.x), CGFloatNormalizeForDevice(point.y));
}

#pragma mark - CGFloat
static inline CGFloat CGFloatNormalizeForDevice(CGFloat f) {
	return roundf(f * PxDeviceScale()) / PxDeviceScale();
}

static inline CGFloat CGFloatFloorForDevice(CGFloat f) {
	return floorf(f * PxDeviceScale()) / PxDeviceScale();
}

static inline CGFloat CGFloatCeilForDevice(CGFloat f) {
	return ceilf(f * PxDeviceScale()) / PxDeviceScale();
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

static inline BOOL PxOSVersionMajor() {
    return [[[UIDevice currentDevice] systemVersion] intValue];
}

static inline BOOL PxOSIsVersion(int osVersion) {
    return PxOSVersionMajor() == osVersion;
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


#endif
