//
//  SWViewController.m
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWViewController.h"
#import "SWImagePickerController.h"

@interface SWViewController () <SWImagePickerControllerDelegate>

@end

@implementation SWViewController
@synthesize imageView = _imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)foo:(id)sender
{
    NSString *documents = [self.class applicationDocumentsDirectory];
    NSString *path = [documents stringByAppendingPathComponent:@"Pictures"];
    
    SWImagePickerController *picker = [[SWImagePickerController alloc] initWithContentsAtPath:path];
    picker.title = @"Image Picker";
    picker.delegate = self;
    //picker.allowsDeletion = NO;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:picker];
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    UIView *view = sender;
    [_popover presentPopoverFromRect:view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark Protocol SWImagePickerControllerDelegate

- (void)imagePickerController:(SWImagePickerController *)imagePicker didSelectImage:(UIImage *)image
{
    [_popover dismissPopoverAnimated:YES];
    self.imageView.image = image;
}

+ (NSString*)applicationDocumentsDirectory 
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


@end
