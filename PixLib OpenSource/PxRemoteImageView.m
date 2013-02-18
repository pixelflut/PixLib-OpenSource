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
//  PxRemoteImageView.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxRemoteImageView.h"
#import "PxCore.h"
#import "PxHTTPRemoteService.h"
#import "PxHTTPImageCache.h"

@interface PxRemoteImageService : PxHTTPRemoteService

@end

@interface PxRemoteImageView ()
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIImageView *bgImageView;

@property(nonatomic, strong) PxHTTPConnection *connection;
@property(nonatomic, assign) Boolean cachedImgIfFailed;
@property(nonatomic, strong) NSString *currentCacheString;
@property(nonatomic, strong) NSString *smallUrl;
@property(nonatomic, strong) NSString *bigUrl;

- (void)getImageForUrl:(NSString *)urlStr;
- (void)setImage:(UIImage *)i;
- (PxImageScale)scaleForUrl:(NSString *)urlStr;

@end

@implementation PxRemoteImageView
@synthesize image = _image;

+ (PxRemoteImageService *)remoteService {
    static PxRemoteImageService *sharedInstance = nil;
	if (sharedInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[PxRemoteImageService alloc] init];
        });
	}
	return sharedInstance;
}

+ (PxHTTPConnection *)preloadImageFromUrl:(NSString *)urlStr completionBlock:(void (^)(PxResult *result))completionBlock {
    PxCaller *caller = [[PxCaller alloc] initWithTarget:self action:@selector(didFetchPreloadImage:) userInfo:completionBlock options:PxRemoteOptionDisk];
    return [(PxRemoteImageService *)[self remoteService] pushRequest:[NSMutableURLRequest requestWithUrlString:urlStr] interval:INT_MAX caller:caller];
}

+ (void)didFetchPreloadImage:(PxResult *)result {
    void (^completionBlock)(PxResult *result) = result.caller.userInfo;
    if (completionBlock) {
        completionBlock(result);
    }
}

#pragma mark - Initializer
- (void)buildUI {
    _bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [_bgImageView setDefaultResizingMask];
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [_imageView setDefaultResizingMask];
    
    [self addSubview:_bgImageView];
    [self addSubview:_imageView];
}

-(void)setDefaults {
	_cacheInterval = 60*60*24*7;
	_cachedImgIfFailed = YES;
    [self setAutoresizesSubviews:YES];
    [self setUserInteractionEnabled:NO];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (id)init {
	return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)f {
    self = [super initWithFrame:f];
    if (self) {
		[self setDefaults];
        [self buildUI];
    }
    return self;
}

- (id)initWithImage:(UIImage *)img {
	return [self initWithDefaultImage:img];
}

- (id)initWithDefaultImage:(UIImage *)img {
    self = [self initWithFrame:CGRectFromSize(img.size)];
	if (self) {
		[self setDefaultImage:img];
	}
	return self;
}

- (id)initWithSmallUrl:(NSString*)small bigUrl:(NSString*)big {
    self = [self init];
	if (self) {
		[self setImageWithSmallUrl:small bigUrl:big];
	}
	return self;
}

#pragma mark - Setter
- (void)setImageWithSmallUrl:(NSString*)small bigUrl:(NSString*)big {
    if (small != _smallUrl) {
        _smallUrl = small;
    }
    if (big != _bigUrl) {
        _bigUrl = big;
    }
	
	NSString *urlString = small;
	if (![small isNotBlank] || (PxDeviceIsScale2() && [big isNotBlank])) {
		urlString = big;
	}
    if (urlString == nil) {
        [self setImage:_defaultImage];
        return;
    }
    
    NSString *cacheKey = urlString;
    if ([cacheKey isEqualToString:_currentCacheString]) {
        return;
    } else {
        _currentCacheString = nil;
        [self setImage:_defaultImage];
    }
    
    [self getImageForUrl:urlString];
}

- (void)setDefaultImage:(UIImage *)img {
    if (_defaultImage != img) {
        _defaultImage = img;
        [_bgImageView setImage:_defaultImage];
		if (_image == nil) {
            [self setImageVisible:NO];
		}
    }
}

- (void)setImageVisible:(BOOL)visible {
    UIView *fromView;
    UIView *toView;
    
    if (visible) {
        fromView = _bgImageView;
        toView = _imageView;
    } else {
        fromView = _imageView;
        toView = _bgImageView;
    }
    
    void (^changeBlock)(void) = ^() {
        [fromView setAlpha:0];
        [toView setAlpha:1];
    };
    
    if (false) {
        [UIView animateWithDuration:0.2 animations:changeBlock];
    }else {
        changeBlock();
    }
    
//    [UIView transitionFromView:fromView toView:toView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];

    if ([self respondsToSelector:@selector(drawRect:)]) {
        [self setNeedsDisplay];
    }
}

- (void)setImage:(UIImage *)i {
    UIImage *img = i;
    if (img != _image) {
        _image = img;
        [_imageView setImage:_image];
        [self setImageVisible:YES];
    }
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    [_imageView setContentMode:contentMode];
    [_bgImageView setContentMode:contentMode];
}

- (UIImage *)currentImage {
    return _imageView.image;
}

#pragma mark - Communication
- (int)remoteOptions {
    return PxRemoteOptionDisk;
}

- (void)cancelConnection {
    [_connection removeCallersWithTarget:self];
    _connection = nil;
}

- (void)willLoadRemoteImage {}

- (void)loadRemoteImage:(NSString*)urlStr {
    unsigned int options = [self remoteOptions];
    PxCaller *caller = [[PxCaller alloc] initWithTarget:self action:@selector(didFetchImage:) userInfo:_currentCacheString options:options];
    [self cancelConnection];
    
    _connection =  [(PxRemoteImageService *)[[self class] remoteService] pushRequest:[NSMutableURLRequest requestWithUrlString:urlStr] interval:_cacheInterval caller:caller];
    if (_connection != nil) {
        [self willLoadRemoteImage];
        if(_delegate && [_delegate respondsToSelector:@selector(imageView:willLoadImageWithUrlString:)]) {
            [_delegate imageView:self willLoadImageWithUrlString:urlStr];
        }
    }
}

- (void)getImageForUrl:(NSString *)urlStr {
	NSString *cacheKey = urlStr;
	if (![_currentCacheString isEqualToString:cacheKey]) {
		_currentCacheString = cacheKey;

        PxHTTPImageCache *cache = (PxHTTPImageCache *)[[[self class] remoteService] cache];
        id result = [cache imageForURLString:urlStr interval:_cacheInterval scale:[self scaleForUrl:urlStr]];
		if (result == nil) {
			NSString *otherCacheUrl = nil;
			if ([_bigUrl isEqualToString:urlStr] && [_smallUrl isNotBlank]) {
                otherCacheUrl = _smallUrl;
			}else if([_smallUrl isEqualToString:urlStr] && [_bigUrl isNotBlank]){
				otherCacheUrl = _bigUrl;
			}
			if (otherCacheUrl != nil) {
				result = [cache imageForURLString:otherCacheUrl interval:_cacheInterval scale:[self scaleForUrl:otherCacheUrl]];
			}
		}
		if (result != nil) {
            PxResult *r = [[PxResult alloc] initWithCaller:[PxCaller callerWithTarget:self action:@selector(didFetchImage:) userInfo:_currentCacheString options:PxRemoteOptionDisk]];
            [r setReturnObject:result];
            [r setStatus:200];
			[self didFetchImage:r];
		}else {
            [self loadRemoteImage:urlStr];
		}
	}
}

- (void)didFetchImage:(PxResult *)result {
	if([result status] < 400 && (_cachedImgIfFailed == YES || (_cachedImgIfFailed == NO && [result status] != PxHTTPStatusCodeCache)) && [_currentCacheString isEqualToString:result.caller.userInfo]) {
        UIImage *origImg = nil;
        if ([result.returnObject isKindOfClass:[UIImage class]]) {
            origImg = result.returnObject;
        }else if (result.filePath) {
            PxHTTPImageCache *cache = (PxHTTPImageCache *)[[[self class] remoteService] cache];
            origImg = [cache imageForURLString:result.caller.userInfo interval:_cacheInterval scale:[self scaleForUrl:result.caller.userInfo]];
        }
        
        if( _delegate != nil && [_delegate respondsToSelector:@selector(imageView:didLoadOriginalImage:)] ) {
            [_delegate imageView:self didLoadOriginalImage:origImg];
        }
        
        [self setImage:origImg];
        
        if (_delegate != nil && [_delegate respondsToSelector:@selector(imageView:didLoad:)]) {
            [_delegate imageView:self didLoad:YES];
        }
	}else {
		// Get the other image if device-specific failed
		if (PxDeviceIsScale2() && [_bigUrl isNotBlank] && [_bigUrl isEqualToString:result.caller.userInfo] && [_smallUrl isNotBlank]) {
			[self getImageForUrl:_smallUrl];
		}else if (!PxDeviceIsScale2() && [_smallUrl isNotBlank] && [_smallUrl isEqualToString:result.caller.userInfo] && [_bigUrl isNotBlank]) {
			[self getImageForUrl:_bigUrl];
		}else if([_currentCacheString isEqualToString:result.caller.userInfo]) {
			if (_errorImage != nil) {
                [_bgImageView setImage:_errorImage];
                [self setImageVisible:NO];
			}
			if (_delegate != nil && [_delegate respondsToSelector:@selector(imageView:didLoad:)]) {
				[_delegate imageView:self didLoad:NO];
			}
		}
	}
}

- (void)didMoveToSuperview {
    if ([self superview] == nil) {
        [self cancelConnection];
    }
}

#pragma mark - Helper
- (PxImageScale)scaleForUrl:(NSString *)urlStr {
    if ([_bigUrl isNotBlank] && [_bigUrl isEqualToString:urlStr]) {
        return PxImageScaleRetina;
    }
    return PxImageScaleDefault;
}

@end


@implementation PxRemoteImageService

- (Class)httpCacheClass {
    return [PxHTTPImageCache class];
}

@end