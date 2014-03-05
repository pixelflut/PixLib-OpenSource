//
//  PxCollectionReusableView.h
//  PxUIKit
//
//  Created by Jonathan Cichon on 05.03.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PxCollectionReusableView : UICollectionReusableView
@property(nonatomic, weak) UICollectionView *collectionView;
@property(nonatomic, assign) id delegate;
@property(nonatomic, strong) id data;

- (void)setData:(id)data setUI:(BOOL)setUI;

@end

@interface PxCollectionReusableView (SubclassingHooks)

+ (CGSize)sizeWithData:(id)data reuseIdentifier:(NSString *)reuseIdentifier collectionView:(UICollectionView *)collectionView;

- (void)buildUI;
- (void)setUI;

@end