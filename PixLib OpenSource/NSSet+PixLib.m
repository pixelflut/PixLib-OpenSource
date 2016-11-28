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
//  NSSet+PixLib.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxCore.h"
#import "NSSet+PixLib.h"
#import "NSMutableArray+PixLib.h"
#import "NSMutableSet+PixLib.h"

@implementation NSSet (PixLib)

- (NSMutableSet *)collect:(id (^)(id obj))block {
    return [self collect:block skipNil:NO];
}

- (NSMutableSet *)collect:(id (^)(id obj))block skipNil:(BOOL)skipNil {
    NSMutableSet *ret = [[NSMutableSet alloc] initWithCapacity:self.count];
    for (id obj in self) {
        [ret addObject:obj skipNil:skipNil];
    }
    return ret;
}

- (unsigned int)count:(BOOL (^)(id obj))block {
    unsigned int c = 0;
    for (id obj in self) {
        if (block(obj)) {
            c++;
        }
    }
    return c;
}

- (NSSet *)each:(void (^)(id obj))block {
    for (id obj in self) {
        block(obj);
    }
    return self;
}

- (id)find:(BOOL (^)(id obj))block {
    for (id obj in self) {
        if (block(obj)) {
            return obj;
        }
    }
    return nil;
}

- (BOOL)include:(BOOL (^)(id obj))block {
    for (id obj in self) {
        if (block(obj)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isNotBlank {
    return [self count] != 0;
}

- (NSMutableDictionary *)groupBy:(id<NSCopying> (^)(id obj))block skipNil:(BOOL)skipNil {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:self.count];
	for (id obj in self) {
		id key = block(obj);
        if (key || !skipNil) {
            if (key) {
                NSMutableSet *tmp = [ret objectForKey:key];
                
                if (tmp == nil) {
                    tmp = [[NSMutableSet alloc] init];
                    [ret setObject:tmp forKey:key];
                }
                [tmp addObject:obj];
            } else {
                [NSException raise:@"nil class exception" format:@"nil key during groupBy"];
            }
        }
	}
	return ret;
}

- (id)max:(NSComparisonResult (^)(id a, id b))block {
    NSUInteger count = [self count];
    if (count == 0) {
        return nil;
    }
    
    id ret = nil;
    for (id obj in self) {
        if (!ret || block(ret, obj) == -1) {
            ret = obj;
        }
    }
    return ret;
}

- (id)min:(NSComparisonResult (^)(id a, id b))block {
    NSUInteger count = [self count];
    if (count == 0) {
        return nil;
    }
    
    id ret = nil;
    for (id obj in self) {
        if (!ret || block(ret, obj) == 1) {
            ret = obj;
        }
    }
    return ret;
}

- (PxPair*)minMax:(NSComparisonResult (^)(id a, id b))block {
    return [PxPair pairWithFirst:[self min:block] second:[self max:block]];
}

- (PxPair *)partition:(BOOL (^)(id obj))block {
    NSMutableSet *_true = [[NSMutableSet alloc] initWithCapacity:self.count];
    NSMutableSet *_false = [[NSMutableSet alloc] initWithCapacity:self.count];
    for (id obj in self) {
        if (block(obj)) {
            [_true addObject:obj];
        }else {
            [_false addObject:obj];
        }
    }
    return [PxPair pairWithFirst:_true second:_false];
}

- (NSMutableSet *)reject:(BOOL (^)(id obj))block {
    NSMutableSet *ret = [[NSMutableSet alloc] initWithCapacity:[self count]];
    for (id obj in self) {
        if (!block(obj)) {
            [ret addObject:obj];
        }
    }
    return ret;
}

- (NSMutableSet *)selectAll:(BOOL (^)(id obj))block {
    NSMutableSet *ret = [[NSMutableSet alloc] initWithCapacity:[self count]];
    for (id obj in self) {
        if (block(obj)) {
            [ret addObject:obj];
        }
    }
    return ret;
}

- (NSMutableArray *)sort:(NSComparisonResult (^)(id a, id b))block {
    if ([self count] > 0) {
        return [[[NSMutableArray alloc] initWithArray:self.allObjects] sort:block];
    }
	return nil;
}

- (float)sum:(float (^)(id obj))block {
    float sum = 0;
	for (id obj in self) {
		sum += block(obj);
	}
	return sum;
}

@end
