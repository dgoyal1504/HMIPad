//
//  SWLoginWindowControllerBase.m
//  HmiPad
//
//  Created by Joan Lluch on 26/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWLoginWindowControllerBase.h"
#import "LoginViewC.h"

#if DEBUGGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif




#if GEN_IMAGE
    #import "CALayer+ScreenShot.h"
#endif


#pragma mark - SWLoginWindowController()

@interface SWLoginWindowControllerBase()<LoginViewDelegate>

//@property (nonatomic, retain) UIBarButtonItem *cancelButtonItem;

@end


#pragma mark - SWLoginWindowController implementation

@implementation SWLoginWindowControllerBase
{
    __weak UIWindow *_swKeyWindow ; // weak ;
    UIWindow *_selfWindow;
    //LoginViewC *_loginView;
    BOOL _isObservingUsers;
}


//@synthesize cancelForbiden;


- (void)establishTextFieldImage:(UITextField*)textField secure:(BOOL)isSecure
{
    if ( isSecure == NO )
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"caution16.png"]];
        [textField setLeftView:imageView] ;
        //[imageView release] ;
    }
    else
    {
        [textField setLeftView:nil] ;
    }
} 


//- (void)establishAccountLabel:(NSString*)account
//{
//    [currentAccountLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Current Account: %@",nil), account]];
//}

//- (void)establishCancelButton:(BOOL)showIt
//{
//    [_loginView establishCancelButton:showIt];
//}


//- (void)establishDoneButton:(BOOL)showIt
//{
//    //[theNavigationItem setRightBarButtonItem:(showIt?doneButtonItem:nil)];
//}


- (void)establishActivityIndicator:(BOOL)putIt animated:(BOOL)animated
{    
    [_loginView establishActivityIndicator:putIt animated:animated];
}


- (void)establishResultText:(NSString*)text;
{
    [_loginView establishResultLabelWithText:text];
}





//- (NSString *)currentAccount
//{
//    return _currentAccount ;
//}
//
//
//- (void)setCurrentAccount:(NSString *)account
//{
//    _currentAccount = account;
////    [self establishAccountLabel:currentAccount] ;
//}


//- (NSString *)username
//{
//    return _username ;
//}
//
//
//- (void)setUsername:(NSString *)user
//{
//    _username = user;
//}


- (NSString *)password
{
    //return [passwordTextField text] ;
    return _loginView.passText;
}


- (void)setCancelForbiden:(BOOL)value
{
    if ( _cancelForbiden == value ) return ;
    _cancelForbiden = value ;
    
    [_loginView establishCancelButton:!_cancelForbiden];
}


#pragma mark - View Controller Methods

- (id)init
{
    NSLog( @"LoginWindowController: init") ;

    // APPROACH 1 : inicialització a partir de un nib
//    if ( (self = [super initWithNibName:@"loginView" bundle:nil]) )
//    {
//    }
    return self ;
}
   

- (void)dealloc
{
    NSLog( @"LoginWindowController: dealloc") ;
    [self stopObservingUsers];
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


- (BOOL)shouldAutorotate
{
    return YES;
}


- (void)loadView
{
    NSLog1( @"LoginWindowController: LoadView" );
    
    CGRect rect = [[UIScreen mainScreen] bounds] ;
    _loginView = [[LoginViewC alloc] initWithFrame:rect];
    _loginView.delegate = self;
    self.view = _loginView;
    //[super loadView];
}



- (void)viewDidLoad
{
    NSLog1( @"LoginWindowController: viewDidLoad" );
    [super viewDidLoad] ;
    
    _loginView.userText = _username;
    
    [_loginView establishCancelButton:!_cancelForbiden];
    [_loginView.titleLabel setText:NSLocalizedString(@"", nil)];

//    [self establishDoneButton:NO];
//    [self establishAccountLabel:@"nobody"];
//    [self establishAccountLabel:currentAccount] ;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    NSLog1( @"LoginWindowController viewWillAppear" );
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    #if GEN_IMAGE
    {
        _loginView.fieldsView.hidden = YES;
        CGSize size = _loginView.bounds.size;
        UIImage *image = [_loginView resizedImageWithContentMode:UIViewContentModeCenter bounds:size interpolationQuality:kCGInterpolationDefault radius:0 cropped:0 oflineRendering:YES];
        
        _loginView.fieldsView.hidden = NO;
        
        NSString *orientation = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])?@"Landscape":@"Portrait";
        CGFloat scale = [[UIScreen mainScreen] scale];
        NSString *dir = NSTemporaryDirectory();
        NSString *idiom = IS_IPHONE?@"iphone":@"ipad";
        
        //NSString *name = [NSString stringWithFormat:@"/tmp/Default-%@%@~ipad.png", orientation,scale==2.0f?@"@2x":@""];
        NSString *name = [NSString stringWithFormat:@"%@Default-%@%@~%@.png", dir, orientation,scale==2.0f?@"@2x":@"",idiom];
        BOOL result = [UIImagePNGRepresentation(image) writeToFile:name atomically: YES];
        NSLog( @"saving gen_image : %d", result );
        //system([@"open " stringByAppendingString:name].UTF8String);
    }
    #endif
    
    if ( _username.length == 0 ) [_loginView setUserFieldResponder];
    else [_loginView setPassFieldResponder];
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}



#pragma mark - Interface Methods


- (void)showAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    NSLog1( @"LoginWindowController: show" );
    
    // el metode keyWindow de application torna nil, per tant utilizem el array windows ! ;
    _swKeyWindow = nil ;
    NSArray *windows = [[UIApplication sharedApplication] windows] ;
    //NSLog( @"windows: %@", windows ) ;
    if ( [windows count] > 0 )
    {
        _swKeyWindow = [windows objectAtIndex:0] ;
    }
    
    //[keyWindow setHidden:YES] ;
    
    UIView *theView = [self view] ; //cridara loadView i viewDidLoad si cal
    if ( _selfWindow == nil )
    {
        CGRect rect = [[UIScreen mainScreen] bounds] ;
        _selfWindow = [[UIWindow alloc] initWithFrame:rect] ;
        [_selfWindow setRootViewController:self] ;
    }
//    [selfWindow setWindowLevel:UIWindowLevelAlert] ;
    [_selfWindow setWindowLevel:UIWindowLevelNormal] ;
    [_selfWindow makeKeyAndVisible] ;  ////
    //[_selfWindow setBackgroundColor:[UIColor colorWithRed:0.5 green:0 blue:0 alpha:0.5]];
    
    _loginView.userText = _username;
    

    void (^block)(void) = ^()
    {
        [theView setAlpha:1.0f];
        [_selfWindow makeKeyAndVisible] ;
        // ^-- necesari, si no en el simulador es posa la keyWindow a sobre (tot i que selfWindow continua essent key (wtf?))
        //[_keyWindow setAlpha:0.0];
    };
    
    if ( animated )
    {
        [theView setAlpha:0.0f];
        //[_keyWindow setAlpha:1.0];
        [UIView animateWithDuration:0.3 animations:block completion:completion];
    }
    else
    {
        block();
    }
}


- (void)dismiss
{
    UIView *theView = _loginView ;
    [self stopObservingUsers];
    
    [UIView animateWithDuration:0.3f animations:^
    {
        [theView setAlpha:0.0f];
        //[_swKeyWindow setAlpha:1.0f];
    }
    completion:^(BOOL finished)
    {
    
        [_selfWindow resignKeyWindow] ;
        //[keyWindow setHidden:NO];
        _selfWindow = nil ;
 
        if ( [_delegate respondsToSelector:@selector(loginWindowDidClose:)] )
        {
            [_delegate loginWindowDidClose:self] ;
        }
    }];
}



- (void)startObservingUsers
{
    if ( _isObservingUsers )
        return;
    
    _isObservingUsers = YES;
    [usersModel() addObserver:self];
}


- (void)stopObservingUsers
{
    if ( !_isObservingUsers )
        return;
    
    _isObservingUsers = NO;
    [usersModel() removeObserver:self];
}


- (void)resign
{
    [_loginView resignUserField];
    [_loginView resignPassField];
}

#pragma mark - LoginView delegate methods

- (void)loginViewDidEnter:(LoginViewC*)loginView
{
    [self resign];
}


- (void)loginViewDidCancel:(LoginViewC*)loginView
{
    [self resign];
}


- (void)loginViewDidForgotPassword:(LoginViewC *)loginView
{
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accions
///////////////////////////////////////////////////////////////////////////////////////////


////----------------------------------------------------------------------------------------
//- (void)doButton:(id)sender
//{
//   BOOL userCanceled = (sender == cancelButtonItem);
//   [self doExitWithCancel:userCanceled] ;
//}










@end

