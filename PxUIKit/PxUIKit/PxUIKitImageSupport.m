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
//  PxUIKitImageSupport.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "PxUIKitImageSupport.h"

UIImageOrientation PxTIFF_UIImageOrientationLUT[] = {
    UIImageOrientationUp,                   // PxTIFFOrientationUnknown
    UIImageOrientationUp,                   // PxTIFFOrientationTopLeft
    UIImageOrientationUpMirrored,           // PxTIFFOrientationTopRight
    UIImageOrientationDown,                 // PxTIFFOrientationBotRight
    UIImageOrientationDownMirrored,         // PxTIFFOrientationBotLeft
    UIImageOrientationLeftMirrored,         // PxTIFFOrientationLeftTop
    UIImageOrientationLeft,                 // PxTIFFOrientationRightTop
    UIImageOrientationRight,                // PxTIFFOrientationRightBot
    UIImageOrientationRightMirrored         // PxTIFFOrientationLeftBot
};

PxTIFFOrientation PxUIImage_TIFFOrientationLUT[] = {
    PxTIFFOrientationTopLeft,               // UIImageOrientationUp
    PxTIFFOrientationBotRight,              // UIImageOrientationDown
    PxTIFFOrientationRightTop,              // UIImageOrientationLeft
    PxTIFFOrientationRightBot,              // UIImageOrientationRight
    PxTIFFOrientationTopRight,              // UIImageOrientationUpMirrored
    PxTIFFOrientationBotLeft,               // UIImageOrientationDownMirrored
    PxTIFFOrientationLeftTop,               // UIImageOrientationLeftMirrored
    PxTIFFOrientationLeftBot                // UIImageOrientationRightMirrored
};

UIImageOrientation PxDevice_UIImageOrientationLUT[] = {
    UIImageOrientationUp,                   // UIDeviceOrientationUnknown
    UIImageOrientationLeft,                 // UIDeviceOrientationPortrait
    UIImageOrientationRightMirrored,        // UIDeviceOrientationPortraitUpsideDown
    UIImageOrientationUp,                   // UIDeviceOrientationLandscapeLeft
    UIImageOrientationDown,                 // UIDeviceOrientationLandscapeRight
    UIImageOrientationUp,                   // UIDeviceOrientationFaceUp
    UIImageOrientationUp                    // UIDeviceOrientationFaceDown
};

CGRect CGRectApplyOrientation(CGRect rect, UIImageOrientation orientation, CGSize size) {
    CGRect resultRect;
    switch (orientation) {
        case UIImageOrientationUp:
            resultRect = rect;
            break;
        case UIImageOrientationDown:
            resultRect = CGRectMake(rect.origin.x, size.height-rect.origin.y-rect.size.height, rect.size.width, rect.size.height);
            break;
        case UIImageOrientationLeft:
            resultRect = CGRectMake(rect.origin.y, size.width-rect.origin.x-rect.size.width, rect.size.height, rect.size.width);
            break;
        case UIImageOrientationRight:
            resultRect = CGRectMake(size.height-rect.origin.y-rect.size.height, rect.origin.x, rect.size.height, rect.size.width);
            break;
        case UIImageOrientationUpMirrored:
            resultRect = CGRectMake(size.width-rect.origin.x-rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
            break;
        case UIImageOrientationDownMirrored:
            resultRect = CGRectMake(size.width-rect.origin.x-rect.size.width, size.height-rect.origin.y-rect.size.height, rect.size.width, rect.size.height);
            break;
        case UIImageOrientationLeftMirrored:
            resultRect = CGRectMake(rect.origin.y, size.width-rect.origin.x-rect.size.width, rect.size.height, rect.size.width);
            break;
        case UIImageOrientationRightMirrored:
            resultRect = CGRectMake(size.height-rect.origin.y-rect.size.height, size.width-rect.origin.x-rect.size.width, rect.size.height, rect.size.width);
            break;
        default:
            break;
    }
    return resultRect;
}

static NSDateFormatter *PxTIFFormater() {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
        });
        
    }
    return formater;
}

NSDictionary *CGImageSourceGetPxImageInfo(CGImageSourceRef imageSource) {
    NSDictionary *sourceDict = (__bridge_transfer NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    return sourceDict;
}

CGRect ExifSubjectAreaFromPxImageInfo(NSDictionary *infoDictionary) {
    id subject = infoDictionary[(__bridge NSString*)kCGImagePropertyExifDictionary][(__bridge NSString*) kCGImagePropertyExifSubjectArea];
    return CGRectFromExifSubjectArea(subject);
}

#ifdef CLLocationCoordinate2D
const PxLocationCoordinate2D kPxLocationCoordinate2DInvalid = kCLLocationCoordinate2DInvalid;
#else
const PxLocationCoordinate2D kPxLocationCoordinate2DInvalid = {-1,-1};
#endif

BOOL PxLocationCoordinate2DIsValid(PxLocationCoordinate2D coord) {
    return coord.latitude == kPxLocationCoordinate2DInvalid.latitude && coord.longitude == kPxLocationCoordinate2DInvalid.longitude;
}

PxLocationCoordinate2D PxImageInfoGetGPSLocation(NSMutableDictionary *infoDictionary) {
    NSDictionary *dict = infoDictionary[(__bridge NSString*)kCGImagePropertyGPSDictionary];
    if (dict) {
        NSNumber *lat = dict[(__bridge NSString*)kCGImagePropertyGPSLatitude];
        NSNumber *lng = dict[(__bridge NSString*)kCGImagePropertyGPSLongitude];
        if (lat && lng) {
            return (PxLocationCoordinate2D){[lat doubleValue], [lng doubleValue]};
        }
    }
    return kPxLocationCoordinate2DInvalid;
}

void PxImageInfoSetGPSLocation(NSMutableDictionary *infoDictionary, PxLocationCoordinate2D location) {
    NSMutableDictionary *gpsDict;
    NSDictionary *dict = infoDictionary[(__bridge NSString*)kCGImagePropertyGPSDictionary];
    if (dict) {
        gpsDict = [dict mutableCopy];
    }else {
        gpsDict = [[NSMutableDictionary alloc] init];
    }
    
    gpsDict[(__bridge NSString*)kCGImagePropertyGPSLatitude] = [NSNumber numberWithFloat:location.latitude];
    gpsDict[(__bridge NSString*)kCGImagePropertyGPSLongitude] = [NSNumber numberWithFloat:location.longitude];
    
    infoDictionary[(__bridge NSString*)kCGImagePropertyGPSDictionary] = gpsDict;
}

#pragma mark - Convinient TIFF Setter/Getter
NSString* PxImageInfoGetComment(NSDictionary *infoDictionary) {
    NSDictionary *dict = infoDictionary[(__bridge NSString*)kCGImagePropertyTIFFDictionary];
    return dict[(__bridge NSString*)kCGImagePropertyTIFFImageDescription];
}

void PxImageInfoSetComment(NSMutableDictionary *infoDictionary, NSString *comment) {
    PxImageInfoSetTIFFValue(infoDictionary, (__bridge NSString*)kCGImagePropertyTIFFImageDescription, comment);
}


NSString* PxImageInfoGetName(NSDictionary *infoDictionary) {
    NSDictionary *dict = infoDictionary[(__bridge NSString*)kCGImagePropertyTIFFDictionary];
    return dict[(__bridge NSString*)kCGImagePropertyTIFFDocumentName];
}

void PxImageInfoSetName(NSMutableDictionary *infoDictionary, NSString *name) {
    PxImageInfoSetTIFFValue(infoDictionary, (__bridge NSString*)kCGImagePropertyTIFFDocumentName, name);
}


NSDate* PxImageInfoGetDate(NSDictionary *infoDictionary) {
    NSDictionary *dict = infoDictionary[(__bridge NSString*)kCGImagePropertyTIFFDictionary];
    return [PxTIFFormater() dateFromString:dict[(__bridge NSString*)kCGImagePropertyTIFFDateTime]];
}

void PxImageInfoSetDate(NSMutableDictionary *infoDictionary, NSDate *date) {
    PxImageInfoSetTIFFValue(infoDictionary, (__bridge NSString*)kCGImagePropertyTIFFDateTime, [PxTIFFormater() stringFromDate:date]);
}

UIImageOrientation PxImageInfoGetOrientation(NSDictionary *infoDictionary) {
    return PxOrientationConvertTIFFToUIImage([PxImageInfoGetTIFFValue(infoDictionary, (__bridge NSString*)kCGImagePropertyTIFFOrientation) intValue]);
}

void PxImageInfoSetOrientation(NSMutableDictionary *infoDictionary, UIImageOrientation orientation) {
    PxImageInfoSetTIFFValue(infoDictionary, (__bridge NSString*)kCGImagePropertyTIFFOrientation, [NSString stringWithFormat:@"%d", PxOrientationConvertUIImageToTIFF(orientation)]);
}

CGSize PxImageInfoGetSize(NSDictionary *infoDictionary) {
    return CGSizeMake([infoDictionary[@"PixelWidth"] intValue], [infoDictionary[@"PixelHeight"] intValue]);
}

#pragma mark - Abstract TIFF Setter/Getter
id PxImageInfoGetTIFFValue(NSDictionary *infoDictionary, NSString *key) {
    NSDictionary *dict = infoDictionary[(__bridge NSString*)kCGImagePropertyTIFFDictionary];
    return dict[key];
}

void PxImageInfoSetTIFFValue(NSMutableDictionary *infoDictionary, NSString *key, NSString *value) {
    NSMutableDictionary *tiffDict;
    NSDictionary *dict = infoDictionary[(__bridge NSString*)kCGImagePropertyTIFFDictionary];
    if (dict) {
        tiffDict = [dict mutableCopy];
    }else {
        tiffDict = [[NSMutableDictionary alloc] init];
    }
    
    [tiffDict setValue:value forKey:key];
    infoDictionary[(__bridge NSString*)kCGImagePropertyTIFFDictionary] = tiffDict;
}

#pragma mark - Face Detection

NSArray* PxImageInfoGetFaceRegions(NSDictionary *infoDictionary) {
    UIImageOrientation orientation = PxImageInfoGetOrientation(infoDictionary);
    
    NSDictionary *regionD = infoDictionary[(__bridge NSString*)kCGImagePropertyExifAuxDictionary][@"Regions"];
    if (regionD) {
        int refW = [regionD[@"WidthAppliedTo"] intValue];
        int refH = [regionD[@"HeightAppliedTo"] intValue];
        CGSize imageSize = CGSizeMake(refW, refH);
        
        NSArray *regions = regionD[@"RegionList"];
        return [regions collect:^id(NSDictionary *region) {
            if ([region[@"Type"] isEqual:@"Face"]) {
                CGRect r = CGRectMake([region[@"X"] floatValue]*refW, [region[@"Y"] floatValue]*refH, [region[@"Width"] floatValue]*refW, [region[@"Height"] floatValue]*refH);
                return [NSValue valueWithCGRect:CGRectApplyOrientation(r, orientation, imageSize)];
            }
            return nil;
        } skipNil:YES];
    }
    return nil;
}

NSDictionary *PxImageDataDetectFaceRegions(NSData *imageData, NSDictionary *infoDictionary) {
    CIContext *context = [CIContext contextWithOptions:nil];
    
    NSDictionary  *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
                                                      forKey:CIDetectorAccuracy];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:opts];
    
    
    CIImage *image = [[CIImage alloc] initWithData:imageData];
    
    opts = [NSDictionary dictionaryWithObject:infoDictionary[(__bridge NSString *)kCGImagePropertyOrientation]
                                       forKey:CIDetectorImageOrientation];
    
    NSArray *features = [detector featuresInImage:image
                                          options:opts];
    CGSize size = image.extent.size;
    if ([features isNotBlank]) {
        NSDictionary *regions = @{@"WidthAppliedTo" : NR(size.width), @"HeightAppliedTo" : NR(size.height), @"RegionList" : [features collect:^id(CIFaceFeature *face) {
            float x, y, width, height;
            x = face.bounds.origin.x/size.width;
            y = face.bounds.origin.y/size.height;
            width = face.bounds.size.width/size.width;
            height = face.bounds.size.height/size.height;
            NSDictionary *faceDict = @{@"Type" : @"Face", @"X" : [NSNumber numberWithFloat:x], @"Y" : [NSNumber numberWithFloat:y], @"Width" : [NSNumber numberWithFloat:width], @"Height" : [NSNumber numberWithFloat:height]};
            return faceDict;
        }]};
        return @{(__bridge NSString*)kCGImagePropertyExifAuxDictionary : @{@"Regions" : regions}};
    }
    return nil;
}

UIImageOrientation PxOrientationConvertTIFFToUIImage(PxTIFFOrientation orientation) {
    if (orientation < 9) {
        return PxTIFF_UIImageOrientationLUT[orientation];
    }
    return UIImageOrientationUp;
}

PxTIFFOrientation PxOrientationConvertUIImageToTIFF(UIImageOrientation orientation) {
    if ((int)orientation < 8) {
        return PxUIImage_TIFFOrientationLUT[orientation];
    }
    return PxTIFFOrientationUnknown;
}

UIImageOrientation PxOrientationConvertDeviceToUIImage(UIDeviceOrientation orientation) {
    if (orientation < 7) {
        return PxDevice_UIImageOrientationLUT[orientation];
    }
    return UIImageOrientationUp;
}