//
//  PxInputAnimation.h
//  PixLib
//
//  Created by Tobias Kreß on 05.09.12.
//
//

#import <UIKit/UIKit.h>

@interface PxInputAnimation : NSObject
@property (nonatomic, assign) CGRect startFrame;
@property (nonatomic, assign) CGRect endFrame;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) UIViewAnimationCurve curve;
@property (nonatomic, strong) NSString *name;

- (id)initWithStartFrame:(CGRect)startFrame endFrame:(CGRect)endFrame duration:(CGFloat)duration curve:(UIViewAnimationCurve)curve name:(NSString *)name;
- (id)initWithPickerNotification:(NSNotification *)notification;
- (id)initWithKeyboardNotification:(NSNotification *)notification;

- (BOOL)willShow;

@end
