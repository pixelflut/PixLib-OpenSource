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
//  PxPair.m
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxPair.h"

@implementation PxPair

+ (id)pairWithFirst:(id)first second:(id)second {
    return [[[self class] alloc] initWithFirst:first second:second];
}

- (id)initWithFirst:(id)f second:(id)s {
    self = [super init];
    if (self) {
        self.first = f;
        self.second = s;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.first = [decoder decodeObjectForKey:@"first"];
        self.second = [decoder decodeObjectForKey:@"second"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_first forKey:@"first"];
    [coder encodeObject:_second forKey:@"second"];
}

- (BOOL)isEqualToPair:(PxPair *)object {
    if (self == object)
        return YES;
    
    if (_first && _second) {
        return [_first isEqual:[object first]] && [_second isEqual:[object second]];
    } else if (_first) {
        return [_first isEqual:[object first]] && ![object second];
    } else if (_second) {
        return [_second isEqual:object.second] && ![object first];
    }
    return ![object first] && ![object second];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@: %p>{\n\tfirst: %@\n\tsecond: %@\n}", [self class], self, _first, _second];
}

- (BOOL)isNotBlank {
    return (_first || _second);
}

#pragma mark - Modern Objective-C Accessor
- (void)setObject:(id)anObject forKeyedSubscript:(NSString *)title {
    [self setValue:anObject forKey:title];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self valueForKey:key];
}

- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)idx {
    switch (idx) {
        case 0:
            [self setFirst:anObject];
            break;
        case 1:
            [self setSecond:anObject];
            break;
        default:
            [NSException raise:NSRangeException format:@"index (%lu) out of range (0 1)", (unsigned long)idx];
            break;
    }
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    switch (idx) {
        case 0:
            return _first;
            break;
        case 1:
            return _second;
            break;
        default:
            [NSException raise:NSRangeException format:@"index (%lu) out of range (0 1)", (unsigned long)idx];
            return nil;
            break;
    }
}

@end
