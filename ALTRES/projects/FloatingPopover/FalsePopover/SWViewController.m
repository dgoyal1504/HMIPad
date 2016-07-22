//
//  AEViewController.m
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWViewController.h"
#import "SWFloatingPopoverController.h"

#import "DemoTableViewController.h"

@implementation SWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_set = [NSMutableSet set];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _set = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)addFloatingPopover:(id)sender
{    
    DemoTableViewController *viewController = [[DemoTableViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.contentSizeForViewInPopover = CGSizeMake(320, 460);
    
    SWFloatingPopoverController *popover = [[SWFloatingPopoverController alloc] initWithContentViewController:viewController];
    popover.delegate = self;
    
    CGFloat rand1,rand2,rand3;   
    rand1 = ((float)(abs(arc4random())%100))/100.0;
    rand2 = ((float)(abs(arc4random())%100))/100.0;
    rand3 = ((float)(abs(arc4random())%100))/100.0;
    
    popover.frameColor = [UIColor colorWithRed:rand1 green:rand2 blue:rand3 alpha:1.0];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:popover 
                                                                               action:@selector(dismissFloatingPopoverAnimated:)];
    viewController.navigationItem.rightBarButtonItem = closeItem;
    
    [_set addObject:popover];
        
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            rand1 = abs(arc4random())%1024;
            rand2 = abs(arc4random())%768;
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            rand1 = abs(arc4random())%768;
            rand2 = abs(arc4random())%1024;        
            break;
        default:
            break;
    }
    
    [self addChildViewController:popover];
    [popover presentFloatingPopoverAtPoint:CGPointMake(rand1, rand2) inView:self.view animated:YES];
    [popover didMoveToParentViewController:self];
}

- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)floatingPopoverController
{
    [_set removeObject:floatingPopoverController];
}

@end
