//
//  PxActionButtonConfig.h
//  PixLib
//
//  Created by Jonathan Cichon on 31.10.12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    PxActionButtonTypeDefault,
    PxActionButtonTypeCancel,
    PxActionButtonTypeDestroy
} PxActionButtonType;

typedef void (^PxActionButtonConfigBlock)(void);

@interface PxActionButtonConfig : NSObject
@property(nonatomic, readonly, assign) int visibleButtonCount;

- (void)addButtonTitle:(NSString *)title block:(PxActionButtonConfigBlock)block;
- (void)setDestructiveButton:(NSString *)title block:(PxActionButtonConfigBlock)block;
- (void)setCancelButton:(NSString *)title block:(PxActionButtonConfigBlock)block;

- (void)setObject:(id)block forKeyedSubscript:(NSString *)title;
- (void)executeButtonAtIndex:(unsigned int)index;

- (NSString *)titleAtIndex:(unsigned int)index;
- (unsigned int)indexOfTitle:(NSString *)title;

- (unsigned int)cancelIndex;
- (unsigned int)destructiveIndex;

- (void)reorderButtons;

@end
