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
//  PxUIKitImageSupport.h
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#pragma once
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <PxCore/PxCore.h>

typedef enum {
    PxTIFFOrientationUnknown    = 0,
    PxTIFFOrientationTopLeft    = 1,
    PxTIFFOrientationTopRight   = 2,
    PxTIFFOrientationBotRight   = 3,
    PxTIFFOrientationBotLeft    = 4,
    PxTIFFOrientationLeftTop    = 5,
    PxTIFFOrientationRightTop   = 6,
    PxTIFFOrientationRightBot   = 7,
    PxTIFFOrientationLeftBot    = 8
} PxTIFFOrientation;

typedef enum {
    PxOrientationTypeUIImage,
    PxOrientationTypeTIFF,
    PxOrientationTypeDevice
} PxOrientationType;

#ifdef CLLocationCoordinate2D
typedef CLLocationCoordinate2D PxLocationCoordinate2D;
#else
typedef double PxLocationDegrees;
typedef struct {
    PxLocationDegrees latitude;
    PxLocationDegrees longitude;
} PxLocationCoordinate2D;
#endif

extern const PxLocationCoordinate2D kPxLocationCoordinate2DInvalid;
BOOL PxLocationCoordinate2DIsValid(PxLocationCoordinate2D coord);


static inline CGRect CGRectFromExifSubjectArea(NSArray *subjectArea) {
    if ([subjectArea count] == 4) {
        return CGRectMake([subjectArea[0] floatValue], [subjectArea[1] floatValue], [subjectArea[2] floatValue], [subjectArea[3] floatValue]);
    }
    return CGRectNull;
}

static inline NSArray *ExifSubjectAreaFromCGRect(CGRect rect) {
    if (!CGRectIsEmpty(rect)) {
        return @[NR(rect.origin.x), NR(rect.origin.y), NR(rect.size.width), NR(rect.size.height)];
    }
    return nil;
}

CGRect CGRectApplyOrientation(CGRect rect, UIImageOrientation orientation, CGSize size);

NSDictionary* CGImageSourceGetPxImageInfo(CGImageSourceRef imageSource);

CGRect ExifSubjectAreaFromPxImageInfo(NSDictionary *infoDictionary);

PxLocationCoordinate2D PxImageInfoGetGPSLocation(NSDictionary *infoDictionary);
void PxImageInfoSetGPSLocation(NSMutableDictionary *infoDictionary, PxLocationCoordinate2D location);

NSString* PxImageInfoGetComment(NSDictionary *infoDictionary);
void PxImageInfoSetComment(NSMutableDictionary *infoDictionary, NSString *comment);

NSString* PxImageInfoGetName(NSDictionary *infoDictionary);
void PxImageInfoSetName(NSMutableDictionary *infoDictionary, NSString *name);

NSDate* PxImageInfoGetDate(NSDictionary *infoDictionary);
void PxImageInfoSetDate(NSMutableDictionary *infoDictionary, NSDate *date);

UIImageOrientation PxImageInfoGetOrientation(NSDictionary *infoDictionary);
void PxImageInfoSetOrientation(NSMutableDictionary *infoDictionary, UIImageOrientation orientation);

id PxImageInfoGetTIFFValue(NSDictionary *infoDictionary, NSString *key);
void PxImageInfoSetTIFFValue(NSMutableDictionary *infoDictionary, NSString *key, NSString *value);

CGSize PxImageInfoGetSize(NSDictionary *infoDictionary);

#pragma mark - Face Infos
NSArray* PxImageInfoGetFaceRegions(NSDictionary *infoDictionary);

#pragma mark - CoreMedia
NSDictionary *PxImageDataDetectFaceRegions(NSData *imageData, NSDictionary *infoDictionary);

UIImageOrientation PxOrientationConvertTIFFToUIImage(PxTIFFOrientation orientation);
PxTIFFOrientation PxOrientationConvertUIImageToTIFF(UIImageOrientation orientation);
UIImageOrientation PxOrientationConvertDeviceToUIImage(UIDeviceOrientation orientation);