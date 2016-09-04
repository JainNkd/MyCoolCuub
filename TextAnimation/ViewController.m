//
//  ViewController.m
//  TextAnimation
//
//  Created by TAG on 21/12/14.
//  Copyright (c) 2014 TAG. All rights reserved.
//

#import "ViewController.h"
#import "TAGAnimateView.h"
#import "HPGrowingTextView.h"

@interface ViewController ()<HPGrowingTextViewDelegate>
{
    BOOL isStopBackgroundAnimation;
}

@property (weak, nonatomic) IBOutlet UIButton *clickButton;
@property (weak, nonatomic) IBOutlet TAGAnimateView *animateView;
@property (weak, nonatomic) IBOutlet UIView *textInputView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *textView;

- (IBAction)clickButtonAction:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //TextView
    _textView.isScrollable = NO;
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    _textView.minNumberOfLines = 1;
    _textView.maxNumberOfLines = 5;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    _textView.returnKeyType = UIReturnKeyDefault; //just as an example
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.delegate = self;
    _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.layer.borderColor=[UIColor grayColor].CGColor;
    _textView.layer.borderWidth=0.5f;
    _textView.layer.cornerRadius=5.0f;
    _textView.placeholder=@"Type a Message";
    
    
    CGRect frame = self.animateView.frame;
    frame.size.height = fabsf(frame.origin.y - self.textInputView.frame.origin.y);
    self.animateView.frame = frame;
    // Keyboard events
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    /* No longer listen for keyboard */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark -
#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[info valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [info objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.textInputView.frame;
    CGRect tableFrame = self.animateView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    tableFrame.size.height = containerFrame.origin.y-16;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.textInputView.frame = containerFrame;
    self.animateView.frame = tableFrame;
    [self.animateView stopAnimation];
    [self.animateView removeLabels];
    isStopBackgroundAnimation = YES;
    [UIView commitAnimations];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [info objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.textInputView.frame;
    CGRect tableFrame = self.animateView.frame;
    
    containerFrame.origin.y = self.view.frame.size.height - containerFrame.size.height;
    tableFrame.size.height = containerFrame.origin.y-16;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.textInputView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
    self.animateView.frame =tableFrame;
}

#pragma mark -
#pragma mark - Actions

- (IBAction)sayPressed:(id)sender
{
    [self.textView resignFirstResponder];

    if (![self.textView.text isEqualToString:@""] && ![[self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self.animateView stopAnimation];
        isStopBackgroundAnimation = NO;
        [self setViewAnimation];
        [self.animateView addStringToAnimate:self.textView.text];
        [self.animateView startAnimation];
        self.textView.text = @"";
    }
}


#pragma mark --
#pragma mark -- UITextView Delegate

- (BOOL)textView:(UITextView *)textView1 shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //    if([text isEqualToString:@"\n"]) {
    //        [textView1 resignFirstResponder];
    //        return NO;
    //    }
    NSUInteger newLength = [textView1.text length] + [text length] - range.length;
    return (newLength > 500) ? NO : YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView1
{
    [textView1 resignFirstResponder];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.textInputView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.textInputView.frame = r;
    
    CGRect s = self.animateView.frame;
    s.size.height += diff;
    self.animateView.frame = s;
}


#pragma Background Color Animation
-(void)setViewAnimation
{
    [UIView animateWithDuration:0.15
                          delay:1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         self.animateView.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:20.0/255.0 blue:60.0/255.0 alpha:1];
     }
                     completion:^(BOOL finished)
     {
         if(isStopBackgroundAnimation){
             self.animateView.backgroundColor = [UIColor lightGrayColor];
             return;
         }
         [UIView animateWithDuration:0.25 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
             self.animateView.backgroundColor = [UIColor colorWithRed:202.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1];
         } completion:^(BOOL finished)
          {
              if(isStopBackgroundAnimation){
                  self.animateView.backgroundColor = [UIColor lightGrayColor];
                  return;
              }
              [UIView animateWithDuration:0.25 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                  self.animateView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:230.0/255.0 blue:133.0/255.0 alpha:1];
              } completion:^(BOOL finished)
               {
                   if(isStopBackgroundAnimation){
                       self.animateView.backgroundColor = [UIColor lightGrayColor];
                       return;
                   }
                   [UIView animateWithDuration:0.25 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                       self.animateView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:113.0/255.0 blue:133.0/255.0 alpha:1];
                   } completion:^(BOOL finished)
                    {
                        if(isStopBackgroundAnimation){
                            self.animateView.backgroundColor = [UIColor lightGrayColor];
                            return;
                        }
                        [UIView animateWithDuration:0.25 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                            self.animateView.backgroundColor = [UIColor colorWithRed:105/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1];
                        } completion:^(BOOL finished)
                         {
                             if(isStopBackgroundAnimation){
                                 self.animateView.backgroundColor = [UIColor lightGrayColor];
                                 return;
                             }                             [UIView animateWithDuration:0.25 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                 self.animateView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1];
                             } completion:^(BOOL finished)
                              {
                                  if(isStopBackgroundAnimation){
                                      self.animateView.backgroundColor = [UIColor lightGrayColor];
                                      return;
                                  }
                                  [self setViewAnimation];
                              }
                              ];
                             
                         }
                         ];
                        
                    }
                    ];
                   
               }
               ];
              
          }
          ];
         
         
     }];
}

@end
