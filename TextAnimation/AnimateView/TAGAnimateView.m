//
//  TAGAnimateView.m
//  TextAnimation
//
//  Created by TAG on 21/12/14.
//  Copyright (c) 2014 TAG. All rights reserved.
//

#import "TAGAnimateView.h"
#import "CoolCUUPUtill.h"
#import <QuartzCore/QuartzCore.h>

#define TEXT_PADDING 0
#define TEXT_SPACING 0

//1.5 Height
//3 Width

@interface TAGAnimateView ()
{
    BOOL isRotateLeft,isRotateRight;
    int leftCount,rightCount;
    UILabel *currentLabel;
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
    self.textColor = [UIColor whiteColor];
//    self.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:35];
    self.font = [UIFont boldSystemFontOfSize:35];
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
    isRotateRight = NO;
    leftCount = 0;
    rightCount = 0;
    self.clipsToBounds = YES;
    
    _textArray = [[NSMutableArray alloc] init];
    _labelArray = [[NSMutableArray alloc] init];
    [self setDefaultSettings];
    self.stopTextAnimation = NO;
    [self beginAnimationForNextString];
}

- (void)stopAnimation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.layer removeAllAnimations];
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
        else
        {
            //Infinite Text Aniamtion
            NSString *animationText = [CoolCUUPUtill getAnimationText];
            //Text Animation start
            [self stopAnimation];
            [self addStringToAnimate:animationText];
            [self startAnimation];
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
    currentLabel = textLabel;
    [self animateNewTextLabel:textLabel];
    [self.labelArray addObject:textLabel];
}

- (UILabel *)newLabelWithText:(NSString *)text {
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [textLabel setFont:self.font];
    textLabel.textColor = self.textColor;
    textLabel.text = [text uppercaseString];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    //    textLabel.backgroundColor = [UIColor blueColor];
    [self addSubview:textLabel];
    
    CGRect frame = textLabel.frame;
    frame.size = self.textSize;
    frame.origin.x = self.frame.size.width/3;
    //    if(self.labelArray.count ==0 && self.textArray.count>10)
    //    frame.origin.y = self.frame.size.height/2 - self.textSize.height - TEXT_PADDING - self.font.pointSize+30;
    //    else
    frame.origin.y = self.frame.size.height/2 - self.textSize.height - TEXT_PADDING - self.font.pointSize;
    textLabel.frame = frame;
    [textLabel sizeToFit];
    
    textLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    textLabel.layer.shadowOpacity = 0.50;
    textLabel.layer.shadowRadius =  1.0;
    textLabel.shadowOffset = CGSizeMake(1,5);
    textLabel.layer.masksToBounds = NO;
    
    
    
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
    int i = 1;
    for (UILabel *textLabel in self.labelArray) {
        if(i%10 == 0 && i>rightCount)
        {
            [self rotateRight:5 valueIndex:i];
            [self rotateRight:4 valueIndex:i];
            [self rotateRight:3 valueIndex:i];
            [self rotateRight:2 valueIndex:i];
            [self rotateRight:1 valueIndex:i];
            
            for(int k=6;k<=10;k++)
            {
                UILabel *label = [self.labelArray objectAtIndex:i-k];
                label.hidden = YES;
            }
            isRotateRight = YES;
            rightCount = i;
        }
        else if(i%5==0 && (i>leftCount && !(i%10==0)))
        {
            [self rotateLeft:1 valueIndex:i];
            [self rotateLeft:2 valueIndex:i];
            [self rotateLeft:3 valueIndex:i];
            [self rotateLeft:4 valueIndex:i];
            [self rotateLeft:5 valueIndex:i];
            
            if(i>10)
            {
                for(int k=6;k<=10;k++)
                {
                    UILabel *label = [self.labelArray objectAtIndex:i-k];
                    label.hidden = YES;
                }
            }
            
            leftCount = i;
            isRotateLeft = YES;
        }
        else{
            //For 1st label diff
//            if(i==2)
//            {
//                UILabel *prevTextLable = [self.labelArray objectAtIndex:0];
//                CGFloat diff = textLabel.frame.origin.y-prevTextLable.frame.origin.y;
//                if(diff>40)
//                {
//                    NSLog(@"difff....%f",diff);
//                    CGRect frame = prevTextLable.frame;
//                    frame.origin = CGPointMake(frame.origin.x, frame.origin.y+diff-80);
//                    prevTextLable.frame = frame;
//                    
//                }
//            }
            CGRect frame = textLabel.frame;
            frame.origin = CGPointMake(frame.origin.x, frame.origin.y - self.textSize.height - TEXT_SPACING);
            textLabel.frame = frame;
        }
        i++;
    }
}

-(void)rotateLeft:(int)index valueIndex:(int)valueIndex
{
    UILabel *textLabel = [self.labelArray objectAtIndex:valueIndex-index];
    CGRect prevFrame = textLabel.frame;
    textLabel.transform = CGAffineTransformMakeRotation (-3.14/2);
    
    CGRect newframe = CGRectMake(prevFrame.origin.x, prevFrame.origin.y-textLabel.frame.size.height+prevFrame.size.height, textLabel.frame.size.width,textLabel.frame.size.height);
    
    CGRect frame = newframe;
    if(index!=1)
        frame.origin = CGPointMake(frame.origin.x-(self.textSize.height*index), frame.origin.y+(self.textSize.height*(index)));
    else
        frame.origin = CGPointMake(frame.origin.x-(self.textSize.height*index), frame.origin.y);
    
    textLabel.frame = frame;
    
}

-(void)rotateRight:(int)index valueIndex:(int)valueIndex
{
    
    UILabel *textLabel = [self.labelArray objectAtIndex:valueIndex-index];
    CGRect prevFrame = textLabel.frame;
    
    textLabel.transform = CGAffineTransformMakeRotation (3.14/2);
    
    CGRect newframe = CGRectMake(currentLabel.frame.origin.x+currentLabel.frame.size.width, prevFrame.origin.y-textLabel.frame.size.height+prevFrame.size.height, textLabel.frame.size.width,textLabel.frame.size.height);
    
    CGRect frame = newframe;
    if(index!=1)
        frame.origin = CGPointMake(frame.origin.x-10+(self.textSize.height*(index-1)), frame.origin.y+(self.textSize.height*(index)));
    else
        frame.origin = CGPointMake(frame.origin.x-10, frame.origin.y);
    
    textLabel.frame = frame;
}

- (void)removeLabels {
    for (UILabel *textLabel in self.labelArray) {
        [textLabel removeFromSuperview];
    }
    [self.labelArray removeAllObjects];
}

@end
