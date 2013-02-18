//
//  PxInputAnimation.m
//  PixLib
//
//  Created by Tobias Kreß on 05.09.12.
//
//

#import "PxInputAnimation.h"
#import "PxUIkit.h"

@implementation PxInputAnimation

- (id)initWithStartFrame:(CGRect)startFrame endFrame:(CGRect)endFrame duration:(CGFloat)duration curve:(UIViewAnimationCurve)curve name:(NSString *)name {
    self = [super init];
    if (self) {
        _startFrame = startFrame;
        _endFrame = endFrame;
        _duration = duration;
        _curve = curve;
        _name = name;
    }
    return self;
}

- (id)initWithPickerNotification:(NSNotification *)not {
    return [self initWithStartFrame:[(NSValue*)[[not userInfo] valueForKey:PxPickerFrameBeginKey] CGRectValue] endFrame:[(NSValue*)[[not userInfo] valueForKey:PxPickerFrameEndKey] CGRectValue] duration:[[[not userInfo] valueForKey:PxPickerAnimationDurationKey] floatValue] curve:[[[not userInfo] valueForKey:PxPickerAnimationCurveKey] intValue] name:not.name];
}

- (id)initWithKeyboardNotification:(NSNotification *)not {
    return [self initWithStartFrame:[(NSValue*)[[not userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] endFrame:[(NSValue*)[[not userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] duration:[[[not userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] curve:[[[not userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] name:not.name];
}

- (BOOL)willShow {
    return CGRectContainsRect([[UIApplication sharedApplication] keyWindow].frame, _endFrame);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\nstartFrame: %@\nendFrame: %@\nduration: %f\ncurve: %d\nname: %@", [super description], NSStringFromCGRect(_startFrame), NSStringFromCGRect(_endFrame), _duration, _curve, _name];
}

@end
