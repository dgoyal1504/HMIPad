//
//  SWTableViewController.m
//  HmiPad
//
//  Created by Joan on 25/02/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWTableViewController.h"
#import "SWTableView.h"

@interface SWTableViewController ()

@end

@implementation SWTableViewController
{
    UITableViewStyle _tableViewStyle;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self)
    {
        _tableViewStyle = style;  // <-- utilitzada de manera temporal, no accesible desde la interface
        _clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        _clearsSelectionOnViewWillAppear = YES;
    }
    return self;

}


- (UITableView *)tableView
{
    return (id)[self view];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}


- (void)loadView
{
    if ( self.nibName /*|| self.storyboard*/ )
    {
        [super loadView];
        return;
    }

    // Do not call super, to prevent the apis from unfruitful looking for inexistent xibs!
    
    // This is what Apple tells us to set as the initial frame, which is of course totally irrelevant
    // with the modern view controller containment patterns, let's leave it for the sake of it!
    CGRect frame = [[UIScreen mainScreen] applicationFrame];

    // create a custom content view for the controller (e.g a UITableView)
    UITableView *tableView = [[SWTableView alloc] initWithFrame:frame style:_tableViewStyle];
    
    // set the content view to resize along with its superview
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    // set delegates for the UITableView to self
    tableView.dataSource = self;
    tableView.delegate = self;

    // set our contentView to the controllers view
    self.view = tableView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

//- (void)didMoveToParentViewController:(UIViewController *)parent
//{
//    [super didMoveToParentViewController:parent];
//    if ( IS_IOS7 )
//    {
//        if ( [parent isKindOfClass:[UINavigationController class]] )
//        {
//            SWTableView *tableView = (id)self.view;
//            [tableView setTableViewOffset:CGPointMake(0,-44)];
//        }
//    }
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( _clearsSelectionOnViewWillAppear )
        [self _deselectAllAnimated:YES];
}


- (void)_deselectAllAnimated:(BOOL)animated
{
    UITableView *table = self.tableView;
    NSArray *indexPaths = [table indexPathsForSelectedRows];
    
    for ( NSIndexPath *indexPath in indexPaths )
    {
        [table deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


@end
