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
//  NSArray+PixLib.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "NSArray+PixLib.h"
#import "NSMutableArray+PixLib.h"
#import "PxCore.h"

#pragma mark - C-Methods
void _recursiveFlatten_(id src, NSMutableArray *dest, int maxLevel, int currentLevel);

void _recursiveFlatten_(id src, NSMutableArray *dest, int maxLevel, int currentLevel) {
    if ([src isKindOfClass:[NSArray class]] && (currentLevel <= maxLevel || maxLevel == -1) ) {
        for (id obj in src) {
            _recursiveFlatten_(obj, dest, maxLevel, currentLevel+1);
        }
    }else {
        [dest addObject:src];
    }
}

#pragma mark - ObjC-Class
@implementation NSArray (PixLib)

- (BOOL)isNotBlank {
    return [self count] != 0;
}

#pragma mark - Ruby Style Blocks
- (NSMutableArray *)cluster:(BOOL (^)(id obj))block {
    BOOL newCluster = YES;
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (id obj in self) {
        if (block(obj)) {
            NSMutableArray *current;
            if (newCluster) {
                current = [[NSMutableArray alloc] init];
                [ret addObject:current];
                newCluster = NO;
            } else {
                current = [ret lastObject];
            }
            [current addObject:obj];
        } else {
            newCluster = YES;
        }
    }
    return ret;
}

- (NSMutableArray*)collect:(id (^)(id obj))block {
    return [self collect:block skipNil:NO];
}

- (NSMutableArray*)collect:(id (^)(id obj))block skipNil:(BOOL)skipNil {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id obj in self) {
        [ret addObject:block(obj) skipNil:skipNil];
    }
    return ret;
}

- (NSMutableArray*)collectWithIndex:(id (^)(id obj, NSUInteger index))block {
    return [self collectWithIndex:block skipNil:NO]; 
}

- (NSMutableArray*)collectWithIndex:(id (^)(id obj, NSUInteger index))block skipNil:(BOOL)skipNil {
    NSMutableArray* ret = [[NSMutableArray alloc] initWithCapacity:[self count]];
    int i = 0;
    for (id obj in self) {
        [ret addObject:block(obj, i) skipNil:skipNil];
        i++;
    }
    return ret;
}

- (NSMutableArray*)collectWithIndex:(id (^)(id obj, NSUInteger index))block skipNil:(BOOL)skipNil flatten:(BOOL)flatten {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[self count]];
    int i = 0;
    for (id obj in self) {
        id tmp = block(obj, i);
        if (tmp || skipNil) {
            if (flatten && [tmp isKindOfClass:[NSArray class]]) {
                [ret addObjectsFromArray:tmp];
            } else {
                if (tmp) {
                    [ret addObject:tmp];
                } else {
                    [NSException raise:@"nil class exception" format:@"nil value during collect"];
                }
            }
        }
        i++;
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

- (NSMutableArray*)drop:(BOOL (^)(id obj, NSUInteger index))block {
    int c = 0;
    for (id obj in self) {
        if (block(obj, c)) {
            c++;
        }else {
            break;
        }
    }
    NSUInteger count = [self count];
    if (count-c > 0 ) {
        return [RANGE(c, count-c) collect:^id(NSInteger index) {
            return [self objectAtIndex:index];
        }];
    }else {
        return nil;
    }
}

- (NSArray*)eachCons:(unsigned int)number block:(void (^)(NSArray *objs))block {
    NSUInteger count = [self count];
    if (number>=count) {
        block(self);
    }else {
        for (int i = 0; i+number<=count; i++) {
            block([self subarrayWithRange:NSMakeRange(i, number)]);
        }
    }
    return self;
}

- (NSArray*)eachSlice:(unsigned int)number block:(void (^)(NSArray *objs))block {
    NSUInteger count = [self count];
    for (int i = 0; i<count; i+=number) {
        block([self subarrayWithRange:NSMakeRange(i, MIN(number, count-i))]);
    }
    return self;
}

- (NSArray*)each:(void (^)(id obj))block {
    for (id obj in self) {
        block(obj);
    }
    return self;
}

- (NSArray*)eachWithIndex:(void (^)(id obj, NSUInteger index))block {
    int i = 0;
    for (id obj in self) {
        block(obj, i);
        i++;
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

- (id)firstObject {
    if ([self count] > 0) {
        return [self objectAtIndex:0];
    }
    return nil;
}

- (NSMutableArray*)flatten:(int)level {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    _recursiveFlatten_(self, ret, level, 0);
    return ret;
}

- (BOOL)include:(BOOL (^)(id obj))block {
    for (id obj in self) {
        if (block(obj)) {
            return YES;
        }
    }
    return NO;
}

- (NSUInteger)index:(BOOL (^)(id obj))block {
    unsigned int i = 0;
    for (id obj in self) {
        if (block(obj)) {
            return i;
        }
        i++;
    }
    return NSNotFound;
}

- (NSMutableDictionary *)indexBy:(id<NSCopying> (^)(id obj))block {
    return [self indexBy:block skipNil:NO];
}

- (NSMutableDictionary *)indexBy:(id<NSCopying> (^)(id obj))block skipNil:(BOOL)skipNil {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    for (id obj in self) {
        id key = block(obj);
        if (key || !skipNil) {
            if (key) {
                [ret setObject:obj forKey:key];
            } else {
                [NSException raise:@"nil class exception" format:@"nil key during indexBy"];
            }
        }
    }
	return ret;
}

- (id)inject:(id)initial block:(id (^)(id memo, id obj))block {
    for (id obj in self) {
        initial = block(initial, obj);
    }
	return initial;
}

- (NSMutableDictionary *)groupBy:(id<NSCopying> (^)(id obj))block skipNil:(BOOL)skipNil {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:self.count];
	for (id obj in self) {
		id key = block(obj);
        if (key || !skipNil) {
            if (key) {
                NSMutableArray *tmp = [ret objectForKey:key];
                
                if (tmp == nil) {
                    tmp = [[NSMutableArray alloc] init];
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
    
    id ret = [self firstObject];
    for (int i = 1; i<count; i++) {
        id tmp = [self objectAtIndex:i];
        if (block(ret, tmp) == -1) {
            ret = tmp;
        }
    }
    return ret;
}

- (id)min:(NSComparisonResult (^)(id a, id b))block {
    NSUInteger count = [self count];
    if (count == 0) {
        return nil;
    }
    
    id ret = [self firstObject];
    for (int i = 1; i<count; i++) {
        id tmp = [self objectAtIndex:i];
        if (block(ret, tmp) == 1) {
            ret = tmp;
        }
    }
    return ret;
}

- (PxPair*)minMax:(NSComparisonResult (^)(id a, id b))block {
    return [PxPair pairWithFirst:[self min:block] second:[self max:block]];
}

- (id)objectAtIndex:(NSUInteger)index handleBounds:(BOOL)handleBounds {
    if (handleBounds) {
        if (index < self.count) {
            return [self objectAtIndex:index];
        }
    }else {
        return [self objectAtIndex:index];
    }
    return nil;
}

- (NSMutableArray*)paginate:(int)pageSize {
    NSUInteger count = [self count];
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:(count+1)/pageSize];
    for (int i = 0; i<count; i+=pageSize) {
        [ret addObject:[self subarrayWithRange:NSMakeRange(i, MIN(pageSize, count-i))]];
    }
    return ret;
}

- (PxPair*)partition:(BOOL (^)(id obj))block {
    NSMutableArray *_true = [[NSMutableArray alloc] initWithCapacity:[self count]];
    NSMutableArray *_false = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id obj in self) {
        if (block(obj)) {
            [_true addObject:obj];
        }else {
            [_false addObject:obj];
        }
    }
    return [PxPair pairWithFirst:_true second:_false];
}

- (NSMutableArray*)reject:(BOOL (^)(id obj))block {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id obj in self) {
        if (!block(obj)) {
            [ret addObject:obj];
        }
    }
    return ret;
}

- (NSMutableArray*)random {
    NSMutableArray *source = [[NSMutableArray alloc] initWithArray:self];
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[self count]];
    NSUInteger count = [source count];
    while (count > 0) {
        NSUInteger index = arc4random_uniform((u_int32_t) count);
        [ret addObject:[source objectAtIndex:index]];
        [source removeObjectAtIndex:index];
        count--;
    }
    return ret;
}

- (NSMutableArray*)selectAll:(BOOL (^)(id obj))block {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id obj in self) {
        if (block(obj)) {
            [ret addObject:obj];
        }
    }
    return ret;
}

- (NSMutableArray*)selectExpectOrdered:(BOOL (^)(id obj, BOOL *stop))block {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[self count]];
    __block BOOL stop = NO;
    for (id obj in self) {
        if (block(obj, &stop)) {
            [ret addObject:obj];
        }
        if (stop == YES) {break;}
    }
    return ret;
}

- (NSMutableArray*)sort:(NSComparisonResult (^)(id a, id b))block {
    if ([self count] > 0) {
        return [[[NSMutableArray alloc] initWithArray:self] sort:block];
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

- (NSMutableArray*)take:(BOOL (^)(id obj, NSUInteger index))block {
    int c = 0;
    for (id obj in self) {
        if (block(obj, c)) {
            c++;
        }else {
            break;
        }
    }
    if (c > 0 ) {
        return [RANGE(0, c) collect:^id(NSInteger index) {
            return [self objectAtIndex:index];
        }];
    }else {
        return nil;
    }
}

- (NSMutableArray *)uniq {
    return [self uniq:^id(id obj) {
        return obj;
    }];
}

- (NSMutableArray *)uniq:(id<NSCopying> (^)(id obj))block {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSMutableDictionary *lookUp = [[NSMutableDictionary alloc] init];
    NSMutableSet *keySet = [[NSMutableSet alloc] init];
    
    __block int index = 0;
    [self each:^(id obj) {
        id key = block(obj);
        if (![keySet containsObject:key]) {
            [keySet addObject:key];
            [lookUp setObject:obj forKey:NR(index)];
            index++;
        }
    }];
    for (int i = 0; i<index; i++) {
        [ret addObject:[lookUp objectForKey:NR(i)]];
    }
    return ret;
}

@end
