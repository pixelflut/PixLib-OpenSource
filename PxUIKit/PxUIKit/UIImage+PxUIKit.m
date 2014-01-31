//
//  UIImage+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "UIImage+PxUIKit.h"
#import <PxCore/PxCore.h>
#import "PxUIkitSupport.h"
#import "PxUIKitImageSupport.h"

@implementation UIImage (PxUIKit)

#pragma mark - Public Methods
+ (NSURL *)urlForImageName:(NSString *)imageName {
	NSString *basename = imageName;
	NSString *extension = [imageName pathExtension];
	if(extension && ![extension isEqualToString:@""]) {
		basename = [[imageName lastPathComponent] stringByDeletingPathExtension];
	}
	if(!extension || [extension isEqualToString:@""]) {
		extension = @"png";
	}
    NSString *imagePath;
	
    if(PxDeviceIsScale2()) {
		NSString *basenameScale2 = [basename stringByAppendingString:@"@2x"];
        imagePath = [[NSBundle mainBundle] pathForResource:basenameScale2 ofType:extension];
	}
    
    if (!imagePath) {
        imagePath = [[NSBundle mainBundle] pathForResource:basename ofType:extension];
    }
    
    if (!imagePath) {
        return nil;
    }
	return [NSURL fileURLWithPath:imagePath];;
}


+ (CGSize)sizeForImageName:(NSString *)imageName {
    static NSMutableDictionary *__imageSizeCache = nil;
    if (!__imageSizeCache) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            __imageSizeCache = [[NSMutableDictionary alloc] init];
        });
    }
    NSValue *value = [__imageSizeCache valueForKey:imageName];
    if (!value) {
        CGSize size = CGSizeZero;
        NSURL *imageURL = [[self class] urlForImageName:imageName];
        if(imageURL) {
            CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
            if(imageSourceRef != NULL) {
                NSDictionary *infos = CGImageSourceGetPxImageInfo(imageSourceRef);
                CFRelease(imageSourceRef);
                size = PxImageInfoGetSize(infos);
                if(PxDeviceIsScale2()) {
                    size.width /= 2;
                    size.height /= 2;
                }
            }
        }
        value = [NSValue valueWithCGSize:size];
        [__imageSizeCache setValue:value forKey:imageName];
    }
    return [value CGSizeValue];
}

- (UIImage*)imageCropedInRect:(CGRect)rect {
    PxBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    [self drawInRect:CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage*)imageWithSize:(CGSize)s contentMode:(UIViewContentMode)mode {
    CGRect rect = CGRectFromSize(s);
    PxBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    [self drawInRect:rect contentMode:mode];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage*)imageWithSize:(CGSize)s {
    return [self imageWithSize:s contentMode:UIViewContentModeScaleToFill];
}

+ (UIImage *)imageWithMaskImage:(UIImage *)maskImage tintColor:(UIColor *)tintColor {
    PxBeginImageContext(maskImage.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextClipToMask(ctx, CGRectFromSize(maskImage.size), [maskImage CGImage]);
    CGContextSetFillColorWithColor(ctx, [tintColor CGColor]);
    CGContextFillRect(ctx, CGRectFromSize(maskImage.size));
    
	CGImageRef image = CGBitmapContextCreateImage(ctx);
	UIImage *output = [UIImage imageWithCGImage:image scale:PxDeviceScale() orientation:([maskImage imageOrientation] == UIImageOrientationUp ? UIImageOrientationDownMirrored : UIImageOrientationUp)];
	CGImageRelease(image);
	
    UIGraphicsEndImageContext();
    return output;
}

+ (UIImage *)imageWithMaskImage:(UIImage *)maskImage tintColor:(UIColor *)tintColor shadowOffset:(CGSize)shadowOffset shadowBlur:(CGFloat)shadowBlur shadowColor:(UIColor *)shadowColor {
    return [self imageWithMaskImage:maskImage tintColor:tintColor shadowOffset:shadowOffset shadowBlur:shadowBlur shadowColor:shadowColor center:NO];
}

+ (UIImage *)imageWithMaskImage:(UIImage *)maskImage tintColor:(UIColor *)tintColor shadowOffset:(CGSize)shadowOffset shadowBlur:(CGFloat)shadowBlur shadowColor:(UIColor *)shadowColor center:(BOOL)center {
    UIImage *image = [self imageWithMaskImage:maskImage tintColor:tintColor];
	
	CGRect rect = CGRectFromSize(image.size);
	CGRect rectWithBlur = CGRectMake(-shadowBlur, -shadowBlur, image.size.width+2*shadowBlur, image.size.height+2*shadowBlur);
	rectWithBlur = CGRectOffset(rectWithBlur, shadowOffset.width, shadowOffset.height);
	CGRect rectUnion = CGRectUnion(rect, rectWithBlur);
	
	if(center) {
		float diffX = (rect.size.width - rectUnion.size.width) / 2 - rectUnion.origin.x;
		float diffY = (rect.size.height - rectUnion.size.height) / 2 - rectUnion.origin.y;
		
		rectUnion = CGRectOffset(rectUnion, diffX, diffY);
	}
	
    PxBeginImageContext(rectUnion.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
	CGContextSetShadowWithColor(ctx, shadowOffset, shadowBlur, [shadowColor CGColor]);
	[image drawAtPoint:CGPointMake(-rectUnion.origin.x, -rectUnion.origin.y)];
	
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
	UIImage *output = [UIImage imageWithCGImage:imageRef scale:PxDeviceScale() orientation:UIImageOrientationUp];
	CGImageRelease(imageRef);
	
    UIGraphicsEndImageContext();
    return output;
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor {
    return [UIImage imageWithMaskImage:self tintColor:tintColor];
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor shadowOffset:(CGSize)shadowOffset shadowBlur:(CGFloat)shadowBlur shadowColor:(UIColor *)shadowColor {
	return [UIImage imageWithMaskImage:self tintColor:tintColor shadowOffset:shadowOffset shadowBlur:shadowBlur shadowColor:shadowColor center:NO];
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor shadowOffset:(CGSize)shadowOffset shadowBlur:(CGFloat)shadowBlur shadowColor:(UIColor *)shadowColor center:(BOOL)center {
    return [UIImage imageWithMaskImage:self tintColor:tintColor shadowOffset:shadowOffset shadowBlur:shadowBlur shadowColor:shadowColor center:center];
}

#pragma mark - DrawInRect

- (void)drawExtendInRect:(CGRect)rect {
    [self drawExtendInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
}

- (void)drawCropInRect:(CGRect)rect {
    [self drawCropInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
}

- (void)drawExtendInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(float)alpha {
    CGSize s = rect.size;
    CGFloat ratioSelf = (self.size.width / self.size.height);
    CGFloat ratioNew = (s.width / s.height);
    if(ratioNew < ratioSelf){
		float newHeight = floor((s.width/ratioSelf)*PxDeviceScale())/PxDeviceScale();
        [self drawInRect:CGRectMake(rect.origin.x, rect.origin.y+floor(((s.height-newHeight)/2.0)*PxDeviceScale())/PxDeviceScale(), s.width, newHeight) blendMode:blendMode alpha:alpha];
    }else{
		float newWidth = floor((ratioSelf*s.height)*PxDeviceScale())/PxDeviceScale();
        [self drawInRect:CGRectMake(rect.origin.x+floor(((s.width-newWidth)/2.0)*PxDeviceScale())/PxDeviceScale(), rect.origin.y, newWidth, s.height) blendMode:blendMode alpha:alpha];
    }
}

- (void)drawCropInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(float)alpha {
    CGSize s = rect.size;
    CGFloat ratioSelf = (self.size.width / self.size.height);
	CGFloat ratioNew = (s.width / s.height);
	
	if(ratioNew < ratioSelf){
		float newWidth = ratioSelf*s.height;
		float offsetX = floor(((s.width-ratioSelf*s.height)/2.0)*PxDeviceScale())/PxDeviceScale();
        [self drawInRect:CGRectMake(rect.origin.x+offsetX+(offsetX+newWidth < s.width ? 1/PxDeviceScale() : 0), rect.origin.y, newWidth, s.height) blendMode:blendMode alpha:alpha];
	}else{
		float newHeight = s.width/ratioSelf;
		float offsetY = floor(((s.height-s.width/ratioSelf)/2.0)*PxDeviceScale())/PxDeviceScale();
        [self drawInRect:CGRectMake(rect.origin.x, rect.origin.y+offsetY+(offsetY+newHeight < s.height ? 1/PxDeviceScale() : 0), s.width, newHeight) blendMode:blendMode alpha:alpha];
	}
}

- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)mode {
    [self drawInRect:rect contentMode:mode blendMode:kCGBlendModeNormal alpha:1.0];
}

- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)mode blendMode:(CGBlendMode)blendMode alpha:(float)alpha {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, rect);
    switch (mode) {
        case UIViewContentModeScaleToFill:
            [self drawInRect:rect blendMode:blendMode alpha:alpha];
            break;
        case UIViewContentModeScaleAspectFit:
            [self drawExtendInRect:rect];
            break;
        case UIViewContentModeScaleAspectFill:
            [self drawCropInRect:rect];
            break;
        case UIViewContentModeCenter:
            [self drawInRect:CGRectMake((rect.size.width-self.size.width)/2, (rect.size.height-self.size.height)/2, self.size.width, self.size.height) blendMode:blendMode alpha:alpha];
            break;
        case UIViewContentModeTop:
            [self drawInRect:CGRectMake((rect.size.width-self.size.width)/2, 0, self.size.width, self.size.height) blendMode:blendMode alpha:alpha];
            break;
        case UIViewContentModeBottom:
            [self drawInRect:CGRectMake((rect.size.width-self.size.width)/2, rect.size.height-self.size.height, self.size.width, self.size.height) blendMode:blendMode alpha:alpha];
            break;
        case UIViewContentModeLeft:
            [self drawInRect:CGRectMake(0, (rect.size.height-self.size.height)/2, self.size.width, self.size.height) blendMode:blendMode alpha:alpha];
            break;
        case UIViewContentModeRight:
            [self drawInRect:CGRectMake(rect.size.width-self.size.width, (rect.size.height-self.size.height)/2, self.size.width, self.size.height) blendMode:blendMode alpha:alpha];
            break;
        case UIViewContentModeTopLeft:
            [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height) blendMode:blendMode alpha:alpha];
            break;
        case UIViewContentModeTopRight:
            [self drawInRect:CGRectMake(rect.size.width-self.size.width, 0, self.size.width, self.size.height) blendMode:blendMode alpha:alpha];
            break;
        case UIViewContentModeBottomLeft:
            [self drawInRect:CGRectMake(0, rect.size.height-self.size.height, self.size.width, self.size.height) blendMode:blendMode alpha:alpha];
            break;
        case UIViewContentModeBottomRight:
            [self drawInRect:CGRectMake(rect.size.width-self.size.width, rect.size.height-self.size.height, self.size.width, self.size.height) blendMode:blendMode alpha:alpha];
            break;
        default:
            [self drawInRect:rect blendMode:blendMode alpha:alpha];
            break;
    }
    CGContextRestoreGState(ctx);
}

@end
