//
//  TAGAnimateView.m
//  TextAnimation
//
//  Created by TAG on 21/12/14.
//  Copyright (c) 2014 TAG. All rights reserved.
//

#import "TAGAnimateView.h"

#define TEXT_PADDING 0
#define TEXT_SPACING 0

//1.5 Height
//3 Width

@interface TAGAnimateView ()
{
    BOOL isRotateLeft;
}
@property (strong,nonatomic) NSMutableArray *stringArray;
@property (strong,nonatomic) NSMutableArray *textArray;
@property (strong,nonatomic) NSMutableArray *labelArray;


@property (assign,nonatomic) BOOL stopTextAnimation;

@end


@implementation TAGAnimateView

- (id)init {
    self = [super init];
    if (self) {
        _stringArray = [[NSMutableArray alloc] init];
        _textArray = [[NSMutableArray alloc] init];
        _labelArray = [[NSMutableArray alloc] init];
        [self setDefaultSettings];
    }
    return self;
}

- (void)setDefaultSettings {
    //    self.textSize = CGSizeMake(self.frame.size.width - (TEXT_SPACING * 2), 40);
    self.textSize  = CGSizeMake(200+ (TEXT_SPACING * 2), 35);
    self.textColor = [UIColor blackColor];
    self.font = [UIFont boldSystemFontOfSize:32];
}

- (void)addStringToAnimate:(NSString *)string {
    if (!self.stringArray) {
        self.stringArray = [[NSMutableArray alloc] init];
    }
    [self.stringArray addObject:string];
}

- (void)startAnimation {
    [self removeLabels];
    isRotateLeft = NO;
    self.clipsToBounds = YES;
    
    _textArray = [[NSMutableArray alloc] init];
    _labelArray = [[NSMutableArray alloc] init];
    [self setDefaultSettings];
    self.stopTextAnimation = NO;
    [self beginAnimationForNextString];
}

- (void)stopAnimation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.stopTextAnimation = YES;
    [self.stringArray removeAllObjects];
    [self.textArray removeAllObjects];
}

- (void)beginAnimationForNextString {
    if (self.stopTextAnimation) {
        return;
    }
    if ([self.textArray count] > 0) {
        [self animateNewText];
    }
    else {
        if ([self.stringArray count] > 0) {
            NSString *string = self.stringArray[0];
            [self.stringArray removeObjectAtIndex:0];
            
            self.textArray = [[string componentsSeparatedByString:@" "] mutableCopy];
            if ([self.textArray count] > 0) {
                [self animateNewText];
            }
        }
    }
}

- (void)animateNewText {
    [self performAnimationForText:self.textArray[0]];
    [self.textArray removeObjectAtIndex:0];
    
    if ([self.textArray count] == 0) {
        [self performSelector:@selector(beginAnimationForNextString) withObject:nil afterDelay:1];
    }
    else {
        [self performSelector:@selector(beginAnimationForNextString) withObject:nil afterDelay:0.5];
        
    }
    
    //[self newLabelWithText:string];
}

- (void)performAnimationForText:(NSString *)text {
    UILabel *textLabel = [self newLabelWithText:text];
    [self animateNewTextLabel:textLabel];
    [self.labelArray addObject:textLabel];
}

- (UILabel *)newLabelWithText:(NSString *)text {
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [textLabel setFont:self.font];
    textLabel.textColor = self.textColor;
    textLabel.text = text;
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    //    textLabel.backgroundColor = [UIColor blueColor];
    [self addSubview:textLabel];
    
    CGRect frame = textLabel.frame;
    frame.size = self.textSize;
    frame.origin.x = self.frame.size.width/3;
    frame.origin.y = self.frame.size.height/1.5 - self.textSize.height - TEXT_PADDING - self.font.pointSize-30;
    textLabel.frame = frame;
    [textLabel sizeToFit];
    
    
    //    textLabel.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height - self.textSize.height - TEXT_PADDING - self.font.pointSize);
    return textLabel;
}

- (void)animateNewTextLabel:(UILabel *)textLabel {
    
    CGFloat scaleFactor = 0.0f;
    textLabel.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        CGFloat scaleFactor = 1.5f;
        textLabel.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
        
        [self moveOtherTextLabels];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            CGFloat scaleFactor = 1.0f;
            textLabel.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
        } completion:^(BOOL finished) {
            
        }];
    }];
    
}

- (void)moveOtherTextLabels {
    //    NSMutableArray *movedOutLabels = [[NSMutableArray alloc] init];
    int i = 1;
    for (UILabel *textLabel in self.labelArray) {
        if(i%5==0 && !isRotateLeft)
        {
            [self rotateLeft:1 valueIndex:i];
            [self rotateLeft:2 valueIndex:i];
            [self rotateLeft:3 valueIndex:i];
            [self rotateLeft:4 valueIndex:i];
            [self rotateLeft:5 valueIndex:i];
            isRotateLeft = YES;
            
        }
        else{
            CGRect frame = textLabel.frame;
            frame.origin = CGPointMake(frame.origin.x, frame.origin.y - self.textSize.height - TEXT_SPACING);
            textLabel.frame = frame;
            
            //            if ((textLabel.frame.origin.y + textLabel.frame.size.height) <= 0) {
            //                [movedOutLabels addObject:textLabel];
            //            }
        }
        i++;
    }
    //    for (UILabel *textLabel in movedOutLabels) {
    //        [textLabel removeFromSuperview];
    //        [self.labelArray removeObject:textLabel];
    //    }
}

-(void)rotateLeft:(int)index valueIndex:(int)valueIndex
{
    UILabel *textLabel = [self.labelArray objectAtIndex:valueIndex-index];
    CGRect prevFrame = textLabel.frame;

    NSLog(@"1print frame ...%@",NSStringFromCGRect(textLabel.frame));
    textLabel.transform = CGAffineTransformMakeRotation (-3.14/2);
    NSLog(@"2print frame ...%@",NSStringFromCGRect(textLabel.frame));
    
    CGRect newframe = CGRectMake(prevFrame.origin.x, prevFrame.origin.y-textLabel.frame.size.height+prevFrame.size.height, textLabel.frame.size.width,textLabel.frame.size.height);
    
    CGRect frame = newframe;
    if(index!=1)
        frame.origin = CGPointMake(frame.origin.x-(self.textSize.height*index), frame.origin.y+(self.textSize.height*(index)));
    else
        frame.origin = CGPointMake(frame.origin.x-(self.textSize.height*index), frame.origin.y);
        
    textLabel.frame = frame;
    
    NSLog(@"%f,,,,%f",textLabel.frame.origin.x,textLabel.frame.origin.y);
}

- (void)removeLabels {
    for (UILabel *textLabel in self.labelArray) {
        [textLabel removeFromSuperview];
    }
    [self.labelArray removeAllObjects];
}

@end
