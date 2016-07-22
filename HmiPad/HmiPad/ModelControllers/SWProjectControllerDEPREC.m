//
//  SWProjectController.m
//  HmiPad
//
//  Created by Joan on 19/09/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWProjectController.h"
#import "FilesViewController.h"
#import "SettingsViewController.h"

@interface SWProjectController ()

@end

@implementation SWProjectController
{
    UINavigationController *_settingsNavigator;
    UINavigationController *_filesNavigator;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
//        SettingsViewController *settingsController = [[SettingsViewController alloc] init];
//    
//        FilesViewController *filesController = [[FilesViewController alloc] init];
//    
//        //_filesNavigator = [[UINavigationController alloc] initWithRootViewController:filesController];
//        //_settingsNavigator = [[UINavigationController alloc] initWithRootViewController:settingsController];
//        //[self setViewControllers:@[_settingsNavigator, _filesNavigator]];
//    
//        [self setTabbedViewControllers:@[settingsController, filesController] animated:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    SettingsViewController *settingsController = [[SettingsViewController alloc] init];
    
    FilesViewController *filesController = [[FilesViewController alloc] init];
    
    //_filesNavigator = [[UINavigationController alloc] initWithRootViewController:filesController];
    //_settingsNavigator = [[UINavigationController alloc] initWithRootViewController:settingsController];
    //[self setViewControllers:@[_settingsNavigator, _filesNavigator]];
    
    [self setTabbedViewControllers:@[settingsController, filesController] animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
