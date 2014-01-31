//
//  UIColor+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "UIColor+PxUIKit.h"

CGColorRef CreateCGColorWithPatternFromUIImage(UIImage *image, CGPoint phaseShift);

@implementation UIColor (PxUIKit)

+ (UIColor *)randomDebugColor {
    float input = arc4random_uniform(31);
    float hue = input/30.0;
    return [self colorWithHue:hue saturation:1.0 brightness:1.0 alpha:0.6];
}

+ (UIColor *)debugColor {
    return [self colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.6];
}

+ (UIColor *)colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha {
    NSUInteger red = (hex>>16) & 0xff;
	NSUInteger green = (hex>>8) & 0xff;
	NSUInteger blue = hex & 0xff;
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

+ (UIColor *)colorWithHex:(NSUInteger)hex {
    return [self colorWithHex:hex alpha:1.0];
}

+ (UIColor *)colorWithPatternImage:(UIImage *)patternImage phaseShift:(CGPoint)phaseShift {
    CGColorRef cgColor = CreateCGColorWithPatternFromUIImage(patternImage, phaseShift);
    UIColor *ret = [[UIColor alloc] initWithCGColor:cgColor];
    CGColorRelease(cgColor);
    return ret;
}

- (void)getRGBA:(CGFloat*)buffer {
    CGColorRef clr = [self CGColor];
	NSInteger n = CGColorGetNumberOfComponents(clr);
	const CGFloat *colors = CGColorGetComponents(clr);
	switch (n) {
		case 2:
			for (int i = 0; i<3; ++i){
				buffer[i] = colors[0];
			}
			buffer[3] = CGColorGetAlpha(clr);
			break;
		case 3:
			for (int i = 0; i<3; ++i){
				buffer[i] = colors[i];
			}
			buffer[3] = 1.0;
			break;
		case 4:
			for (int i = 0; i<4; ++i){
				buffer[i] = colors[i];
			}
			break;
		default:
            for (int i = 0; i<3; i++) {
                buffer[i] = 0;
            }
			break;
	}
}

- (NSString*)hexString {
    CGFloat rgb[4];
	[self getRGBA:rgb];
	return [NSString stringWithFormat:@"%X%X%X%X", (int)(rgb[0]*255), (int)(rgb[1]*255), (int)(rgb[2]*255), (int)(rgb[3]*255)];
}

- (int)hexValue {
    CGFloat rgb[4];
	[self getRGBA:rgb];
	return ((int)(rgb[0]*255)<<16) & 0xff + ((int)(rgb[1]*255)<<8) & 0xff + (int)(rgb[2]*255) & 0xff;
}

@end

typedef struct {
    float hue;
    float val;
    float sat;
} hsv_color;

typedef struct {
    float r;
    float g;
    float b;
}rgb_color;

hsv_color HSVfromRGB(rgb_color rgb);

#define max(a,b) ((a) > (b) ? (a) : (b))
#define max3(a,b,c) (max((a), max((b),(c))))

#define min(a,b) ((a) < (b) ? (a) : (b))
#define min3(a,b,c) (min((a), min((b),(c))))

hsv_color HSVfromRGB(rgb_color rgb){
    hsv_color hsv;
    
    CGFloat rgb_min, rgb_max;
    rgb_min = min3(rgb.r, rgb.g, rgb.b);
    rgb_max = max3(rgb.r, rgb.g, rgb.b);
    
    if (rgb_max == rgb_min) {
        hsv.hue = 0;
    } else if (rgb_max == rgb.r) {
        hsv.hue = 60.0f * ((rgb.g - rgb.b) / (rgb_max - rgb_min));
        hsv.hue = fmodf(hsv.hue, 360.0f);
    } else if (rgb_max == rgb.g) {
        hsv.hue = 60.0f * ((rgb.b - rgb.r) / (rgb_max - rgb_min)) + 120.0f;
    } else if (rgb_max == rgb.b) {
        hsv.hue = 60.0f * ((rgb.r - rgb.g) / (rgb_max - rgb_min)) + 240.0f;
    }
    hsv.val = rgb_max;
    if (rgb_max == 0) {
        hsv.sat = 0;
    } else {
        hsv.sat = 1.0 - (rgb_min / rgb_max);
    }
    
    return hsv;
}


// optimize using UIImage instead of CGImage, so apple caching/purge can be used
typedef struct {
    CGImageRef image;
    CGPoint phaseShift;
} pxPatternInfo;

// callback for CreateImagePattern.
static void DrawPatternImage(void *info, CGContextRef ctx) {
    pxPatternInfo *patternInfo = info;
    CGImageRef image = patternInfo->image;
    float x = patternInfo->phaseShift.x;
    float y = patternInfo->phaseShift.y;
    CGContextDrawTiledImage(ctx, CGRectMake(-x,-y, CGImageGetWidth(image),CGImageGetHeight(image)), image);
}

// callback for CreateImagePattern.
static void ReleasePatternImage( void *info ) {
    pxPatternInfo *patternInfo = info;
    CGImageRelease(patternInfo->image);
    free(patternInfo);
}

CGColorRef CreateCGColorWithPatternFromUIImage(UIImage *image, CGPoint phaseShift) {
    CGImageRef cgImage =  CGImageRetain([image CGImage]);
    
    pxPatternInfo *info = malloc(sizeof(pxPatternInfo));
    info->image = cgImage;
    info->phaseShift = phaseShift;
    
    CGFloat width = [image size].width;
    CGFloat height = [image size].height;
    static const CGPatternCallbacks callbacks = {0, &DrawPatternImage, &ReleasePatternImage};
    CGPatternRef pattern = CGPatternCreate(info,
                                           CGRectMake(0, 0, width, height),
                                           CGAffineTransformMake(1, 0, 0, 1, 0, 0),
                                           width,
                                           height,
                                           kCGPatternTilingConstantSpacing,
                                           true,
                                           &callbacks);
    CGColorSpaceRef space = CGColorSpaceCreatePattern(NULL);
    CGFloat components[1] = {1.0};
    CGColorRef color = CGColorCreateWithPattern(space, pattern, components);
    CGColorSpaceRelease(space);
    CGPatternRelease(pattern);
    return color;
}
