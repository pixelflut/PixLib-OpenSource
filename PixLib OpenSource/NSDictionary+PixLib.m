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
//  NSDictionary+PixLib.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "NSDictionary+PixLib.h"
#import "PxCore.h"

@implementation NSDictionary (PixLib)

- (PxPair*)pairForKey:(NSString *)key {
	id value = [self valueForKey:key];
	if (value) {
		return [PxPair pairWithFirst:key second:value];
	}
	return nil;
}

- (NSMutableArray*)collect:(id (^)(id key, id value))block {
    return [self collect:block skipNil:NO];
}

- (NSMutableArray*)collect:(id (^)(id key, id value))block skipNil:(BOOL)skipNil {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[self count]];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [ret addObject:block(key, obj) skipNil:skipNil];
    }];
    return ret;
}

- (NSDictionary*)eachPair:(void (^)(id key, id value))block {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
    return self;
}

- (PxPair*)find:(BOOL (^)(id key, id value))block {
    __block PxPair *ret = nil;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (block(key, obj)) {
            ret = [PxPair pairWithFirst:key second:obj];
            *stop = YES;
        }
    }];
    return ret;
}

- (BOOL)include:(BOOL (^)(id key, id value))block {
    return [self find:block] != nil;
}

- (BOOL)isNotBlank {
    return [self count] != 0;
}

- (NSMutableDictionary*)map:(id (^)(id key, id value))block {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [ret setObject:block(key, obj) forKey:key];
    }];
    return ret;
}

- (NSMutableDictionary*)reject:(BOOL (^)(id key, id value))block {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!block(key, obj)) {
            [ret setObject:obj forKey:key];
        }
    }];
    return ret;
}

- (NSMutableDictionary*)selectAll:(BOOL (^)(id key, id value))block {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (block(key, obj)) {
            [ret setObject:obj forKey:key];
        }
    }];
    return ret;
}

- (NSString *)stringForQuery {
    return [self stringForQuery:NO];
}

- (NSString *)stringForQuery:(BOOL)sorted {
    NSMutableArray *ret = [self collect:^(NSString *key, id value) {
        return [NSString stringWithFormat:@"%@=%@", key, [value stringByAddingURLEncoding]];
    }];
    if (sorted) {
        ret = [ret sort:^(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
    }
    return [ret componentsJoinedByString:@"&"];
}

@end
