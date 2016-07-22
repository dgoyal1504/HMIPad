//
//  SWLoginWindowControllerP.h
//  HmiPad
//
//  Created by Joan Lluch on 26/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SWLoginWindowControllerBase.h"

@class SWSystemItemUsersManager;


@interface SWLoginWindowControllerP : SWLoginWindowControllerBase

//@property (nonatomic, readonly) SWSystemItemUsersManager *documentModel;
- (id)initWithUsersManager:(SWSystemItemUsersManager*)usersManager;

//- (void)setBackgroundColor:(UIColor*)color;
//- (void)setBackgroundImageName:(NSString*)imageName;
//- (void)setCompanyTitle:(NSString*)companyTitle;
//- (void)setCompanyLogoImageName:(NSString*)companyLogoImageName;

@end
