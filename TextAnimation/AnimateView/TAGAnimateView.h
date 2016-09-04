//
//  TAGAnimateView.h
//  TextAnimation
//
//  Created by TAG on 21/12/14.
//  Copyright (c) 2014 TAG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAGAnimateView : UIView

@property (strong,nonatomic) UIFont *font;
@property (strong,nonatomic) UIColor *textColor;
@property (assign,nonatomic) CGSize textSize;

- (void)removeLabels;
- (void)addStringToAnimate:(NSString *)string;
- (void)startAnimation;
- (void)stopAnimation;
@end
