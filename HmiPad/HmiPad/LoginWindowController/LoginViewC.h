//
//  LoginViewController.h
//  OdataProva
//
//  Created by Joan on 05/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ColoredButton.h"

@class LoginViewC ;

@protocol LoginViewDelegate<NSObject>

@required
- (void)loginViewDidEnter:(LoginViewC*)loginView ;
- (void)loginViewDidCancel:(LoginViewC*)loginView ;
- (void)loginViewDidForgotPassword:(LoginViewC*)loginView ;

@end



@interface LoginViewC : UIView<UITextFieldDelegate>

//@property (nonatomic,retain) IBOutlet UILabel *labelhmipad;
//@property (nonatomic,retain) IBOutlet UIView *logoView ;
//@property (nonatomic,retain) IBOutlet UIView *fieldsView ;
//@property ( nonatomic, retain ) IBOutlet UIImageView *backView ;


@property (nonatomic,retain) IBOutlet UILabel *labelhmipad;
@property ( nonatomic, retain ) IBOutlet UILabel *titleLabel ;
@property ( nonatomic, retain ) IBOutlet UIImageView *backView ;
@property ( nonatomic, retain ) IBOutlet UIImageView *logoImage ;

@property (nonatomic,assign) id<LoginViewDelegate> delegate ;
//@property (nonatomic,retain) IBOutlet UITextField *userField ;
//@property (nonatomic,retain) IBOutlet UITextField *passField ;
//@property (nonatomic,retain) IBOutlet UILabel *resultLabel ;
//@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator ;

//@property ( nonatomic, retain ) IBOutlet UIButton *cancelButton ;
//@property ( nonatomic, retain ) IBOutlet UIButton *forgotPasswordButton ;
//@property (nonatomic,retain) IBOutlet UIButton *okButton ;

//- (IBAction)buttonTouched:(UIButton *)sender ;
//- (IBAction)forgotPasswordButtonTouched:(UIButton *)sender ;

@property (nonatomic,strong) NSString *userText;
- (void)setUserFieldResponder;
- (void)resignUserField;

@property (nonatomic,strong) NSString *passText;
- (void)setPassFieldResponder;
- (void)resignPassField;

- (void)establishCancelButton:(BOOL)showIt;
- (void)establishForgotPasswordButton:(BOOL)showIt;
- (void)establishActivityIndicator:(BOOL)putIt animated:(BOOL)animated;
- (void)establishResultLabelWithText:(NSString*)text;
- (void)setTextColorIsDark:(BOOL)isDark;

//- (void)setBackgroundImage:(UIImage*)backgroundImage;
//- (void)setCustomBackColor:(UIColor *)back;



@end
