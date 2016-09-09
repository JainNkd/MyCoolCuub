//
//  CoolCUUPUtill.h
//  TextAnimation
//
//  Created by Naveen Dungarwal on 07/09/16.
//  Copyright © 2016 TAG. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kANIMATION_TEXT @"AnimationText"


@interface CoolCUUPUtill : NSObject

//Save Animation Text In Nsuserdefault.
+(void)saveAnimationTextInLocal:(NSString*)animationText;

//Get Current Amination Text
+(NSString*)getAnimationText;


@end
