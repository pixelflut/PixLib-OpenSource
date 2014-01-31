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
//  NSObject+PxCore.m
//  PxCore OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "NSObject+PxCore.h"
#import "PxCore.h"
#import <objc/message.h>
#import <objc/runtime.h>

static NSDictionary *__associationKeys = nil;

@implementation NSObject (PxCore)

- (NSComparisonResult)compare:(id)object context:(void *)context {
    NSUInteger a = [self hash];
    NSUInteger b = [object hash];
    return PxCompare(a, b);
}

- (BOOL)isNotBlank {
    return YES;
}

+ (BOOL)classRespondsToSelector:(SEL)aSelector {
    Method classMethod = class_getClassMethod([self class], aSelector);
    if (classMethod) {
        return YES;
    }
    return NO;
}

+ (id)classPerformSelector:(SEL)aSelector {
    id (*action)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
    return action(self, aSelector);
}

+ (id)classPerformSelector:(SEL)aSelector withObject:(id)anObject {
    id (*action)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
    return action(self, aSelector, anObject);
}

+ (id)classPerformSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject {
    id (*action)(id, SEL, id, id) = (id (*)(id, SEL, id, id))objc_msgSend;
    return action(self, aSelector, anObject, anotherObject);
}

+ (void)printImplementation {
	Class c = [self class];
	unsigned int count;
	
    NSLog(@"%s : %s", class_getName(c), class_getName(class_getSuperclass(c)));
    
	NSLog(@"Class Methods: ");
	
	Method* class_methods = class_copyMethodList(object_getClass(c), &count);
	for (int i = 0; i < count; ++i) {		
		NSLog(@"%s %s %d", sel_getName(method_getName(class_methods[i])), method_copyReturnType(class_methods[i]), method_getNumberOfArguments(class_methods[i]));
	}
	
	free(class_methods);
	
	NSLog(@"Methods: ");
	Method *methods = class_copyMethodList(c, &count);
	for (int i = 0; i < count; ++i) {
		
		NSLog(@"%s %s %d", sel_getName(method_getName(methods[i])), method_copyReturnType(methods[i]), method_getNumberOfArguments(methods[i]));
	}
	
	free(methods);
	
	NSLog(@"Ivars: ");
	Ivar *ivars = class_copyIvarList(c, &count);
	for (int i = 0; i < count; ++i) {
		NSLog(@"%s %s", ivar_getName(ivars[i]), ivar_getTypeEncoding(ivars[i]));
	}
	
	free(ivars);
	
	NSLog(@"Protocols: ");
	__unsafe_unretained Protocol **ps = class_copyProtocolList(c, &count);
	for (int i = 0; i < count; ++i) {
		NSLog(@"%s", protocol_getName(ps[i]));
	}
	free(ps);
}

+ (void)load {
    __associationKeys = [[NSMutableDictionary alloc] init];
}

- (void)setRuntimeProperty:(id)value name:(NSString *)name {
    NSString *key = [__associationKeys valueForKey:name];
    if (!key) {
        key = name;
        [__associationKeys setValue:key forKey:key];
    }
    objc_setAssociatedObject(self, (__bridge void *)key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)runtimeProperty:(NSString *)property {
    NSString *key = [__associationKeys valueForKey:property];
    if (key) {
        return objc_getAssociatedObject(self, (__bridge void *)key);
    }
    return nil;
}

- (void)setPxProperty:(id)value name:(NSString *)name {
    [self setRuntimeProperty:value name:name];
}

- (id)pxProperty:(NSString *)property {
    return [self runtimeProperty:property];
}


@end
