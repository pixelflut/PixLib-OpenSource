//
//  PxHTTPImageCache.h
//  PixLib
//
//  Created by Jonathan Cichon on 09.01.13.
//
//

#import "PxHTTPCache.h"
#import <UIKit/UIKit.h>

typedef enum {
    PxImageScaleDefault = 0,
    PxImageScaleRetina  = 1
} PxImageScale;

@interface PxHTTPImageCache : PxHTTPCache
- (UIImage *)imageForURLString:(NSString *)urlString interval:(NSTimeInterval)interval scale:(PxImageScale)scale;
@end
