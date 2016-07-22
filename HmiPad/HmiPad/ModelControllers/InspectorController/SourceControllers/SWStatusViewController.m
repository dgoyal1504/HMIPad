//
//  SWSourcesViewController.m
//  HmiPad
//
//  Created by Joan Martin on 7/30/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <mach/mach.h>

#import "SWStatusViewController.h"

#import "SWInspectorViewController.h"

#import "SWDocument.h"
#import "SWDocumentModel.h"
#import "SWProjectUser.h"
#import "SWPlcDevice.h"

#import "SWEventCenter.h"
#import "SWValue.h"

//#import "SWTableSectionHeaderView.h"

#import "SWSourcesViewControllerHeader.h"
#import "SWSourceTagsViewController.h"



@interface SWStatusViewController ()
@end

@interface SWStatusViewController (ModelObserver) <DocumentModelObserver,SWEventCenterObserver>
@end

@implementation SWStatusViewController
{
    dispatch_source_t _cpuUpdateTimer;
    float _cpuRate;
}

@synthesize documentModel = _documentModel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    //_offset = CGPointZero;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = nil;
    
    UITableView *tableView = self.tableView;     // es un SWTableView
        
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    [tableView setTableHeaderView:_headerView];
}

//- (void)viewDidUnload
//{
//    [self setEnableConnectionsSwitch:nil];  // xxx
//    [super viewDidUnload];
//}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.editing = self.navigationController.editing;
    
    [self.tableView reloadData];
    [self _updateUserLabel];
    [self _updateAlarmsLabel];
    [self _updateCpuLabelWithValue:0];
    [self _updateTagsLabel];
    [self _updateConnectionsLabel];
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;

    [nc addObserver:self selector:@selector(_commStateChangeNotification:) name:kFinsStateDidChangeNotification object:nil];
    [nc addObserver:self selector:@selector(_tagCountChangeNotification:) name:kFinsNumberOfTagsDidChangeNotification object:nil];
    
    [_documentModel addObserver:self];
    [_documentModel.eventCenter addObserver:self];
    [self _startUpdateCpuTimer];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_documentModel removeObserver:self];
    [_documentModel.eventCenter removeObserver:self];
    [self _stopUpdateCpuTimer];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.tableView reloadData];  // Aixo causa la crida a tableView:didEndDisplayingCell de les celdes, cool!
}


#pragma mark Properties

- (void)setDocumentModel:(SWDocumentModel *)documentModel
{
    _documentModel = documentModel;
    
    if (self.isViewLoaded)
        [self.tableView reloadData];
}


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    return sections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - View update


- (void)_updateUserLabel
{
    SWProjectUser *projectUser = _documentModel.selectedProjectUser;
    SWValue *userNameVa = projectUser.userName;
    NSString *text = nil;
    if ( userNameVa == nil || [userNameVa valueIsEmpty] ) text = NSLocalizedString(@"[Administrator]", nil);
    else text = [userNameVa valueAsString];
    [_headerView.userLabel setText:text];
}


- (void)_updateAlarmsLabel
{
    SWEventCenter *eventCenter = _documentModel.eventCenter;
    NSInteger total = eventCenter.events.count;
    //NSInteger unAck = eventCenter.numberOfUnacknowledgedActiveEvents;
    NSInteger active = eventCenter.numberOfActiveEvents;
    
    //NSString *format = NSLocalizedString(@"active %d / total %d", nil);
    NSString *format = @"%d / %d";
    NSString *badge = [NSString stringWithFormat:format, active, total];
    [_headerView.alarmsLabel setText:badge];
    
//    NSString *imageName = active>0?(unAck>0?@"alarm20Red.png":@"alarm20DarkRed.png"):@"alarm20.png";
//    [_headerView.imageViewAlarm setImage:[UIImage imageNamed:imageName]];
}


- (void)_updateCpuLabelWithValue:(float)value
{
    float filter = 0.2f;
    _cpuRate = value*filter + _cpuRate*(1-filter);
    //NSString *format = NSLocalizedString(@"rate %1.1f%%", nil);
    NSString *format = @"%1.1f%%";
    NSString *text = [NSString stringWithFormat:format, _cpuRate];
    [_headerView.cpuLabel setText:text];
}


- (void)_updateTagsLabel
{
    int totalTags = 0;
    int pollingTags = 0;
    
    NSArray *sourceItems = [_documentModel sourceItems];
    for ( SWSourceItem *sourceItem in sourceItems )
    {
        totalTags += sourceItem.sourceNodes.count;
        pollingTags += sourceItem.numberOfTags;
    }


    //NSString *format = NSLocalizedString(@"using %d / total %d", nil);
    NSString *format = @"%d / %d";
    NSString *badge = [NSString stringWithFormat:format, pollingTags, totalTags];
    [_headerView.tagsLabel setText:badge];
}


- (void)_updateConnectionsLabel
{
    enum SWCommStateValues
    {
        kCommStateLinked = 0,
        kCommStateStop = 1,
        kCommStatePartialLink = 2,
        kCommStateError = 3,
    };
    
    NSArray *sourceItems = [_documentModel sourceItems];

    int totalMonitor = 0;
    int totalErrors = 0;
    int totalStarted = 0;
    int totalLinked = 0;
    int totalPlcSources = 0;
    int totalLocal = 0;
    int totalRemote = 0;
    
    for ( SWSourceItem *sourceItem in sourceItems )
    {
        totalPlcSources += 1 ;
        BOOL monitorOn = sourceItem.monitorOn;
        if ( monitorOn )
        {
            totalMonitor +=1 ;
            if ( sourceItem.error ) totalErrors += 1;
            if ( sourceItem.plcObjectStarted) totalStarted += 1 ;
            if ( sourceItem.plcObjectLinked ) totalLinked += 1 ;
            int route = sourceItem.plcObjectRoute;
            if ( route == 1 ) totalLocal += 1;
            if ( route == 2 ) totalRemote += 1;
        }
    }

    ItemDecorationType decoration = ItemDecorationTypeNone;
    
    if ( totalMonitor == 0 ) decoration = ItemDecorationTypeGray;
    else if ( totalPlcSources > 0 && totalErrors == totalPlcSources ) decoration = ItemDecorationTypeRed;
    else if ( totalLinked < totalStarted || totalErrors > 0 ) decoration = ItemDecorationTypePurple;
    else decoration = ItemDecorationTypeGreen;
    
    NSInteger total = sourceItems.count;
    //NSString *format = NSLocalizedString(@"linked %d / total %d", nil);
    NSString *format = @"%d / %d";
    NSString *badge = [NSString stringWithFormat:format, totalLinked, total];
    [_headerView.connectionLabel setText:badge];
    
//    CGRect frame = _headerView.imageViewConnection.frame;
//    [_headerView.imageViewConnection removeFromSuperview];
//    UIView *imgView = [UIView decoratedViewWithFrame:frame forSourceItemDecoration:decoration animated:YES];
//    _headerView.imageViewConnection = (id)imgView;
//    [_headerView addSubview:imgView];
}


#pragma mark - cpu rate updates

static float _cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;

    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }

    //task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;

    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;

    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads

    //basic_info = (task_basic_info_t)tinfo;

    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;

    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;

    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }

        basic_info_th = (thread_basic_info_t)thinfo;

        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }

    } // for each thread

    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);

    return tot_cpu;
}


- (void)_startUpdateCpuTimer
{
    dispatch_queue_t concurrentQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    if ( _cpuUpdateTimer == nil )
    {
        _cpuUpdateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, concurrentQ);
		
        dispatch_source_set_event_handler( _cpuUpdateTimer,
        ^{
            float cpu = _cpu_usage();
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self _updateCpuLabelWithValue:cpu];
            });
        });
    
        dispatch_resume(_cpuUpdateTimer);
        dispatch_source_set_timer(_cpuUpdateTimer, DISPATCH_TIME_NOW, NSEC_PER_SEC/2, 0);      // 0.5 seg
    }
}


- (void)_stopUpdateCpuTimer
{
    if (_cpuUpdateTimer)
    {
        dispatch_source_cancel(_cpuUpdateTimer);
        _cpuUpdateTimer = NULL;
    }
}





#pragma mark StateChangeNotification

//@implementation SWStatusViewController (NotificationObserver)


- (void)_commStateChangeNotification:(NSNotification*)note
{
    [self _updateConnectionsLabel];
}

- (void)_tagCountChangeNotification:(NSNotification*)note
{
    [self _updateTagsLabel];
}


@end


#pragma mark SWEventCenterObserver


@implementation SWStatusViewController (EventCenterObserver)

- (void)eventCenterDidChangeEvents:(SWEventCenter *)alarmCenter
{
    [self _updateAlarmsLabel];
}

@end


@implementation SWStatusViewController (ModelObserver)

- (void)documentModel:(SWDocumentModel *)docModel didInsertSourceItemsAtIndexes:(NSIndexSet *)indexes
{
    [self _updateConnectionsLabel];
}

- (void)documentModel:(SWDocumentModel *)docModel didRemoveSourceItemsAtIndexes:(NSIndexSet *)indexes
{
    [self _updateConnectionsLabel];
}

- (void)documentModel:(SWDocumentModel *)docModel selectedProjectUserDidChange:(SWProjectUser *)user
{
    [self _updateUserLabel];
}

@end

