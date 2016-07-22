//
//  SWEmptyViewController.m
//  HmiPad
//
//  Created by Joan on 03/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWEmptyViewController.h"
#import "SWTableViewMessage.h"

@interface SWEmptyViewController ()

@end

@implementation SWEmptyViewController

- (void)loadView
{
    UIView *selfView = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];

    SWTableViewMessage *message = [[SWTableViewMessage alloc] initForTableFooter];
    [message setEmptyTitle:NSLocalizedString(@"No Selection", nil)];
    [message setMessage:NSLocalizedString(@"", nil)];
    [message showForEmptyTable:YES];
    
    self.title = NSLocalizedString(@"Objects", nil);
    
    [selfView setBackgroundColor:[UIColor colorWithWhite:0.90 alpha:1.0]];
    [selfView addSubview:message];
    self.view = selfView;
}


@end
