//
//  SWPlayerCenter.h
//  ScadaMobile_091113
//
//  Created by Joan on 13/11/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


extern NSString *SWPlayerCenterErrorNotification;
extern NSString *SWPlayerCenterErrorKey;

@class SWPlayerView;
@interface SWPlayerCenter : NSObject 
{
    BOOL repeat;
}

+ (SWPlayerCenter*) defaultCenter;

//- (void) postAlertWithMessage:(NSString*)message image:(UIImage*)image;
//- (void) postAlertWithMessage:(NSString *)message;

- (void)playSoundTextUrl:(NSString*)textUrl labelText:(NSString*)text;  // nil textUrl per aturar
- (void)setRepeat:(BOOL)state ;
- (void)setVisible:(BOOL)state ;     // nomes te efecte si ha un so

@end