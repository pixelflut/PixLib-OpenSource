//
//  PxHTTPImageCache.m
//  PixLib
//
//  Created by Jonathan Cichon on 09.01.13.
//
//

#import "PxHTTPImageCache.h"
#import "PxCore.h"

@interface PxHTTPImageCache ()
@property(nonatomic, assign) NSInteger memoryCacheSize;
@property(nonatomic, strong) NSMutableDictionary *dataCache;
@property(nonatomic, strong) NSMutableArray *fifoCache;

- (UIImage *)imageForKey:(NSString *)key;
- (void)storeImage:(UIImage *)img forKey:(NSString *)key;


@end

@implementation PxHTTPImageCache

- (id)init {
	return [self initWithMemcacheSize:50];
}

- (id)initWithMemcacheSize:(NSInteger)size {
	if ((self = [super init])) {
		_memoryCacheSize = size;
		_dataCache = [[NSMutableDictionary alloc] initWithCapacity:size];
		_fifoCache = [[NSMutableArray alloc] initWithCapacity:size];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemcacheOnLowMemory:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

#pragma mark - Path Handling
- (NSString *)cacheSubDir {
    return @"images";
}

#pragma mark - Low Memory Handling
- (void)clearMemcacheOnLowMemory:(NSNotification *)notification {
	[_dataCache removeAllObjects];
	[_fifoCache removeAllObjects];
}

#pragma mark - Storage Access
- (UIImage *)imageForURLString:(NSString *)urlString interval:(NSTimeInterval)interval scale:(PxImageScale)scale {
    if (![urlString isNotBlank]) {
        return nil;
    }
    
	NSString *key = [urlString stringByAddingMD5Encoding];
	UIImage *result = [self imageForKey:key];
    
    if (result == nil) {
        NSDictionary *header;
        NSDate *creationDate;
        NSString *savePath = [self pathForURL:[NSURL URLWithString:urlString] header:&header creationDate:&creationDate];
        if (savePath) {
            NSTimeInterval inter = [[NSDate date] timeIntervalSinceDate:creationDate];
            if( creationDate != nil && inter < interval) {
                result = [[UIImage alloc] initWithContentsOfFile:savePath];
                if (scale == PxImageScaleRetina) {
                    result = [[UIImage alloc] initWithCGImage:[result CGImage] scale:2.0 orientation:UIImageOrientationUp];
                }
                if (result != nil) {
                    [self storeImage:result forKey:key];
                }
            }
        }
    }
	return result;
}

- (UIImage *)imageForKey:(NSString *)key {
	id result = nil;
	if (_memoryCacheSize > 0 ) {
		PxPair *tmp = [_dataCache objectForKey:key];
		if (tmp != nil) {
			// move the Image to the front of the cache again
			NSInteger oldIndex = [(NSNumber*)[tmp first] intValue];
			[tmp setFirst:[NSNumber numberWithInt:[_fifoCache count]-1]];
			[_fifoCache removeObjectAtIndex:oldIndex];
			[_fifoCache addObject:key];
			result = [tmp second];
		}
	}
	return result;
}

- (void)storeImage:(UIImage*)img forKey:(NSString*)key {
	if ( _memoryCacheSize > 0 ) {
		if ([_fifoCache count] == _memoryCacheSize) {
			[_dataCache removeObjectForKey:[_fifoCache objectAtIndex:0]];
			[_fifoCache removeObjectAtIndex:0];
		}
		[_fifoCache addObject:key];
		[_dataCache setValue:[PxPair pairWithFirst:[NSNumber numberWithInt:[_fifoCache count]-1] second:img] forKey:key];
	}
}

@end
