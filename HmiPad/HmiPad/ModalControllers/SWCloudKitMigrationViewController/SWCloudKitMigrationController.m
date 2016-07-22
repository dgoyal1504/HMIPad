//
//  SWCloudKitMigrationController.m
//  HmiPad
//
//  Created by joan on 13/08/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWCloudKitMigrationController.h"


#import "LoginWindowControllerC.h"

#import "UIViewController+SWSendMailControllerPresenter.h"

#import "SWAppCloudKitUser.h"
#import "AppUsersModel.h"
#import "UserDefaults.h"

#import "AppModelFilesEx.h"

#import "SWBlockAlertView.h"
#import "SWCircleButton.h"
#import "SWColor.h"

@interface SWCloudKitMigrationController()<AppUsersModelObserver,SWAppCloudKitUserObserver,LoginWindowControllerDelegate,AppFilesModelObserver,AppFilesModelMigrationObserver>
{
    double _currentStep;
    SWAppCloudKitUser *_ckUser;
    AppUsersModel *_userModel;
    AppModelFilesEx *_filesModel;
    
    LoginWindowControllerC *_loginWindow;
    
    NSArray *_projectMDs;
    NSArray *_assetFileMDs;
    NSArray *_activationMDs;
    NSArray *_redemptionMDs;
    
    BOOL _isGettingCloudAvailability;
    BOOL _isGettingIntegratorServerUser;
    BOOL _isFetchingCloudUserData;
    BOOL _isMigrating;
    BOOL _hasMigrated;
}

@end

@implementation SWCloudKitMigrationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _scrollView.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1];
    _scrollView.layer.borderWidth = 0.5;
    _scrollView.layer.borderColor = [UIColor grayColor].CGColor;
    _scrollContentView.backgroundColor = [UIColor clearColor];
    _scrollView.delaysContentTouches = NO;
    
    //[_labelTopMessage setText:NSLocalizedString(@"MigrateSectionMessage", nil)];
    
    [_buttonLogIn addTarget:self action:@selector(_buttonLogIn:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonAccountToCloud addTarget:self action:@selector(_buttonAccountToCloud:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonMoveToCloud addTarget:self action:@selector(_buttonMoveToCloud:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonClose addTarget:self action:@selector(_buttonClose:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonSupport addTarget:self action:@selector(_buttonSupport:) forControlEvents:UIControlEventTouchUpInside];
    
    [_buttonClose setTintColor:UIColorWithRgb(TangerineSelectionColor)];
    [_buttonSupport setTintColor:UIColorWithRgb(TheNiceGreenColor)];
    
    UIImage *image = _imageViewLogIcloud.image;
    image = [UIImage imageNamed:@"258-checkmark.png"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imageViewLogIcloud setImage:image];
    [_imageViewLogIServer setImage:image];
    [_imageViewMoveUser setImage:image];
    [_imageViewMigrate setImage:image];
    
    //[_activityIndicator setHidesWhenStopped:YES];

    _currentStep = -1;
    _ckUser = cloudKitUser();
    _userModel = usersModel();
    _filesModel = filesModel().files;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



//- (void)deepSetPreferredMaxLayoutWidth
//{
//    __block __unsafe_unretained BOOL (^setPreferredMaxLayoutWithToView)(UIView *);
//    
//    setPreferredMaxLayoutWithToView = ^(UIView *view)
//    {
//        for ( UIView *subview in [view subviews] )
//        {
//            BOOL s = setPreferredMaxLayoutWithToView(subview);
//            if ( s )
//            {
//                [view setNeedsLayout];
//                [view layoutIfNeeded];
//            }
//        }
//        
//        if ( [view isKindOfClass:[UILabel class]] )
//        {
//            UILabel *label = (id)view;
//            if ( label.numberOfLines == 0 /*&& label == _maxLayoutWidthLabel*/)
//            {
//                CGFloat width = label.bounds.size.width;
//                if ( label.preferredMaxLayoutWidth != width )
//                {
//                    label.preferredMaxLayoutWidth = width;
//                    return YES;
//                }
//            }
//        }
//    
//        return NO;
//    };
//    
//    
//    UIView *view = self.view;
//    if ( setPreferredMaxLayoutWithToView( view ) )
//    {
//        [view setNeedsLayout];
//        [view layoutIfNeeded];
//    }
//}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self deepSetPreferredMaxLayoutWidthToView:self.view];
}


- (void)deepSetPreferredMaxLayoutWidthToView:(UIView*)view
{
    // update preferredMaxLayoutWidth on UILabels if needed
    if ( [view isKindOfClass:[UILabel class]] )
    {
        UILabel *label = (id)view;
        if ( label.numberOfLines == 0 )
        {
            CGFloat width = label.bounds.size.width;
            if ( label.preferredMaxLayoutWidth != width )
            {
                label.preferredMaxLayoutWidth = width;
                UIView *labelSuperView = label.superview;
                [labelSuperView setNeedsLayout];
                [labelSuperView layoutIfNeeded];  // we do force layout of the label superview every time one of its children changed preferredMaxLayoutWidth
            }
        }
    }
    else
    {
        // go deep the view hierarchy in search of more UILabels
        for ( UIView *subview in [view subviews] )
        {
            [self deepSetPreferredMaxLayoutWidthToView:subview];
        }
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self _setupCurrentStep];
    
    [self _establishCurrentUserCloudKit];
    [self _establishCurrentUserIntegratorServer];
    [self _establishCurrentUserMovedCloudKit];
    [self _resetMigrationStep];
    //[self _establishActivity:NO];
    
//    [_filesModel listRemoteIntegratorServerFilesForCategory:kFileCategoryRemoteSourceFile];
//    [_filesModel listRemoteIntegratorServerFilesForCategory:kFileCategoryRemoteAssetFile];
//    [_filesModel listRemoteIntegratorServerFilesForCategory:kFileCategoryRemoteActivationCode];
//    [_filesModel listRemoteIntegratorServerFilesForCategory:kFileCategoryRemoteRedemption];
    
    [_ckUser addObserver:self];
    [_userModel addObserver:self];
    [_filesModel addObserver:self];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [_ckUser removeObserver:self];
    [_userModel removeObserver:self];
    [_filesModel removeObserver:self];
}


#pragma mark - private

- (void)_updateViewsForCurrentStep
{
    for ( UIView *subview in [_scrollContentView subviews] )
    {
        CGFloat tag = subview.tag;
        BOOL thisEnabled = tag <= _currentStep;
        BOOL nextEnabling = tag > _currentStep && tag < _currentStep+1;
        BOOL nextEnabled = tag <= _currentStep+1;
     
        if ( [subview isKindOfClass:[UIControl class]] )
        {
            UIControl *control = (id)subview;
            BOOL enable = ((_currentStep - floor(_currentStep)) == 0);
            enable = enable && nextEnabled;
            [control setEnabled:enable];
        }
    
        else if ( [subview isKindOfClass:[UILabel class]] )
        {
            UILabel *label = (id)subview;
            [label setEnabled:nextEnabled];
        }
        
        else if ( [subview isKindOfClass:[UIImageView class]] )
        {
            UIImageView *imageView = (id)subview;
            //UIColor *color = thisEnabled?[UIColor greenColor]:[UIColor colorWithWhite:0.85 alpha:1.0];
            UIColor *color = thisEnabled?UIColorWithRgb(TheNiceGreenColor):[UIColor colorWithWhite:0.85 alpha:1.0];
            [imageView setTintColor:color];
            [imageView setHidden:nextEnabling];
            //[imageView setHighlighted:thisEnabled];
        }
        
        else if ( [subview isKindOfClass:[UIProgressView class]] )
        {
            //
        }
        
        else if ( [subview isKindOfClass:[UIActivityIndicatorView class]] )
        {
            UIActivityIndicatorView *activityView = (id)subview;
            [activityView setHidden:!nextEnabling];
            if ( nextEnabling ) [activityView startAnimating];
            else [activityView stopAnimating];
        }
    }
    

}


- (NSString*)_userStringForProfile:(UserProfile*)profile
{
    NSMutableString *text = [NSMutableString string];
    
    NSString *userName = profile.username;
    NSString *mainText = userName.length > 0 ? userName : NSLocalizedString(@"iCloud user", nil);
    [text appendString:mainText];
    if ( userName.length > 0 )
    {
        NSString *email = profile.email;
        if ( email.length > 0 )
        {
            [text appendFormat:@", %@", email];
        }
    }

    return text;
}


#pragma mark - Step

- (void)_setupCurrentStep
{
    //CGFloat nextStep = _currentStep;
    
    CGFloat nextStep = 0;
    
    // step 0
    
    CGFloat testStep = 0;
    if ( nextStep >= testStep ) nextStep = testStep;
    
    // step 1
    
    testStep = 1;
    if ( nextStep >= testStep-1 )
    {
        BOOL cloudKitStepOk = [self _testCloudKitStep];
        if ( !cloudKitStepOk ) nextStep = testStep-1;
        if ( cloudKitStepOk ) nextStep = testStep;
    }
    
    // step 2
    
    testStep = 2;
    if ( nextStep >= testStep-1 )
    {
        BOOL integratorUserStepOk = [self _testIntegratorsUserStep];
        if ( !integratorUserStepOk ) nextStep = testStep-1;
        if ( integratorUserStepOk ) nextStep = testStep;
    }
    
    // step 3
    
    testStep = 3;
    if ( nextStep >= testStep-1 )
    {
        BOOL cloudKitUserStepOk = [self _testCloudKitUserStep];
        if ( !cloudKitUserStepOk ) nextStep = testStep-1;
        if ( cloudKitUserStepOk ) nextStep = testStep;
    }
    
    // step 4
    
    if ( nextStep < 3 )
        _hasMigrated = NO;
    
    testStep = 4;
    if ( nextStep >= testStep-1 )
    {
        BOOL migrateStepOk = [self _testMigrateStep];
        if ( !migrateStepOk ) nextStep = testStep-1;
        if ( migrateStepOk ) nextStep = testStep;
    }
    
    // final
    
    if ( (nextStep == 0 && _isGettingCloudAvailability) ||
        (nextStep == 1 && _isGettingIntegratorServerUser) ||
        (nextStep == 2 && _isFetchingCloudUserData) ||
        (nextStep == 3 && _isMigrating) )
    {
        nextStep += 0.5;
    }    
    
    if ( _currentStep != nextStep )
    {
        _currentStep = nextStep;
        [self _updateViewsForCurrentStep];
    }
}


#pragma mark - CloudKit step


- (BOOL)_testCloudKitStep
{
    UserProfile *profile = _ckUser.currentUserProfile;
    BOOL isIcloudReady = profile.token != nil && !_isGettingCloudAvailability;
    
    return isIcloudReady;
}


- (void)_establishCurrentUserCloudKit
{
    NSString *text = nil;
    UserProfile *profile = _ckUser.currentUserProfile;

    BOOL isIcloudReady = profile.token != nil;
    if ( isIcloudReady ) text = NSLocalizedString(@"Ready", nil);
    else text = NSLocalizedString(@"(none)", nil);
    
    NSString *textL = [NSString stringWithFormat:@"iCloud Account: %@", text];
    
    [_labelCurrentUserICLoud setText:textL];
}


#pragma mark - Integrators User step

- (BOOL)_testIntegratorsUserStep
{
    UserProfile *profile = _userModel.currentUserProfile;
    BOOL isReady = ! profile.isLocal;

    return isReady;
}

- (void)_establishCurrentUserIntegratorServer
{
    NSString *text = nil;
    UserProfile *profile = _userModel.currentUserProfile;

    BOOL isReady = ! profile.isLocal;
    
    NSString *buttonTitle = isReady ? @"Switch User" : @"Log in";
    [_buttonLogIn setTitle:buttonTitle forState:UIControlStateNormal];

    
    if ( isReady ) text = [self _userStringForProfile:profile];
    else text = NSLocalizedString(@"(none)", nil);
    
    NSString *textL = [NSString stringWithFormat:@"Current User: %@", text];

    [_labelCurrentUserIServer setText:textL];
}


- (void)_buttonLogIn:(id)sender
{
   _loginWindow = [[LoginWindowControllerC alloc] init] ;
    [_loginWindow setDelegate:self];
    
    NSString *userName =  [_userModel currentUserName];
    [_loginWindow setCurrentAccount:userName];
    [_loginWindow setUsername:userName];
    
    _isGettingIntegratorServerUser = YES;
    [self _setupCurrentStep];
    [_loginWindow showAnimated:YES completion:nil] ;
}


#pragma mark - Cloud kit user step

- (BOOL)_testCloudKitUserStep
{
    UserProfile *profile = _ckUser.currentUserProfile;
    BOOL isIcloudUserReady = [profile.username length] > 0 && !_isFetchingCloudUserData;
    
    return isIcloudUserReady;
}

- (void)_establishCurrentUserMovedCloudKit
{
    NSString *text = nil;
    UserProfile *profile = _ckUser.currentUserProfile;

    BOOL isIcloudReady = profile.token != nil;
    
    NSString *buttonTitle = isIcloudReady ? @"Update User" : @"Move User";
    [_buttonAccountToCloud setTitle:buttonTitle forState:UIControlStateNormal];
    
    if ( isIcloudReady ) text = [self _userStringForProfile:profile];
    else text = NSLocalizedString(@"(none)", nil);
    
    NSString *textL = [NSString stringWithFormat:@"Current User: %@", text];
    
    [_labelCurrentUserMovedICLoud setText:textL];
}

- (void)_buttonAccountToCloud:(id)sender
{
    UserProfile *profile = _userModel.currentUserProfile;
    if ( !profile.isLocal )
    {
        [_ckUser updateWithProfile:profile];
    }
}


#pragma mark - Migrate Step

- (BOOL)_testMigrateStep
{
    BOOL isReady = NO;
    isReady = _hasMigrated && !_isMigrating;
    
    return isReady;
}


//- (void)_establishActivity:(BOOL)state
//{
//    if ( state ) [_activityIndicator startAnimating];
//    else [_activityIndicator stopAnimating];
//
//    [_labelProgress1 setHidden:!state];
//    [_labelProgress2 setHidden:!state];
//}


- (void)_resetMigrationStep
{
//    [_labelProgress1 setText:@"Ready"];
//    [_labelProgress2 setText:@"Ready"];
    [_labelProgress1 setText:@"..."];
    [_labelProgress2 setText:@"..."];
}

- (void)_buttonMoveToCloud:(id)sender
{
    UserProfile *isProfile = _userModel.currentUserProfile;
    UserProfile *ckProfile = _ckUser.currentUserProfile;
    
#if HMiPadDev
    //NSArray *categories = @[ @(kFileCategoryRemoteSourceFile), @(kFileCategoryRemoteAssetFile), @(kFileCategoryRemoteActivationCode), @(kFileCategoryRemoteRedemption) ];
    NSArray *categories = @[ @(kFileCategoryRemoteSourceFile), @(kFileCategoryRemoteAssetFile), @(kFileCategoryRemoteActivationCode), @(kFileCategoryRemoteRedemption) ];
#endif

#if HMiPadRun
    NSArray *categories = @[ @(kFileCategoryRemoteRedemption) ];
#endif
    
    _isMigrating = YES;
    //[self _establishActivity:YES];
    [self _setupCurrentStep];
    [_filesModel migrateCategories:categories isProfile:isProfile ckProfile:ckProfile
    completion:^(BOOL success)
    {
        if ( success )
        {
            NSString *title = NSLocalizedString(@"Migration Assistant", nil);
            NSString *message = NSLocalizedString(@"\nMigration to HMI Pad iCloud has completed successfully. You can now close the Migration Assistant and start working with the app", nil);
            NSString *ok = NSLocalizedString(@"OK", nil);
            [SWQuickAlert presentQuickAlertWithTitle:title message:message actionTitle:ok handler:nil];
        }
    
        NSLog( @"migration finished with success:%d", success );
        _hasMigrated = success;
        _isMigrating = NO;
        
        if ( success )
            [defaults() setPendingMigrate:NO];
        
        [self _resetMigrationStep];
        [self _setupCurrentStep];
    }];
    
    
    
//    [_filesModel migrateCategory:kFileCategoryRemoteSourceFile isProfile:isProfile ckProfile:ckProfile
//    completion:^(BOOL success)
//    {
//        NSLog( @"migration finished with success:%d", success );
//        _hasMigrated = success;
//        [self _resetMigrationStep];
//        [self _establishActivity:NO];
//        [self _setupCurrentStep];
//    }];
}


#pragma mark - Close step

- (void)_buttonClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)_buttonSupport:(id)sender
{
    [self presentReviewAppMailController];
}


#pragma mark - SWAppCloudKitUserObserver

- (void)cloudKitUserCurrentUserWillLogIn:(SWAppCloudKitUser*)cloudKitUser
{
    _isGettingCloudAvailability = YES;
}

- (void)cloudKitUser:(SWAppCloudKitUser*)cloudKitUser currentUserDidLoginWithError:(NSError*)error
{
    _isGettingCloudAvailability = NO;
    [self _setupCurrentStep];
    [self _establishCurrentUserCloudKit];
    [self _establishCurrentUserMovedCloudKit];
}

- (void)cloudKitUserCurrentUserLogOut:(SWAppCloudKitUser*)cloudKitUser
{
    [self _setupCurrentStep];
    [self _establishCurrentUserCloudKit];
    [self _establishCurrentUserMovedCloudKit];
}


- (void)cloudKitUserWillFetchUserData:(SWAppCloudKitUser*)cloudKitUser
{
    _isFetchingCloudUserData = YES;
    [self _setupCurrentStep];
    [self _establishCurrentUserMovedCloudKit];
}


- (void)cloudKitUser:(SWAppCloudKitUser*)cloudKitUser didFetchUserDataWithError:(NSError*)error
{
    _isFetchingCloudUserData = NO;
    [self _setupCurrentStep];
    [self _establishCurrentUserMovedCloudKit];
}


- (void)cloudKitUserWillUpdateUserData:(SWAppCloudKitUser*)cloudKitUser
{
    _isFetchingCloudUserData = YES;
    [self _setupCurrentStep];
    [self _establishCurrentUserMovedCloudKit];
}


- (void)cloudKitUser:(SWAppCloudKitUser*)cloudKitUser didUpdateUserDataWithError:(NSError*)error
{
    _isFetchingCloudUserData = NO;
    [self _setupCurrentStep];
    [self _establishCurrentUserMovedCloudKit];
}





#pragma mark - UsersModel

- (void)appUsersModel:(AppUsersModel*)usersModel didLoginWithProfile:(UserProfile*)profile localLogin:(BOOL)remote withError:(NSError*)error
{
    _isGettingIntegratorServerUser = NO;
    [self _setupCurrentStep];
    [self _establishCurrentUserIntegratorServer];
}


#pragma mark - Login LoginWindowControllerDelegate

- (void)loginWindowDidClose:(LoginWindowControllerC*)sender
{    
    _loginWindow = nil;
    _isGettingIntegratorServerUser = NO;
    [self _setupCurrentStep];
    [self _establishCurrentUserIntegratorServer];
}


#pragma mark - AppFilesModelObserver


- (void)appFilesModel:(AppModelFilesEx*)filesModel willChangeMigrationListingForCategory:(FileCategory)category
{
    NSString *text1 = nil;
    if ( category == kFileCategoryRemoteSourceFile ) text1 = @"Fetching project file listing";
    else if ( category == kFileCategoryRemoteAssetFile ) text1 = @"Fetching asset file listing";
    else if ( category == kFileCategoryRemoteActivationCode ) text1 = @"Fetching activation codes listing";
    else if ( category == kFileCategoryRemoteRedemption ) text1 = @"Fetching redemption listing";
    
    [_labelProgress1 setText:text1];
    [_labelProgress2 setText:@"Starting"];
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel didChangeMigrationListingForCategory:(FileCategory)category withError:(NSError*)error
{
//    if ( error != nil )
//    {
//        [self _resetMigrationStep];
//        return;
//    }

    NSString *text1 = nil;
    if ( category == kFileCategoryRemoteSourceFile ) text1 = @"Fetching project file listing";
    else if ( category == kFileCategoryRemoteAssetFile ) text1 = @"Fetching asset file listing";
    else if ( category == kFileCategoryRemoteActivationCode ) text1 = @"Fetching activation codes listing";
    else if ( category == kFileCategoryRemoteRedemption ) text1 = @"Fetching redemption listing";
    
    [_labelProgress1 setText:text1];
    [_labelProgress2 setText:@"Complete"];
}

- (void)appFilesModel:(AppModelFilesEx*)filesModel beginMigrationGroupDownloadForCategory:(FileCategory)category
{
    NSString *text1 = nil;
    if ( category == kFileCategoryRemoteSourceFile ) text1 = @"Downloading project files";
    else if ( category == kFileCategoryRemoteAssetFile ) text1 = @"Downloading asset files";
    else if ( category == kFileCategoryRemoteActivationCode ) text1 = @"Retrieving activation codes";
    else if ( category == kFileCategoryRemoteRedemption ) text1 = @"Retrieving redemptions";
    
    [_labelProgress1 setText:text1];
    [_labelProgress2 setText:@"Starting"];
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel willDownloadMigrationFile:(NSString*)fileName forCategory:(FileCategory)category
{
    [_labelProgress2 setText:[NSString stringWithFormat:@"Downloading:'%@'", fileName]];
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel migrationFileDownloadProgress:(double)progress fileName:(NSString *)fileName category:(FileCategory)category
{
    [_labelProgress2 setText:[NSString stringWithFormat:@"'%@' download: %05.2f%%", fileName, progress*100]];
}

- (void)appFilesModel:(AppModelFilesEx*)filesModel didDownloadMigrationFile:(NSString*)fileName
    forCategory:(FileCategory)category withError:(NSError*)error;
{
//    if ( error != nil )
//    {
//        [self _resetMigrationStep];
//        return;
//    }
    [_labelProgress2 setText:[NSString stringWithFormat:@"'%@' complete", fileName]];
}


- (void)appFilesModel:(AppModelFilesEx*)filesModel endMigrationGroupDownloadForCategory:(FileCategory)category
    finished:(BOOL)finished userCanceled:(BOOL)canceled
{
//    if ( finished == NO )
//    {
//        [self _resetMigrationStep];
//        return;
//    }

    NSString *text1 = nil;
    if ( category == kFileCategoryRemoteSourceFile ) text1 = @"Downloading project files";
    else if ( category == kFileCategoryRemoteAssetFile ) text1 = @"Downloading asset files";
    else if ( category == kFileCategoryRemoteActivationCode ) text1 = @"Retrieving activation codes";
    else if ( category == kFileCategoryRemoteRedemption ) text1 = @"Retrieving redemptions";

    [_labelProgress1 setText:text1];
    [_labelProgress2 setText:@"Complete"];
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel beginGroupUploadForCategory:(FileCategory)category
{

    NSString *text1 = nil;
    if ( category == kFileCategoryRemoteSourceFile ) text1 = @"Migrating project files";
    else if ( category == kFileCategoryRemoteAssetFile ) text1 = @"Migrating asset files";
    else if ( category == kFileCategoryRemoteActivationCode ) text1 = @"Migrating activation codes";
    else if ( category == kFileCategoryRemoteRedemption ) text1 = @"Migrating redemptions";

    [_labelProgress1 setText:text1];
    [_labelProgress2 setText:@"Starting"];
    
    //[_progressView1 setProgress:0 animated:NO];
    //[_progressView2 setProgress:0 animated:NO];
}


//- (void)appFilesModel:(AppModelFilesEx *)filesModel groupUploadProgressStep:(NSInteger)step stepCount:(NSInteger)stepCount category:(FileCategory)category
//{
//    float progressValue = 0.1f + (float)step*(0.9f/(float)stepCount);
//    //[_progressView1 setProgress:progressValue animated:YES];
//    //[_progressView2 setProgress:0 animated:NO];
//}

- (void)appFilesModel:(AppModelFilesEx *)filesModel willUploadFile:(NSString *)fileName forCategory:(FileCategory)category
{
    //[_labelProgress1 setText:@"Migrating project files"];
    [_labelProgress2 setText:[NSString stringWithFormat:@"Processing '%@'", fileName]];
}

- (void)appFilesModel:(AppModelFilesEx *)filesModel fileUploadProgressBytesRead:(long long)bytesRead totalBytesExpected:(long long)totalBytesExpected category:(FileCategory)category
{
    //float progressValue = 0.1f + (float)bytesRead*(0.9f/(float)totalBytesExpected);
    //[_progressView2 setProgress:progressValue animated:YES];
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel fileUploadProgress:(double)progress fileName:(NSString *)fileName category:(FileCategory)category
{
    [_labelProgress2 setText:[NSString stringWithFormat:@"'%@' processed: %05.2f%%", fileName, progress*100]];
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel didUploadFile:(NSString *)fileName forCategory:(FileCategory)category withError:(NSError *)error
{
//    if ( error != nil )
//    {
//        [self _resetMigrationStep];
//        return;
//    }
//    [_labelProgress1 setText:@"Migrating project files"];
    [_labelProgress2 setText:[NSString stringWithFormat:@"'%@' complete", fileName]];
}


- (void)appFilesModel:(AppModelFilesEx *)filesModel endGroupUploadForCategory:(FileCategory)category
    finished:(BOOL)finished userCanceled:(BOOL)canceled
{
//    [self _resetMigrationStep];
    
    //[_progressView1 setProgress:0 animated:NO];
    //[_progressView2 setProgress:0 animated:NO];
    
    NSString *text1 = nil;
    if ( category == kFileCategoryRemoteSourceFile ) text1 = @"Migrating project files";
    else if ( category == kFileCategoryRemoteAssetFile ) text1 = @"Migrating asset files";
    else if ( category == kFileCategoryRemoteActivationCode ) text1 = @"Migrating activation codes";
    else if ( category == kFileCategoryRemoteRedemption ) text1 = @"Migrating redemptions";

    [_labelProgress1 setText:text1];
    [_labelProgress2 setText:@"Complete"];
}


@end
