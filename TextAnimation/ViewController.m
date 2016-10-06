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
#import "CoolCUUPUtill.h"


#define XMARGIN 50
#define ICON_WIDTH 50
#define ICON_HEIGTH 50
#define ICON_ANIMATION_HEIGHT 80
#define ZOOMOUT_SCALE_IAMGE 1.0
#define ZOOMIN_SCALE_IAMGE 1.25

@interface ViewController ()<HPGrowingTextViewDelegate>
{
    BOOL isStopBackgroundAnimation;
}

@property (strong, nonatomic) NSMutableArray *rightImagesArray,*leftImagesArray;

@property (weak, nonatomic) IBOutlet UIButton *clickButton;
@property (weak, nonatomic) IBOutlet TAGAnimateView *animateView;
@property (weak, nonatomic) IBOutlet UIView *textInputView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *textView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
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
    
    UILabel *headingLbl = [[UILabel alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    headingLbl.text = @"Animation View";
    headingLbl.textAlignment = UITextAlignmentCenter;
    headingLbl.font = [UIFont boldSystemFontOfSize:19];
    headingLbl.textColor = [UIColor blackColor];
    [self.animateView addSubview:headingLbl];
    
    
    CGRect frame = self.animateView.frame;
    frame.size.height = fabs(frame.origin.y - self.textInputView.frame.origin.y);
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
    tableFrame.size.height = containerFrame.origin.y-16+20;
    
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
    tableFrame.size.height = containerFrame.origin.y-16+20;
    
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
        
        self.textView.text = [NSString stringWithFormat:@" %@",self.textView.text];
        //Initial image animation
        //        [self initialImageAnimation];
        
        [self startTextAnimation];
    }
}

-(void)startTextAnimation
{
    //Save Current Animation text
    [CoolCUUPUtill saveAnimationTextInLocal:self.textView.text];
    
    //backgound color changes
    isStopBackgroundAnimation = NO;
    [self setViewAnimation];
    
    
    //Setup for images for Background animal animation
    [self setUpImageViews];
    
    //Text Animation start
    [self.animateView stopAnimation];
    [self.animateView addStringToAnimate:self.textView.text];
    [self.animateView startAnimation];
    self.textView.text = @"";
    
    //Setup for images for Background animal animation
    //    [self setUpImageViews];
    
    //Play moving images at background
    [self playAnimalBackgroundImages];
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


#pragma  For Animation animal moving images at background

//Create Images and add to animation view.
-(void)setUpImageViews
{
    
    //Remove images before adding to another set of images on uianimationView
    
    if(self.rightImagesArray.count==0){
    [self removeAllBackgorundImages];
    
    CGFloat xOrigin,yOrigin;
    self.rightImagesArray = [[NSMutableArray alloc]init];
    self.leftImagesArray = [[NSMutableArray alloc]init];
    
    xOrigin = -310;  //630
    yOrigin = 250;
    for(int i=0;i<8;i++)
    {
        UIView *viewObj = [[UIView alloc]init];
        viewObj.frame = CGRectMake(xOrigin,yOrigin,ICON_WIDTH, ICON_HEIGTH);
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,ICON_WIDTH,ICON_HEIGTH)];
        imageView.image = [UIImage imageNamed:@"elephant_small.png"];
        [viewObj addSubview:imageView];
        
        [self.animateView addSubview:viewObj];
        [self.rightImagesArray addObject:viewObj];
        xOrigin += (XMARGIN+ICON_WIDTH);
    }
    
    xOrigin = 640;
    yOrigin = self.animateView.frame.size.height-150;
    for(int j = 0;j <12;j++)
    {
        UIView *viewObj = [[UIView alloc]init];
        viewObj.frame = CGRectMake(xOrigin,yOrigin,ICON_HEIGTH, ICON_HEIGTH);
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,ICON_WIDTH,ICON_HEIGTH)];
        imageView.image = [UIImage imageNamed:@"frog_small.png"];
        [viewObj addSubview:imageView];
        
        [self.animateView addSubview:viewObj];
        [self.leftImagesArray addObject:viewObj];
        xOrigin -= (XMARGIN+ICON_WIDTH);
    }
    }else
    {
        CGFloat xOrigin,yOrigin;
        
        xOrigin = -310;  //630
        yOrigin = 150;
        for(int i=0;i<8;i++)
        {
            UIView *viewObj = [self.rightImagesArray objectAtIndex:i];
            viewObj.frame = CGRectMake(xOrigin,yOrigin,ICON_WIDTH, ICON_HEIGTH);
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,ICON_WIDTH,ICON_HEIGTH)];
            imageView.image = [UIImage imageNamed:@"elephant_small.png"];
            //[viewObj addSubview:imageView];
            
            //[self.animateView addSubview:viewObj];
            //[self.rightImagesArray addObject:viewObj];
            xOrigin += (XMARGIN+ICON_WIDTH);
        }
        
        xOrigin = 640;
        yOrigin = self.animateView.frame.size.height-150;
        for(int j = 0;j <12;j++)
        {
            UIView *viewObj = [self.leftImagesArray objectAtIndex:j];
            viewObj.frame = CGRectMake(xOrigin,yOrigin,ICON_HEIGTH, ICON_HEIGTH);
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,ICON_WIDTH,ICON_HEIGTH)];
            imageView.image = [UIImage imageNamed:@"frog_small.png"];
//            [viewObj addSubview:imageView];
            
//            [self.animateView addSubview:viewObj];
//            [self.leftImagesArray addObject:viewObj];
            xOrigin -= (XMARGIN+ICON_WIDTH);
        }
    }
}

//Play Backgound images Animation
- (void)playAnimalBackgroundImages {
    
    [self setUpImageViews];
    //Start Animation
    [UIView animateWithDuration:0.5f animations:^{
        
        //Move Top Image up with Animation
        [self topImagesMoveUp];
        
        //Move Bottom Image up with Animation
        [self bottomImagesMoveUp];
    }
                     completion:^(BOOL finished)
     {
         if(isStopBackgroundAnimation){
             [self removeAllBackgorundImages];
             return;
         }
         [UIView animateWithDuration:0.5f animations:^{
             
             //Move Images Down With Animation
             [self topImagesMoveDown];
             
             //Move Images Down With Animation
             [self bottomImagesMoveDown];
             
         }
                          completion:^(BOOL finished)
          {
              if(isStopBackgroundAnimation){
                  [self removeAllBackgorundImages];
                  return;
              }
              [UIView animateWithDuration:0.5f animations:^{
                  
                  //Move Top Image up with Animation
                  [self topImagesMoveUp];
                  
                  //Move Image up with Animation
                  [self bottomImagesMoveUp];
              }
                               completion:^(BOOL finished)
               {
                   if(isStopBackgroundAnimation){
                       [self removeAllBackgorundImages];
                       return;
                   }
                   [UIView animateWithDuration:0.5f animations:^{
                       
                       //Move Images Down With Animation
                       [self topImagesMoveDown];
                       
                       //Move Images Down With Animation
                       [self bottomImagesMoveDown];
                       
                   }
                                    completion:^(BOOL finished)
                    {
                        if(isStopBackgroundAnimation){
                            [self removeAllBackgorundImages];
                            return;
                        }
                        [UIView animateWithDuration:0.5f animations:^{
                            
                            //Move Top Image up with Animation
                            [self topImagesMoveUp];
                            
                            //Move Image up with Animation
                            [self bottomImagesMoveUp];
                            
                        }
                                         completion:^(BOOL finished)
                         {
                             if(isStopBackgroundAnimation){
                                 [self removeAllBackgorundImages];
                                 return;
                             }
                             [UIView animateWithDuration:0.5f animations:^{
                                 
                                 //Move Images Down With Animation
                                 [self topImagesMoveDown];
                                 
                                 //Move Images Down With Animation
                                 [self bottomImagesMoveDown];
                             }
                                              completion:^(BOOL finished)
                              {
                                  if(isStopBackgroundAnimation){
                                      [self removeAllBackgorundImages];
                                      return;
                                  }
                                  [self playAnimalBackgroundImages];
                              }];
                         }];
                    }];
               }];
          }];
     }];
}

//Remove images from Animation View
-(void)removeAllBackgorundImages
{
    if(self.leftImagesArray.count>0){
        for(int k = 0; k<12; k++)
        {
            if(self.rightImagesArray.count>k){
                UIView *view1= [self.rightImagesArray objectAtIndex:k];
                [view1 removeFromSuperview];
            }
            UIView *view2= [self.leftImagesArray objectAtIndex:k];
            
            [view2 removeFromSuperview];
        }
        
        [self.rightImagesArray removeAllObjects];
        [self.leftImagesArray removeAllObjects];
    }
}

//Bottom Animal Images Move Up animation
-(void)bottomImagesMoveUp
{
    UIView *viewl1 = [self.leftImagesArray objectAtIndex:0];
    UIView *viewl2 = [self.leftImagesArray objectAtIndex:1];
    UIView *viewl3 = [self.leftImagesArray objectAtIndex:2];
    UIView *viewl4 = [self.leftImagesArray objectAtIndex:3];
    UIView *viewl5 = [self.leftImagesArray objectAtIndex:4];
    UIView *viewl6 = [self.leftImagesArray objectAtIndex:5];
    UIView *viewl7 = [self.leftImagesArray objectAtIndex:6];
    UIView *viewl8 = [self.leftImagesArray objectAtIndex:7];
    UIView *viewl9 = [self.leftImagesArray objectAtIndex:8];
    UIView *viewl10 = [self.leftImagesArray objectAtIndex:9];
    UIView *viewl11 = [self.leftImagesArray objectAtIndex:10];
    UIView *viewl12 = [self.leftImagesArray objectAtIndex:11];
    
    viewl1.frame = CGRectOffset(viewl1.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl1.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl2.frame = CGRectOffset(viewl2.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl2.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl3.frame = CGRectOffset(viewl3.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl3.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl4.frame = CGRectOffset(viewl4.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl4.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl5.frame = CGRectOffset(viewl5.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl5.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl6.frame = CGRectOffset(viewl6.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl6.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl7.frame = CGRectOffset(viewl7.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl7.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl8.frame = CGRectOffset(viewl8.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl8.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl9.frame = CGRectOffset(viewl9.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl9.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl10.frame = CGRectOffset(viewl10.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl10.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl11.frame = CGRectOffset(viewl11.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl11.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    viewl12.frame = CGRectOffset(viewl12.frame, -ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    viewl12.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
}

//Bottom Animal Images Move Down with animation
-(void)bottomImagesMoveDown
{
    
    UIView *viewl1 = [self.leftImagesArray objectAtIndex:0];
    UIView *viewl2 = [self.leftImagesArray objectAtIndex:1];
    UIView *viewl3 = [self.leftImagesArray objectAtIndex:2];
    UIView *viewl4 = [self.leftImagesArray objectAtIndex:3];
    UIView *viewl5 = [self.leftImagesArray objectAtIndex:4];
    UIView *viewl6 = [self.leftImagesArray objectAtIndex:5];
    UIView *viewl7 = [self.leftImagesArray objectAtIndex:6];
    UIView *viewl8 = [self.leftImagesArray objectAtIndex:7];
    UIView *viewl9 = [self.leftImagesArray objectAtIndex:8];
    UIView *viewl10 = [self.leftImagesArray objectAtIndex:9];
    UIView *viewl11 = [self.leftImagesArray objectAtIndex:10];
    UIView *viewl12 = [self.leftImagesArray objectAtIndex:11];
    
    viewl1.frame = CGRectOffset(viewl1.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl1.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl2.frame = CGRectOffset(viewl2.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl2.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl3.frame = CGRectOffset(viewl3.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl3.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl4.frame = CGRectOffset(viewl4.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl4.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl5.frame = CGRectOffset(viewl5.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl5.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl6.frame = CGRectOffset(viewl6.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl6.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl7.frame = CGRectOffset(viewl7.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl7.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl8.frame = CGRectOffset(viewl8.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl8.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl9.frame = CGRectOffset(viewl9.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl9.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl10.frame = CGRectOffset(viewl10.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl10.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl11.frame = CGRectOffset(viewl11.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl11.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    viewl12.frame = CGRectOffset(viewl12.frame, -ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    viewl12.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
}

//Top Animal images move up
-(void)topImagesMoveUp
{
    UIView *view1 = [self.rightImagesArray objectAtIndex:0];
    UIView *view2 = [self.rightImagesArray objectAtIndex:1];
    UIView *view3 = [self.rightImagesArray objectAtIndex:2];
    UIView *view4 = [self.rightImagesArray objectAtIndex:3];
    UIView *view5 = [self.rightImagesArray objectAtIndex:4];
    UIView *view6 = [self.rightImagesArray objectAtIndex:5];
    UIView *view7 = [self.rightImagesArray objectAtIndex:6];
    UIView *view8 = [self.rightImagesArray objectAtIndex:7];
    //    UIView *view9 = [self.rightImagesArray objectAtIndex:8];
    //    UIView *view10 = [self.rightImagesArray objectAtIndex:9];
    //    UIView *view11 = [self.rightImagesArray objectAtIndex:10];
    //    UIView *view12 = [self.rightImagesArray objectAtIndex:11];
    
    view1.frame = CGRectOffset(view1.frame, ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    view1.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    view2.frame = CGRectOffset(view2.frame, ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    view2.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    view3.frame = CGRectOffset(view3.frame, ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    view3.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    view4.frame = CGRectOffset(view4.frame, ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    view4.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    view5.frame = CGRectOffset(view5.frame, ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    view5.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    view6.frame = CGRectOffset(view6.frame, ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    view6.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    view7.frame = CGRectOffset(view7.frame, ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    view7.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    view8.frame = CGRectOffset(view8.frame, ICON_WIDTH, -ICON_ANIMATION_HEIGHT);
    view8.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    
    //        view9.frame = CGRectOffset(view9.frame, 50, -ICON_ANIMATION_HEIGHT);
    //        view9.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    //
    //        view10.frame = CGRectOffset(view10.frame, 50, -ICON_ANIMATION_HEIGHT);
    //        view10.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    //
    //        view11.frame = CGRectOffset(view11.frame, 50, -ICON_ANIMATION_HEIGHT);
    //        view11.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
    //
    //        view12.frame = CGRectOffset(view12.frame, 50, -ICON_ANIMATION_HEIGHT);
    //        view12.transform = CGAffineTransformMakeScale(ZOOMIN_SCALE_IAMGE, ZOOMIN_SCALE_IAMGE);
}

//Top Animal images move down
-(void)topImagesMoveDown
{
    
    UIView *view1 = [self.rightImagesArray objectAtIndex:0];
    UIView *view2 = [self.rightImagesArray objectAtIndex:1];
    UIView *view3 = [self.rightImagesArray objectAtIndex:2];
    UIView *view4 = [self.rightImagesArray objectAtIndex:3];
    UIView *view5 = [self.rightImagesArray objectAtIndex:4];
    UIView *view6 = [self.rightImagesArray objectAtIndex:5];
    UIView *view7 = [self.rightImagesArray objectAtIndex:6];
    UIView *view8 = [self.rightImagesArray objectAtIndex:7];
    //    UIView *view9 = [self.rightImagesArray objectAtIndex:8];
    //    UIView *view10 = [self.rightImagesArray objectAtIndex:9];
    //    UIView *view11 = [self.rightImagesArray objectAtIndex:10];
    //    UIView *view12 = [self.rightImagesArray objectAtIndex:11];
    
    view1.frame = CGRectOffset(view1.frame, ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    view1.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    view2.frame = CGRectOffset(view2.frame, ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    view2.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    view3.frame = CGRectOffset(view3.frame, ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    view3.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    view4.frame = CGRectOffset(view4.frame, ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    view4.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    view5.frame = CGRectOffset(view5.frame, ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    view5.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    view6.frame = CGRectOffset(view6.frame, ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    view6.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    view7.frame = CGRectOffset(view7.frame, ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    view7.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    view8.frame = CGRectOffset(view8.frame, ICON_WIDTH, ICON_ANIMATION_HEIGHT);
    view8.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    
    //                  view9.frame = CGRectOffset(view9.frame, 50, ICON_ANIMATION_HEIGHT);
    //                  view9.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    //
    //                  view10.frame = CGRectOffset(view10.frame, 50, ICON_ANIMATION_HEIGHT);
    //                  view10.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    //
    //                  view11.frame = CGRectOffset(view11.frame, 50, ICON_ANIMATION_HEIGHT);
    //                  view11.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
    //
    //                  view12.frame = CGRectOffset(view12.frame, 50, ICON_ANIMATION_HEIGHT);
    //                  view12.transform = CGAffineTransformMakeScale(ZOOMOUT_SCALE_IAMGE, ZOOMOUT_SCALE_IAMGE);
}


//Initial Image Zoom animation
-(void)initialImageAnimation
{
    self.animateView.hidden = YES;
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.hidden = NO;
    
    imageView.frame = CGRectMake(0,(self.view.frame.size.height-self.view.frame.size.width)/2,self.view.frame.size.width,self.view.frame.size.width);
    imageView.image = [UIImage imageNamed:@"elephant_small.png"];
    [self.view addSubview:imageView];
    
    [UIView animateWithDuration:0.75 animations:^{
        imageView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:2.0 animations:^{
            imageView.transform = CGAffineTransformMakeScale(0.75, 0.75);
        }completion:^(BOOL finished){
            imageView.hidden = YES;
            self.animateView.hidden = NO;
            [self startTextAnimation];
        }
         ];
    }];
}


@end
