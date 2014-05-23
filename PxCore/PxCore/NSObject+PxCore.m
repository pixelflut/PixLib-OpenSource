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

static NSString *pxObserverPropertyKey = @"__px_observer_prop_key";
static NSString *pxObserverSignaturKey = @"__px_observer_sig_key";

static NSDictionary *__associationKeys = nil;

@interface PxObserverInfo : NSObject
@property (nonatomic, copy, readonly) void (^block)(id object, NSDictionary *change);
@property (nonatomic, assign, readonly) NSKeyValueObservingOptions options;
@property (nonatomic, strong, readonly) NSString *keyPath;
@property (nonatomic, weak, readonly) id observedObject;
@property (nonatomic, weak, readonly) id observer;
@property (nonatomic, strong, readonly) NSString *observerSignatur;

- (id)initWithObserver:(id)observer observedObject:(id)observedObject keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void (^)(id object, NSDictionary *change))block;

@end

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


- (NSMutableDictionary *)pxObserver {
    NSMutableDictionary *observer = [self runtimeProperty:pxObserverPropertyKey];
    if (!observer) {
        observer = [[NSMutableDictionary alloc] init];
        [self setRuntimeProperty:observer name:pxObserverPropertyKey];
    }
    return observer;
}

- (void)addPxObserverInfo:(PxObserverInfo *)info {
    [self addObserver:info forKeyPath:info.keyPath options:info.options context:(__bridge void *)(info)];
    NSMutableArray *observer = [[self pxObserver] valueForKey:info.observerSignatur];
    if (!observer) {
        observer = [[NSMutableArray alloc] init];
        [[self pxObserver] setValue:observer forKey:info.observerSignatur];
    }
    [observer addObject:info];
}

- (void)addPxObserver:(id)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void (^)(id object, NSDictionary *change))block {
    if (observer && keyPath && block) {
        PxObserverInfo *info = [[PxObserverInfo alloc] initWithObserver:observer observedObject:self keyPath:keyPath options:options block:block];
        [self addPxObserverInfo:info];
    }
}

- (void)removePxObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    NSMutableArray *observerArray = [[self pxObserver] valueForKey:observer.pxObserverSignatur];
    [observerArray deleteIf:^BOOL(PxObserverInfo *info) {
        if ([info.keyPath isEqualToString:keyPath]) {
            [self removeObserver:info forKeyPath:keyPath];
            return YES;
        }
        return NO;
    }];
}

- (void)removePxObserver:(NSObject *)observer {
    [self removePxObserverWithSignatur:observer.pxObserverSignatur];
}

- (void)removePxObserverWithSignatur:(NSString *)signatur {
    NSMutableArray *observerArray = [[self pxObserver] valueForKey:signatur];
    for (PxObserverInfo *info in observerArray) {
        [self removeObserver:info forKeyPath:info.keyPath];
    }
    [[self pxObserver] setValue:nil forKey:signatur];
}

- (NSString *)pxObserverSignatur {
    NSString *sig = [self runtimeProperty:pxObserverSignaturKey];
    if (!sig) {
        sig = [[NSUUID UUID] UUIDString];
        [self setRuntimeProperty:sig name:pxObserverSignaturKey];
    }
    return sig;
}

@end


@implementation PxObserverInfo

- (id)initWithObserver:(id)observer observedObject:(id)observedObject keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void (^)(id object, NSDictionary *change))block {
    self = [super init];
    if (self) {
        _block = block;
        _options = options;
        _keyPath = keyPath;
        _observer = observer;
        _observedObject = observedObject;
        _observerSignatur = [observer pxObserverSignatur];
        
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.observer) {
        self.block(object, change);
    } else {
        [object removePxObserverWithSignatur:self.observerSignatur];
    }
}

- (void)dealloc {
    [self.observedObject removePxObserverWithSignatur:self.observerSignatur];
}

@end