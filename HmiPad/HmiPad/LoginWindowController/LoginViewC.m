//
//  LoginViewController.m
//  OdataProva
//
//  Created by Joan on 05/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewC.h"
#import "SWKeyboardListener.h"
//#import "SWColor.h"
//#import "Drawing.h"


/*
@interface LogoView : UIView
@end

@implementation LogoView
@end

@interface FieldsView : UIView
@end

@implementation FieldsView
@end
*/


@interface LoginViewC()

//@property (nonatomic,retain) IBOutlet UILabel *labelhmipad;
@property (nonatomic,retain) IBOutlet UIView *logoView ;
@property (nonatomic,retain) IBOutlet UIView *fieldsView ;
//@property ( nonatomic, retain ) IBOutlet UIImageView *backView ;
//@property ( nonatomic, retain ) IBOutlet UIImageView *logoImage ;

@property (nonatomic,retain) IBOutlet UITextField *userField ;
@property (nonatomic,retain) IBOutlet UITextField *passField ;
@property (nonatomic,retain) IBOutlet UILabel *resultLabel ;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator ;


@property ( nonatomic, retain ) IBOutlet UIButton *cancelButton ;
@property ( nonatomic, retain ) IBOutlet UIButton *forgotPasswordButton ;

- (IBAction)buttonTouched:(UIButton *)sender ;
- (IBAction)forgotPasswordButtonTouched:(UIButton *)sender ;

@end


@implementation LoginViewC
{
    BOOL _forgotBtnIsHidden;
}

//@synthesize okButton ;
//@synthesize logoView, fieldsView ;
//@synthesize backView ;
//@synthesize userField, passField, resultLabel ;
//@synthesize activityIndicator ;
//@synthesize delegate ;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame] ;
    if ( self )
    {
        NSString *nibName;
        if ( IS_IOS7 ) nibName = @"LoginViewC";
        else nibName = @"LoginViewC6";
        UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
        NSArray *topLevelObjects = [nib instantiateWithOwner:self options:nil];
        (void)topLevelObjects;
        
        if ( IS_IPHONE )
        {
            CGRect fieldsFrame = _fieldsView.frame;
            fieldsFrame.size.height = roundf(fieldsFrame.size.height *0.8);
            _fieldsView.frame = fieldsFrame;
            
            CGRect logoFrame = _logoView.frame;
            logoFrame.size.height = roundf(logoFrame.size.height *0.9);
            _logoView.frame = logoFrame;
        }
        
        // backView
        [self addSubview:_backView] ;
        [_backView setFrame:frame] ;
        [_backView setContentMode:UIViewContentModeScaleAspectFill] ;
        
        // logoView
        [self addSubview:_logoView] ;

        // fieldsView
        [self addSubview:_fieldsView] ;
        
        // hmipad
        [_labelhmipad setText:@AppName];
        
////        NSShadow *shadow = [[NSShadow alloc] init];
////        [shadow setShadowOffset:CGSizeMake(-1,-1)];
////        [shadow setShadowColor:[UIColor blackColor]];
//
//        
//        NSAttributedString *appName = [[NSAttributedString alloc] initWithString:@ AppName attributes:@{
//            /*NSShadowAttributeName:shadow,*/
//            NSTextEffectAttributeName:NSTextEffectLetterpressStyle,
//        }];
//        
//        [_labelhmipad setAttributedText:appName];
        
        
        [_userField setDelegate:self] ;
        [_userField setReturnKeyType:UIReturnKeyNext] ;
        NSString *placeholder = NSLocalizedString(@"username",nil) ;
        [_userField setPlaceholder:placeholder] ;
        
        [_passField setDelegate:self] ;
        [_passField setReturnKeyType:UIReturnKeyDone] ;
        placeholder = NSLocalizedString(@"password",nil) ;
        [_passField setPlaceholder:placeholder] ;
        
        [self establishResultLabelWithText:nil];
        [_activityIndicator setHidesWhenStopped:YES] ;
        
        // cancelbutton
        if ( [_cancelButton respondsToSelector:@selector(setRgbTintColor:overWhite:)] )
            [(ColoredButton*)_cancelButton setRgbTintColor:0xe0e0e0 overWhite:NO];
        
        // loginView (self)
        [self setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]] ;
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight] ;
        [self setAutoresizesSubviews:YES] ;  // layoutSubview ho overrida quan cal
        
        [self setTextColorIsDark:YES];
    }
    return self ;
}

//- (void)awakeFromNib
//{
//    [super awakeFromNib] ;
//    [_userField setDelegate:self] ;
//    [_userField setReturnKeyType:UIReturnKeyNext] ;
//    [_passField setDelegate:self] ;
//    [_passField setReturnKeyType:UIReturnKeyDone] ;
//    
//
//}

/*
- (void)dealloc
{
    [logoView release] ;
    [fieldsView release] ;
}
*/

- (void)layoutSubviews
{
    [super layoutSubviews] ;
    
    if ( _logoView == nil || _fieldsView == nil ) return ;
    CGRect bounds = [self bounds] ;
    [_backView setFrame:bounds] ;
    //NSLog( @"bounds %@", NSStringFromCGRect(bounds));
    CGRect logoBounds = [_logoView bounds] ;
    CGRect fieldsBounds = [_fieldsView bounds] ;
    
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance];
    //CGFloat keybGap = 0 ;
    //if ( [keyb isVisible] ) keybGap = 120 ;
    CGFloat keybOffset = [keyb offset] /*- keybGap*/;
    
    
    CGFloat hgap = round((bounds.size.width - logoBounds.size.width - fieldsBounds.size.width)/3);
    if ( hgap < 0 ) hgap = 0;
    
    CGFloat vgap = round((bounds.size.height - keybOffset - logoBounds.size.height - fieldsBounds.size.height)/7);
    if ( vgap < 0 ) vgap = 0;
    
    CGRect logoFrame ;
    logoFrame.size = logoBounds.size ;
    logoFrame.origin.x = hgap ;
    logoFrame.origin.y = vgap*4 ;
    
    CGRect fieldsFrame ;
    fieldsFrame.size = fieldsBounds.size ;
    fieldsFrame.origin.x = bounds.size.width - hgap - fieldsBounds.size.width;
    //fieldsFrame.origin.y = roundf( (bounds.size.height-fieldsBounds.size.height-keybOffset)*2/3 );
    fieldsFrame.origin.y = round( bounds.size.height - keybOffset - vgap*2 - fieldsBounds.size.height);
    
    [_logoView setFrame:logoFrame] ;
    [_fieldsView setFrame:fieldsFrame] ;
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    if ( newSuperview != nil )
    {
        [nc addObserver:self selector:@selector(keybDidChange:) name:SWKeyboardWillShowNotification object:nil] ;
        [nc addObserver:self selector:@selector(keybDidChange:) name:SWKeyboardWillHideNotification object:nil] ;
    }
    else
    {
        [nc removeObserver:self] ;
    }

}



# pragma mark - public methods

- (void)setUserText:(NSString *)userText
{
    _userField.text = userText;
}

- (NSString*)userText
{
    return _userField.text;
}

- (void)setPassText:(NSString *)passText
{
    _passField.text = passText;
}

- (NSString*)passText
{
    return _passField.text;
}


- (void)setPassFieldResponder
{
    [_passField becomeFirstResponder];
}

- (void)resignPassField
{
    [_passField resignFirstResponder];
}

- (void)setUserFieldResponder
{
    [_userField becomeFirstResponder];
}

- (void)resignUserField
{
    [_userField resignFirstResponder];
}

- (void)keybDidChange:(NSNotification*)note
{
    [UIView animateWithDuration:0.25
    animations:^
    {
        [self layoutSubviews] ;
    }] ;
}





/*
- (IBAction)buttonTouched:(UIButton *)sender
{
    if ( [[userField text] isEqualToString:@"pepe"] &&
        [[passField text] isEqualToString:@"pepe"] )
    {
        [delegate loginViewDidEnd:self] ;
    }
}
*/


- (void)establishCancelButton:(BOOL)showIt
{
    _cancelButton.hidden = !showIt;
    _cancelButton.enabled = showIt;
}

- (void)establishForgotPasswordButton:(BOOL)showIt
{
    _forgotBtnIsHidden = !showIt;
    [self _updateForgotButtonHiddenState];
//    _forgotPasswordButton.hidden = !showIt;
//    _forgotPasswordButton.enabled = showIt;
}


- (void)establishActivityIndicator:(BOOL)putIt animated:(BOOL)animated
{
    if ( putIt ) [_activityIndicator startAnimating];
    else [_activityIndicator stopAnimating];
    
    _resultLabel.hidden = putIt;
    [self _updateForgotButtonHiddenState];
//    _forgotPasswordButton.hidden = putIt || _resultLabel.text.length>0 || _forgotBtnIsHidden ;
}


- (void)establishResultLabelWithText:(NSString*)text
{
    _resultLabel.text = text;
    [self _updateForgotButtonHiddenState];
//    _forgotPasswordButton.hidden = text.length>0 || _forgotBtnIsHidden;
}


- (void)setTextColorIsDark:(BOOL)isDark
{
    UIColor *color = isDark ? [UIColor darkGrayColor] : [UIColor whiteColor];
    [_resultLabel setTextColor:color];
    [_titleLabel setTextColor:color];
    [_cancelButton setTintColor:color];
    //[_cancelButton.titleLabel setTextColor:color];
    [_cancelButton setTitleColor:color forState:UIControlStateNormal];
    [_forgotPasswordButton setTintColor:color];
    [_forgotPasswordButton.titleLabel setTextColor:color];
    [_activityIndicator setColor:color];
}


#pragma mark - Private

- (void)_updateForgotButtonHiddenState
{
    BOOL isHidden = _activityIndicator.isAnimating || _resultLabel.text.length>0 || _forgotBtnIsHidden ;
    _forgotPasswordButton.hidden = isHidden;
    _forgotPasswordButton.enabled = !isHidden;
}


# pragma mark - Actions


- (IBAction)buttonTouched:(UIButton *)sender
{
    if ( sender == _cancelButton )
    {
        [_delegate loginViewDidCancel:self];
    }
}


- (IBAction)forgotPasswordButtonTouched:(UIButton *)sender
{
    if ( sender == _forgotPasswordButton )
    {
        [_delegate loginViewDidForgotPassword:self];
    }
}


#pragma mark  delegat dels text fields

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField       
// return NO to disallow editing.
{
    return YES ;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
// became first responder
{
    [self establishResultLabelWithText:nil];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
{
    return YES ;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
    //NSString *text = [textField text] ;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
// return NO to not change text
{
    [self establishResultLabelWithText:nil];
    
    int textLength = [[textField text] length];
    int stringLength = [string length];
    int finalLength = textLength + (stringLength?stringLength:-1) ;
    if ( finalLength > 20 ) return NO ;
    
    UITextField *theOtherOne = _passField ;
    if ( textField == theOtherOne ) theOtherOne = _userField ;
    
//    BOOL userFieldSecure = (textField == userField ? finalLength : [[userField text] length]) > 0 ;
//    BOOL passFieldSecure = YES ; // admetem cap password    
//    bothFieldsSecure = userFieldSecure && passFieldSecure ;
//    
//    [self establishDoneButton:bothFieldsSecure];
    
    if ( stringLength == 0 ) return YES ;
        
    NSMutableCharacterSet *validSet = [NSMutableCharacterSet alphanumericCharacterSet] ;
    [validSet addCharactersInString:@"@_-."];
    NSScanner *scanner = [[NSScanner alloc] initWithString:string] ;
    NSString *filtered = nil ;
    [scanner scanCharactersFromSet:validSet intoString:&filtered] ;
//    [scanner release] ;
    return [string isEqualToString:filtered];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
// called when clear button pressed. return NO to ignore (no notifications)
{
    return YES ;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
// called when 'return' key pressed. return NO to ignore.
{
    if ( textField == _userField )
    {
        [_passField becomeFirstResponder] ;
        return NO ;
    }
    
    [_delegate loginViewDidEnter:self];
    [textField resignFirstResponder] ;
    return NO ;
}


@end
