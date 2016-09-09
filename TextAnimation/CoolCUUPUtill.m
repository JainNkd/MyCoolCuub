//
//  CoolCUUPUtill.m
//  TextAnimation
//
//  Created by Naveen Dungarwal on 07/09/16.
//  Copyright © 2016 TAG. All rights reserved.
//

#import "CoolCUUPUtill.h"

@implementation CoolCUUPUtill

//Save Animation Text In Nsuserdefault.
+(void)saveAnimationTextInLocal:(NSString*)animationText
{
    if(animationText.length>0)
        [[NSUserDefaults standardUserDefaults] setValue:animationText forKey:kANIMATION_TEXT];
}

//Get Current Amination Text
+(NSString*)getAnimationText
{
    NSString *animationText = [[NSUserDefaults standardUserDefaults] valueForKey:kANIMATION_TEXT];
    if(animationText.length>0)
        return animationText;
    else
        return @"";
}

@end
