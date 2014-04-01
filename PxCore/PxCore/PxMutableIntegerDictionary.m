//
//  PxMutableIntegerDictionary.m
//  PxCore-OpenSource
//
//  Created by Jonathan Cichon on 01.07.13.
//  Copyright (c) 2013 pixelflut GmbH. All rights reserved.
//

#import "PxMutableIntegerDictionary.h"
#import "PxCore.h"

const void *keyRetainCallBack(CFAllocatorRef allocator, const void *value);
void keyReleaseCallBack(CFAllocatorRef allocator, const void *value);
CFStringRef keyDescriptionCallBack(const void *value);
Boolean keyEqualCallBack(const void *value1, const void *value2);
CFHashCode keyHashCallBack(const void *value);

@implementation PxMutableIntegerDictionary {
    CFMutableDictionaryRef __backingDictionary;
}

- (id)init {
    self = [super init];
    if (self) {
        CFDictionaryKeyCallBacks keyCallbacks = {
            .version = 0,
            .retain = keyRetainCallBack,
            .release = keyReleaseCallBack,
            .copyDescription = keyDescriptionCallBack,
            .equal = keyEqualCallBack,
            .hash = keyHashCallBack
        };
        __backingDictionary = CFDictionaryCreateMutable(NULL, 0, &keyCallbacks, &kCFTypeDictionaryValueCallBacks);
        
    }
    return self;
}

- (BOOL)isNotBlank {
    return [self count] != 0;
}

- (NSUInteger)count {
    return CFDictionaryGetCount(__backingDictionary);
}

- (void)setObject:(id)object forKey:(NSInteger)key {
    if (object) {
        CFDictionarySetValue(__backingDictionary, &key, (__bridge const void *)(object));
    } else {
        CFDictionaryRemoveValue(__backingDictionary, &key);
    }
    
}

- (id)objectForKey:(NSInteger)key {
    return CFDictionaryGetValue(__backingDictionary, &key);
}

#pragma mark - Aggregating Items
- (NSMutableArray *)collect:(id (^)(NSInteger key, id value))block {
    return [self collect:block skipNil:NO];
}

- (NSMutableArray *)collect:(id (^)(NSInteger key, id value))block skipNil:(BOOL)skipNil {
    if ([self count] > 0) {
        int **keys = malloc([self count] * sizeof(int *));
        CFDictionaryGetKeysAndValues(__backingDictionary, (const void **)keys, NULL);
        
        NSMutableArray *retValue = [[NSMutableArray alloc] initWithCapacity:[self count]];
        for (int i = 0; i<[self count]; ++i) {
            int *key = (int *)keys[i];
            [retValue addObject:block(*key, [self objectForKey:*key]) skipNil:skipNil];
        }
        free((void *)keys);
        return retValue;
    } else {
        return nil;
    }
}

#pragma mark - Iterating Items
- (PxMutableIntegerDictionary *)eachPair:(void (^)(NSInteger key, id value))block {
    if ([self count] > 0) {
        int **keys = malloc([self count] * sizeof(int *));
        CFDictionaryGetKeysAndValues(__backingDictionary, (const void **)keys, NULL);
        
        for (int i = 0; i<[self count]; ++i) {
            int *key = (int *)keys[i];
            block(*key, [self objectForKey:*key]);
        }
        free((void *)keys);
    }
    return self;
}

#pragma mark - Accessing Items
- (PxPair *)pairForKey:(NSInteger)key {
    id obj = [self objectForKey:key];
    if (obj) {
        return [PxPair pairWithFirst:NR(key) second:obj];
    }
    return nil;
}

#pragma mark - Searching Items
- (id)find:(BOOL (^)(NSInteger key, id value))block {
    if ([self count] > 0) {
        int **keys = malloc([self count] * sizeof(int *));
        CFDictionaryGetKeysAndValues(__backingDictionary, (const void **)keys, NULL);
        
        id retValue;
        for (int i = 0; i<[self count]; ++i) {
            int *key = (int *)keys[i];
            id obj = [self objectForKey:*key];
            if (block(*key, obj)) {
                retValue = obj;
                break;
            }
        }
        free((void *) keys);
        return retValue;
    }
    return nil;
}

- (BOOL)include:(BOOL (^)(NSInteger key, id value))block {
    if ([self count] > 0) {
        int **keys = malloc([self count] * sizeof(int *));
        CFDictionaryGetKeysAndValues(__backingDictionary, (const void **)keys, NULL);
        
        BOOL included = NO;
        for (int i = 0; i < [self count]; ++i) {
            int *key = (int *)keys[i];
            id obj = [self objectForKey:*key];
            if (block(*key, obj)) {
                included = YES;
                break;
            }
        }
        free((void *) keys);
        return included;
    }
    return NO;
}

#pragma mark - memory cleanup
- (void)dealloc {
    if (__backingDictionary) {
        CFRelease(__backingDictionary);
    }
}

@end

const void *keyRetainCallBack(CFAllocatorRef allocator, const void *value) {
    int *val = malloc(sizeof(int));
    *val = *((int *)value);
    return val;
}

void keyReleaseCallBack(CFAllocatorRef allocator, const void *value) {
    free((void *)value);
}

CFStringRef keyDescriptionCallBack(const void *value) {
    return (__bridge CFStringRef)([NSString stringWithFormat:@"%d", *((int *)value)]);
}

Boolean keyEqualCallBack(const void *value1, const void *value2) {
    return (*((int *)value1)) == (*((int *)value2));
}

CFHashCode keyHashCallBack(const void *value) {
    return *((int *)value);
}