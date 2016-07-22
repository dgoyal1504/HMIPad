//
//  SWInspectorViewController.m
//  HmiPad
//
//  Created by Joan on 19/02/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWInspectorViewController.h"
#import "SWStatusViewController.h"
#import "SWEventsViewController.h"
#import "SWHistoEventsViewController.h"
#import "SWSourcesViewController.h"
#import "SWDocumentModel.h"
#import "SWEventCenter.h"

#import "SWDocumentController.h"


//@interface SWTableViewLineLayer : CALayer
//@end
//
//@implementation SWTableViewLineLayer
//@end






@interface SWInspectorViewController ()<SWEventCenterObserver>
{
    SWDocumentModel *_docModel;
    SWEventsViewController *_eventsViewController;
    SWHistoEventsViewController *_histoEventsViewController;
    CALayer *_lineLayer;
    NSInteger _eventsControllerIndex;
}
@end

@implementation SWInspectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithDocumentModel:(SWDocumentModel*)docModel
{
    self = [super init];
    if ( self )
    {
        _docModel = docModel;
        
        // Status
        
        NSString *storyBoardStatus = @"SWStatusViewController";
        
        UIStoryboard *storyboard0 = [UIStoryboard storyboardWithName:storyBoardStatus bundle:nil];
        SWStatusViewController *statusViewController = [storyboard0 instantiateInitialViewController];
        statusViewController.documentModel = docModel;
        
        UINavigationController *nav0 = [[UINavigationController alloc] initWithRootViewController:statusViewController];
        
        [nav0.tabBarItem setImage:[UIImage imageNamed:@"724-info.png"]];
        [nav0.tabBarItem setSelectedImage:[UIImage imageNamed:@"724-info-selected.png"]];
        [statusViewController setTitle:NSLocalizedString(@"Project Status",nil)];
        [nav0.tabBarItem setTitle:NSLocalizedString(@"Status",nil)];   // <-- despres de setTitle del statusViewController
        
        // Sources
        
        NSString *storyBoardSources = @"SWSourcesViewController";
        
        UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:storyBoardSources bundle:nil];
        SWSourcesViewController *sourcesViewController = [storyboard1 instantiateInitialViewController];
        sourcesViewController.documentModel = docModel;
        
        UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:sourcesViewController];
        
        //[nav1.tabBarItem setImage:[UIImage imageNamed:@"55-network.png"]];
        [nav1.tabBarItem setImage:[UIImage imageNamed:@"938-connections.png"]];
        [nav1.tabBarItem setSelectedImage:[UIImage imageNamed:@"938-connections-selected.png"]];
        [sourcesViewController setTitle:NSLocalizedString(@"Connectors",nil)];
        
        // Alarms
        
        NSString *storyBoardEvents = @"SWEventsViewController";
        
        UIStoryboard *storyboard2 = [UIStoryboard storyboardWithName:storyBoardEvents bundle:nil];
        _eventsViewController = [storyboard2 instantiateInitialViewController];
        _eventsViewController.eventCenter = docModel.eventCenter;
        
        UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:_eventsViewController];
        
        //[nav2.tabBarItem setImage:[UIImage imageNamed:@"alarm30.png"]];
        [nav2.tabBarItem setImage:[UIImage imageNamed:@"719-alarm-clock.png"]];
        [nav2.tabBarItem setSelectedImage:[UIImage imageNamed:@"719-alarm-clock-selected.png"]];
        [_eventsViewController setTitle:@""]; // NSLocalizedString(@"A",nil)];
        [nav2.tabBarItem setTitle:NSLocalizedString(@"Alarms",nil)];  // <-- despres de setTitle del statusViewController
        
        // Histo Alarms
        
        NSString *storyBoardHistoEvents = @"SWHistoEventsViewController";
        
        UIStoryboard *storyboard3 = [UIStoryboard storyboardWithName:storyBoardHistoEvents bundle:nil];
        _histoEventsViewController = [storyboard3 instantiateInitialViewController];
        //_histoEventsViewController.documentModel = docModel;
        _histoEventsViewController.histoAlarms = docModel.histoAlarms;
        
        UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:_histoEventsViewController];
        
        //[nav2.tabBarItem setImage:[UIImage imageNamed:@"alarm30.png"]];
        [nav3.tabBarItem setImage:[UIImage imageNamed:@"796-clock-2.png"]];
        [nav3.tabBarItem setSelectedImage:[UIImage imageNamed:@"796-clock-2-selected.png"]];
        [_histoEventsViewController setTitle:NSLocalizedString(@"Histo Alarms",nil)];
        
        //[self.tabBar setBarStyle:UIBarStyleBlack];
        
        NSArray *controllers = @[nav0,nav1,nav2,nav3];
        
        if ( [_docModel.sourceItems count] == 0 ) _eventsControllerIndex = 1;  //
        
        _eventsControllerIndex = 2 ;   // << atencio important que el index coincideixi amb la posicio de nav2
        
        [self setViewControllers:controllers];
        
        NSInteger initialIndex = 1;    // << atencio, coincidir amb el connections
        if ( [_docModel.sourceItems count] == 0 ) initialIndex = 0;  // << atencio, coincidir amb el de status
        [self setSelectedIndex:initialIndex];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
   // [self.view setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.95]];

    if ( IS_IOS7 )
    {
        UIView *selfView = self.view;
        
//        [selfView setBackgroundColor:[[UIColor groupTableViewBackgroundColor] colorWithAlphaComponent:0.9]];
        [selfView setBackgroundColor:[UIColor clearColor]];
        
        // THE MOST UNEXPECTED: http://stackoverflow.com/questions/17704240/ios-7-dynamic-blur-effect-like-in-control-center
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:selfView.bounds];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //toolbar.barTintColor = selfView.tintColor;
        toolbar.barTintColor = nil;
        [selfView insertSubview:toolbar atIndex:0];
        
        _lineLayer = [[CALayer alloc] init];
        [_lineLayer setBackgroundColor:[UIColor darkGrayColor].CGColor];
        [selfView.layer addSublayer:_lineLayer];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.95]];
    }
}


- (void)viewDidLayoutSubviews
{
    UIView *selfView = self.view;
    CGRect bounds = selfView.bounds;
    //_lineLayer.frame = CGRectMake(-1, 0, 0.5, bounds.size.height);
    
    CGFloat contentScale = [[UIScreen mainScreen] scale];
    CGFloat pixelWidth = 1/contentScale;
    
    _lineLayer.frame = CGRectMake(-pixelWidth, 0, pixelWidth, bounds.size.height);
}


- (UIColor*)preferredCellBackgroundColor
{
//    if ( IS_IOS7 )  return [UIColor colorWithWhite:1.0 alpha:0.8];
//    else return [UIColor colorWithWhite:0.0 alpha:0.15];
    
    if ( IS_IOS7 )  return [UIColor colorWithWhite:1.0 alpha:0.6];
    else return [UIColor colorWithWhite:0.0 alpha:0.15];
}


- (void)_infoBadgeUpdate
{
    SWEventCenter *eventCenter = _docModel.eventCenter;
    NSString *badge = [NSString stringWithFormat:@"%ld/%lu",(long)eventCenter.numberOfActiveEvents,(unsigned long)eventCenter.events.count];
    [_eventsViewController.navigationController.tabBarItem setBadgeValue:badge];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _infoBadgeUpdate];
    [_docModel.eventCenter addObserver:self];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [_docModel.eventCenter removeObserver:self];
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showEventsList
{
    [self setSelectedIndex:_eventsControllerIndex];
}

#pragma mark SWEventCenterObserver

- (void)eventCenterDidChangeEvents:(SWEventCenter *)alarmCenter
{
    [self _infoBadgeUpdate];
}



@end
