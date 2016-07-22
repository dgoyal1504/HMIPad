//
//  SWLoginWindowControllerBase.h
//  HmiPad
//
//  Created by Joan Lluch on 26/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewC.h"
#import "AppUsersModel.h"

@class SWLoginWindowControllerBase;

@protocol LoginWindowControllerDelegate<NSObject>

//- (void)loginWindowWillOpen:(LoginWindowController*)sender;
//- (BOOL)loginWindowWillClose:(LoginWindowController*)sender canceled:(BOOL)canceled userChanged:(BOOL)userChanged;
//- (void)loginWindowDidClose:(LoginWindowController*)sender canceled:(BOOL)canceled userChanged:(BOOL)userChanged;

@required
- (void)loginWindowDidClose:(SWLoginWindowControllerBase*)sender;

@end


@interface SWLoginWindowControllerBase : UIViewController<LoginViewDelegate,AppUsersModelObserver>

@property (nonatomic, assign) BOOL cancelForbiden;  // default is NO
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *currentAccount;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, weak) id<LoginWindowControllerDelegate> delegate;
@property (nonatomic, readonly) LoginViewC *loginView;

//- (void)showAnimated:(BOOL)animated;
- (void)showAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion;
- (void)dismiss;
- (void)resign;
- (void)establishResultText:(NSString*)text;
- (void)establishActivityIndicator:(BOOL)doIt animated:(BOOL)animated;

- (void)startObservingUsers;
- (void)stopObservingUsers;


@end
