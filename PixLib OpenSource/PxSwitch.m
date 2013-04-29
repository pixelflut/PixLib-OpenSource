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
//  PxSwitch.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxSwitch.h"
#import "PxCore.h"

@protocol PxSwitchScrollViewDelegate <UIScrollViewDelegate>

- (void)scrollViewDidBeginTouch:(UIScrollView *)scrollView;
- (void)scrollViewDidCancelTouch:(UIScrollView *)scrollView;

@end

@interface PxSwitchScrollView : UIScrollView

- (void)setDelegate:(id<PxSwitchScrollViewDelegate>)delegate;
- (id<PxSwitchScrollViewDelegate>)delegate;

@end

@interface PxSwitch () <PxSwitchScrollViewDelegate> {
    BOOL uiBuilded;
    BOOL shouldTell;
    BOOL shouldUnHighlight;
}
@property (nonatomic, strong) PxSwitchScrollView *contentView;

- (void)scrollLeft:(BOOL)animated;
- (void)scrollRight:(BOOL)animated;

@end

@implementation PxSwitch
@synthesize contentView		= _contentView;
@synthesize thumbView		= _thumbView;
@synthesize leftView		= _leftView;
@synthesize rightView		= _rightView;
@synthesize backgroundView	= _backgroundView;
@synthesize on				= _on;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setClipsToBounds:YES];
        
        [self buildUI];
        if (!uiBuilded) {
            [NSException raise:@"Wrong Implementation" format:@"%@: You Have to call Super at the end of your buildUI implementation", self.class];
        }
        
        float thumbWidth = _thumbView.frame.size.width;
        float valueWidth = frame.size.width - thumbWidth;
        
        float contentWidth = thumbWidth+2*valueWidth;
        
        _contentView = [[PxSwitchScrollView alloc] initWithFrame:CGRectFromSize(frame.size)];
        [_contentView setDelegate:self];
        [_contentView setContentSize:CGSizeMake(contentWidth, 0)];
        [self addSubview:_contentView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(upEvent)];
        [tap setCancelsTouchesInView:NO];
        [_contentView addGestureRecognizer:tap];
        
        UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, frame.size.height)];
        [_contentView addSubview:dummyView];
        
		[self scrollRight:NO];
    }
    return self;
}

- (void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    [self changeValue:on];
    if(!on){
        [self scrollRight:animated];
    }else{
        [self scrollLeft:animated];
    }
}

- (void)scrollLeft:(BOOL)animated {
    shouldTell = NO;
	[_contentView setHorizontalScrollPercentage:0 animated:animated];
}

- (void)scrollRight:(BOOL)animated {
    shouldTell = NO;
    [_contentView setHorizontalScrollPercentage:1.0 animated:animated];
}

- (void)changeValue:(BOOL)newValue {
    [self setHighlighted:NO];
    if (newValue != _on) {
        _on = newValue;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - Events

- (void)upEvent {
    [self setOn:!_on animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)delayedHighlight {
    [self setHighlighted:NO];
}

- (void)scrollViewDidBeginTouch:(UIScrollView *)scrollView {
    [self setHighlighted:YES];
}

- (void)scrollViewDidCancelTouch:(UIScrollView *)scrollView {
    shouldUnHighlight = YES;
    [self performSelector:@selector(delayedHighlight) withObject:nil afterDelay:0.1];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (shouldUnHighlight) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedHighlight) object:nil];
        shouldUnHighlight = NO;
    }
    
    CGRect refFrame = self.frame;
    float percentage = 1.0-[scrollView horizontalScrollPercentage];
    
    float thumbX = lerp(percentage, 0, refFrame.size.width-_thumbView.frame.size.width);
    CGRect thumbFrame = _thumbView.frame;
    thumbFrame.origin.x = thumbX;
    
    CGRect leftFrame = CGRectMake(0, 0, thumbFrame.origin.x, refFrame.size.height);
    CGRect rightFrame = CGRectMake(CGRectGetMaxX(thumbFrame), 0, refFrame.size.width-CGRectGetMaxX(thumbFrame), refFrame.size.height);
	CGRect backgroundFrame = CGRectMake(0, 0, rightFrame.origin.x, refFrame.size.height);
    
    [_thumbView pxSwitchChangeAppearance:thumbFrame valueFrame:thumbFrame percentage:percentage];
    [_leftView pxSwitchChangeAppearance:thumbFrame valueFrame:leftFrame percentage:percentage];
    [_rightView pxSwitchChangeAppearance:thumbFrame valueFrame:rightFrame percentage:1.0-percentage];
	[_backgroundView pxSwitchChangeAppearance:thumbFrame valueFrame:backgroundFrame percentage:percentage];

    [self setHighlighted:_contentView.isTracking];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    float velo = velocity.x;
    float a;
    float b;
    if (velo < 0) {
        a = 498.9401;
        b = -4.8816;
    }else {
        a = 498.9448;
        b = -4.816;
    }
    float x = scrollView.contentOffset.x+roundf(a*velo+b);
    
    float max = scrollView.contentSize.width-self.frame.size.width;
    float evalPos = max -_thumbView.frame.size.width/2;
    
    if (x>=(evalPos/2.0)) {
        x = max;
    }else {
        x = 0;
    }
    targetContentOffset->x = x;
    if (targetContentOffset->x == scrollView.contentOffset.x) {
        [self changeValue:(scrollView.contentOffset.x == 0)];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self changeValue:(scrollView.contentOffset.x == 0)];
    shouldTell = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (shouldTell) {
        [self changeValue:(scrollView.contentOffset.x == 0)];
    }
    shouldTell = YES;
}

- (void)buildUI {
    if (!_leftView || !_rightView || !_thumbView) {
        [NSException raise:@"Wrong Implementation" format:@"%@: You Have to assign leftView, rightView and thumbView in your buildUI implementation", self.class];
    }else {
		if(_backgroundView) {
			[self addSubview:_backgroundView];
		}
        [self addSubview:_leftView];
        [self addSubview:_rightView];
        [self addSubview:_thumbView];
    }
    uiBuilded = YES;
}

#pragma mark - Helpers

- (void)setEnabled:(BOOL)enabled {
    if (enabled != self.enabled) {
        [super setEnabled:enabled];
        [@[_thumbView, _leftView, _rightView, _backgroundView] each:^(id obj) {
            if([obj respondsToSelector:@selector(pxSwitchIsEnabled:)]) {
                [obj pxSwitchIsEnabled:enabled];
            }
            if ([obj respondsToSelector:@selector(pxSwitchDidChangeState:)]) {
                [obj pxSwitchDidChangeState:self.state];
            }
        }];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted != self.isHighlighted) {
        [super setHighlighted:highlighted];
        [@[_thumbView, _leftView, _rightView, _backgroundView] each:^(id obj) {
            if([obj respondsToSelector:@selector(pxSwitchIsHighlighted:)]) {
                [obj pxSwitchIsHighlighted:highlighted];
            }
            if ([obj respondsToSelector:@selector(pxSwitchDidChangeState:)]) {
                [obj pxSwitchDidChangeState:self.state];
            }
        }];
    }
}

- (void)setSelected:(BOOL)selected {
    if (selected != self.selected) {
        [super setSelected:selected];
        [@[_thumbView, _leftView, _rightView, _backgroundView] each:^(id obj) {
            if([obj respondsToSelector:@selector(pxSwitchIsSelected:)]) {
                [obj pxSwitchIsSelected:selected];
            }
            if ([obj respondsToSelector:@selector(pxSwitchDidChangeState:)]) {
                [obj pxSwitchDidChangeState:self.state];
            }
        }];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ((!self.isHidden && self.userInteractionEnabled && self.alpha > 0 && self.enabled) && CGRectContainsPoint(CGRectFromSize(self.frame.size), point) ) {
        return [_contentView hitTest:[self convertPoint:point toView:_contentView] withEvent:event];
    }
    return nil;
}

@end


@implementation PxSwitchScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setShowsVerticalScrollIndicator:FALSE];
        [self setShowsHorizontalScrollIndicator:FALSE];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setBounces:NO];
    }
    return self;
}

- (id<PxSwitchScrollViewDelegate>)delegate {
    return (id<PxSwitchScrollViewDelegate>)[super delegate];
}

- (void)setDelegate:(id<PxSwitchScrollViewDelegate>)delegate {
    [super setDelegate:delegate];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self delegate] scrollViewDidBeginTouch:self];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self delegate] scrollViewDidCancelTouch:self];
    [super touchesEnded:touches withEvent:event];
}

@end