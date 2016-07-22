//
//  SWEventsViewController.m
//  HmiPad
//
//  Created by Joan on 08/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWEventsViewController.h"
#import "SWInspectorViewController.h"

#import "SWTableViewMessage.h"

#import "ColoredButton.h"
#import "SWColor.h"
#import "UIView+Additions.h"
#import "SWEventCell.h"
#import "SWEvent.h"
#import "SWEventCenter.h"

@interface SWEventsViewController ()
@end

@interface SWEventsViewController(ModelObserver) <SWEventCenterObserver>
@end

@implementation SWEventsViewController
{
    CGRect _commentFrame;
    SWEventCell *_anyCell;
}

@synthesize eventCenter = _eventCenter;
//@synthesize ackButton = _ackButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.navigationBar.tintColor = nil;
    
    UITableView *tableView = self.tableView;   // es un SWTableView
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;    // no separator
  //  tableView.separatorColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    
//    [tableView setContentInset:UIEdgeInsetsMake(0, 0, 48, 0)];   // workaround al defecte del UITabBar
//    [tableView setScrollIndicatorInsets:tableView.contentInset];   // workaround al defecte del UITabBar


    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableHeader];
    [messageView setMessage:NSLocalizedString(@"EventsViewControllerFooter", nil)];
    [messageView setEmptyTitle:NSLocalizedString(@"No Alarms", nil)];
    [tableView setTableHeaderView:messageView];
    
    [self establishAckButton:YES animated:NO];
    [self establishInfoLabel:YES animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    [self infoLabelUpdate];
    [_eventCenter addObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_eventCenter removeObserver:self];
    [super viewWillDisappear:animated];
}


#pragma mark - Properties

- (UIButton *)ackButton
{
    UIButton *btn1;
    if ( IS_IOS7 )
    {
        btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [[btn1 titleLabel] setFont:[UIFont systemFontOfSize:17]];
    }
    else
    {
        btn1 = [[ColoredButton alloc] init];
        [[btn1 titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
    }
    [btn1 setAutoresizingMask:(UIViewAutoresizingNone)];
    [btn1 setFrame:CGRectMake(0, 0, 120, 29)];
    if ( [btn1 respondsToSelector:@selector(setRgbTintColor:overWhite:)] )
        [(ColoredButton*)btn1 setRgbTintColor:TextDefaultColor overWhite:NO];
    [btn1 setTitle:NSLocalizedString(@"Acknowledge",nil) forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [btn1 addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchCancel];
    [btn1 addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    //[btn1 addTarget:self action:@selector(ackButtonTouched:forEvent:) forControlEvents:UIControlEventAllTouchEvents];
    return btn1;  // el retenim per seguir la tonica d'altres parts
}

- (UILabel *)infoLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,20)];
    [label setAutoresizingMask:(UIViewAutoresizingNone)];
    [label setBackgroundColor:[UIColor clearColor]];
    
    if ( IS_IOS7 )
    {
        [label setTextColor:[UIColor darkGrayColor]];
        [label setShadowColor:[UIColor whiteColor]];
    }
    else
    {
        [label setTextColor:[UIColor whiteColor]];
        [label setShadowColor:[UIColor grayColor]];
    }
    [label setFont:[UIFont boldSystemFontOfSize:15]];
    [label setTextAlignment:NSTextAlignmentRight];
    return label;
}

- (void)establishAckButton:(BOOL)putIt animated:(BOOL)animated
{
    UIBarButtonItem *button = nil;
    if ( putIt )
    {
        UIButton *theButton = [self ackButton];
        button = [[UIBarButtonItem alloc] initWithCustomView:theButton];
    }
    [[self navigationItem] setLeftBarButtonItem:button animated:animated];
}

- (void)infoLabelUpdate
{    
    if ( infoLabel )
    {
        NSInteger alarmsCount = _eventCenter.events.count;
        NSInteger activeCount = _eventCenter.numberOfActiveEvents;
        NSString *limitsText = [NSString stringWithFormat:@"%ld / %ld", (long)activeCount, (long)alarmsCount];
        [infoLabel setText:limitsText];
    }
}

- (void)establishInfoLabel:(BOOL)putIt animated:(BOOL)animated
{
    UIBarButtonItem *button;
    if ( putIt )
    {
        if (infoLabel == nil ) infoLabel = [self infoLabel];
        [self infoLabelUpdate];
        button = [[UIBarButtonItem alloc] initWithCustomView:infoLabel];
    }
    else
    {
        button = nil;
        infoLabel = nil;
    }
    
    [[self navigationItem] setRightBarButtonItem:button animated:animated];
}



- (void)setEventCenter:(SWEventCenter *)eventCenter
{
    _eventCenter = eventCenter;
    
    if (self.isViewLoaded)
    {
        [self.tableView reloadData];
    }
}

#pragma mark actions

- (void)button:(UIButton *)sender changedTo:(BOOL)newState
{   
    if ( newState == NO )
    {
        [_eventCenter eventsAcknowledgeEvents];
    }
    
    // TO DO actualitzar system expressions
//    // enviem els reconeixement (primer 1, despres 0 al PLC)
//    SystemExpressions *systemExpressions = [theModel systemExpressions];
//    ExpressionBase *ackExpression = [systemExpressions ackExpression];
//    [ackExpression evalWithConstantValue:(double)newState];
}


//- (void)ackButtonTouched:(UIControl *)sender forEvent:(UIEvent*)event
//{ 
//    UITouchPhase phase = [sender touchFaseForEvent:event];
//    
//    int newState = -1;
//    if ( phase == UITouchPhaseBegan )  newState = 1;
//    else if ( phase == UITouchPhaseEnded || phase == UITouchPhaseCancelled || phase == -1 )  newState = 0;
//    else if ( phase == UITouchPhaseMoved ) newState = [sender isTouchInside];
//    
//    if ( newState != -1 && newState != [sender tag] )
//    {
//        [self button:(id)sender changedTo:(newState != 0)];
//        [sender setTag:newState];
//    }
//}

- (IBAction)buttonTouchDown:(id)sender
{
    [self button:sender changedTo:1];
}

- (IBAction)buttonTouchUp:(id)sender
{
    [self button:sender changedTo:0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *events = _eventCenter.events;
    NSInteger rowsCount = events.count;
    //if (count == 0) count = 1;
    
    [(id)tableView.tableHeaderView showForEmptyTable:(rowsCount==0)];
   // [tableView setScrollEnabled:(rowsCount>0)];
    
    return rowsCount;
}


static NSString *CellIdentifier = @"SWEventCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSArray *events = _eventCenter.events;
    NSInteger row = indexPath.row;
    SWEvent *event = [events objectAtIndex:row];
    
    cell.event = event;
        
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ( _anyCell == nil )
        _anyCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *events = _eventCenter.events;
    NSInteger row = indexPath.row;
    SWEvent *event = [events objectAtIndex:row];
    NSString *comment = event.commentText;
    
    CGFloat height = [_anyCell heightForComment:comment];
    
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    NSArray *events = _eventCenter.events;
    NSInteger rowsCount = events.count;
    if ( rowsCount > 0)
        title = NSLocalizedString(@"Real Time Alarms", nil);
    
    return title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [(SWInspectorViewController*)self.tabBarController preferredCellBackgroundColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end

@implementation SWEventsViewController (ModelObserver)

- (void)eventCenterDidChangeEvents:(SWEventCenter *)alarmCenter
{
    // TO DO: no s'ha de fer un reload data! s'han de fer animacions per les insercions, supressions i canvis varis!

    [self.tableView reloadData];
//    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d/%d",_eventCenter.numberOfActiveEvents,_eventCenter.events.count];
    [self infoLabelUpdate];
}

@end
