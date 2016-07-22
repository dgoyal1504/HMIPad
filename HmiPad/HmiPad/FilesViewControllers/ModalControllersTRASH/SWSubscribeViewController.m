//
//  SWUploadViewController.m
//  HmiPad
//
//  Created by Joan on 18/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWSubscribeViewController.h"
#import "ColoredButton.h"
#import "AppFilesModel.h"
#import "SWColor.h"

@interface SWSubscribeViewController ()<AppsFileModelObserver>

@end

@implementation SWSubscribeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"xWhiteShadow.png"]
                    style:UIBarButtonItemStyleBordered
                    target:self
                    action:@selector(_dismissController:)];
    [[self navigationItem] setLeftBarButtonItem:closeItem];
    
    [_buttonUpload setRgbTintColor:Theme_RGB(0, 255, 255, 255) overWhite:YES];
    [_labelHeader setText:NSLocalizedString(@"UploadViewControllerMessage", nil)];
}


- (void)viewWillAppear:(BOOL)animated
{
    FileMD *documentMD = [filesModel() currentDocumentFileMD];
    NSString *title = documentMD.fileName;
    
    [[self navigationItem] setTitle:title];
    [_labelProgress setText:title];
    
    [self _establishActivityIndicatorAnimated:animated];
    
    [filesModel() addObserver:self];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [filesModel() removeObserver:self];
}


#pragma mark private

- (void)_dismissController:(id)sender
{
    [self dismissModalViewControllerAnimated:YES] ;
}

- (void)_establishActivityIndicatorAnimated:(BOOL)animated
{
    BOOL updating = [filesModel() updatingProject];
    BOOL putIt = updating;

    UIBarButtonItem *btnItem = nil ;
    if ( putIt )
    {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activity startAnimating];

        btnItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
    }
    else
    {
        NSLog( @"%@,%g", _progressView, _progressView.progress );
        [_progressView setProgress:0];
        [_detailProgressView setProgress:0];
    }
    
    [[self navigationItem] setRightBarButtonItem:btnItem animated:YES];
    NSString *buttonTitle = nil;
    if ( putIt ) buttonTitle = NSLocalizedString(@"CANCEL UPLOAD", nil);
    else buttonTitle = NSLocalizedString(@"BEGIN UPLOAD", nil);
    [_buttonUpload setTitle:buttonTitle forState:UIControlStateNormal];
}


#pragma mark button action

- (IBAction)uploadButtonAction:(id)sender
{
    NSInteger uploadStep = [filesModel() groupUploadStep];
    if ( uploadStep == 0 )
        [filesModel() uploadDocument];
    else
        [filesModel() cancelUpload];
}


#pragma mark AppsFileModelObserver


- (void)appFilesModelBeginGroupUpload:(AppFilesModel*)filesModel
{
    [self _establishActivityIndicatorAnimated:YES];
}


- (void)appFilesModel:(AppFilesModel*)filesModel willUploadFile:(NSString*)fileName forCategory:(FileCategory)category
{
    NSLog( @"Will upload %@", fileName );

    NSString *text = [NSString stringWithFormat:@"%@ '%@'", NSLocalizedString(@"Uploading:",nil), fileName];
    [_labelDetailProgress setText:text];
}


- (void)appFilesModel:(AppFilesModel*)filesModel didUploadFile:(NSString*)fileName
    forCategory:(FileCategory)category withError:(NSError*)error
{
    
    NSLog( @"Did upload %@", fileName );
    
    [_labelDetailProgress setText:NSLocalizedString(@"Progress", nil)];
        
    if ( NO )
    {
        if ( error )
        {
            NSString *title = NSLocalizedString(@"Integrators Service Upload", nil );
            NSString *message = [error localizedDescription];
            NSString *ok = NSLocalizedString( @"Ok", nil );
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil
                otherButtonTitles:ok, nil];
            [alert show];
        }
    }
}


- (void)appFilesModelEndGroupUpload:(AppFilesModel*)filesModel finished:(BOOL)finished
{
    [self _establishActivityIndicatorAnimated:YES];
}


- (void)appFilesModel:(AppFilesModel*)filesModel groupUploadProgressStep:(NSInteger)step
    stepCount:(NSInteger)stepCount;
{
    float progressValue = (float)step/(float)stepCount;
    [_progressView setProgress:progressValue animated:YES];
    [_detailProgressView setProgress:0.05f animated:NO];
}


- (void)appFilesModel:(AppFilesModel *)filesModel fileUploadProgressBytesRead:(long long)bytesRead
    totalBytesExpected:(long long)totalBytesExpected
{
    float progressValue = (float)bytesRead/(float)totalBytesExpected;
    [_detailProgressView setProgress:progressValue animated:YES];
}

@end
