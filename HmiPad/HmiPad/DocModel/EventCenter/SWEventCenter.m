//
//  SWAlarmCenter.m
//  HmiPad
//
//  Created by Joan Martin on 8/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWEventCenter.h"

#import "SWAlarm.h"
#import "SWEvent.h"

#import "SWPlayerCenter.h"
#import "SWBlockAlertView.h"

@interface SWEventCenter()
{
    NSMutableArray *_observers;
    BOOL _pendingCommitAlarmNodesChange;
}

@property (nonatomic) SWBlockAlertView *alertView;
@end


@implementation SWEventCenter

@synthesize events = _events;
@synthesize mostRecentEvent = _mostRecentEvent;
@synthesize numberOfActiveEvents = _numberOfActiveEvents;
@synthesize numberOfUnacknowledgedEvents = _numberOfUnacknowledgedEvents;

#pragma mark - Initialization

- (void)doInit
{
    _events = [NSMutableArray array];
    _numberOfUnacknowledgedEvents = 0;
    _numberOfUnacknowledgedActiveEvents = 0;
    _numberOfActiveEvents = 0;
    
    //_observers = [NSMutableArray array];
    _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self doInit];
    }
    return self;
}


#pragma mark QuickCoding

//- (id)initWithQuickCoder:(QuickUnarchiver *)unarchiver
//{
//    self = [super init];
//    if (self)
//    {
//        _events = [unarchiver decodeObject];
//        _numberOfActiveEvents = [unarchiver decodeInt];
//        _numberOfUnacknowledgedEvents = [unarchiver decodeInt];
//        
//        _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
//    }
//    return self;
//}

//- (void)encodeWithQuickCoder:(QuickArchiver *)archiver
//{
//    [archiver encodeObject:_events];
//    [archiver encodeInt:_numberOfActiveEvents];
//    [archiver encodeInt:_numberOfUnacknowledgedEvents];
//}


//- (id)initWithQuickCoder:(QuickUnarchiver *)unarchiver
//{
//    return [self init];
//}
//
//- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
//{
//}
//
//
//- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
//{
//    _numberOfActiveEvents = [decoder decodeInt];
//    _numberOfUnacknowledgedEvents = [decoder decodeInt];
//    _events = [decoder decodeObject];  // fem un decode en lloc de un retrieve
//}
//
//- (void)storeWithQuickCoder:(QuickArchiver *)encoder
//{
//    [encoder encodeInt:_numberOfActiveEvents];
//    [encoder encodeInt:_numberOfUnacknowledgedEvents];
//    [encoder encodeObject:_events];
//}
//
//
//#pragma mark SymbolicCoding
//
//- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
//{
//    return [self init];
//}
//
//- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
//{
//}
//
//- (void)retrieveWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
//{
//    [decoder decodeIntForKey:@"numberOfActiveEvents"];
//    [decoder decodeIntForKey:@"numberOfUnacknowledgedEvents"];
//    [decoder retrieveForCollectionOfObjects:_events forKey:@"events"];
//}
//
//- (void)storeWithSymbolicCoder:(SymbolicArchiver *)encoder
//{
//    [encoder encodeInt:_numberOfActiveEvents forKey:@"numberOfActiveEvents"];
//    [encoder encodeInt:_numberOfUnacknowledgedEvents forKey:@"numberOfUnacknowledgedEvents"];
//    [encoder encodeCollectionOfObjects:_events forKey:@"events"];
//}
//
//



#pragma mark - Observation

- (void)addObserver:(id)object
{
    [_observers addObject:object];
}
- (void)removeObserver:(id)object
{
    [_observers removeObject:object];
}

#pragma mark - AlarmNodes

- (void)updateEventsForHolder:(id<SWEventHolder>)holder
{
    BOOL itemActive = [holder activeStateForEvent];
    SWEvent *newEvent = nil;
    
    if (itemActive)
    {
        NSUInteger count = _events.count;
        NSUInteger i=0;
        for (; i<count; i++)
        {
            SWEvent *event = [_events objectAtIndex:i];
            if (event.holder == holder && event.active)
                break;
        }
        
        if  (i == count)
            newEvent = [self _eventsAddNewEventForHolder:holder];
    }
    
    else
    {
        [self _eventsRemoveEventsForHolder:holder];
    }
    
    if ( newEvent )
    {
        BOOL shouldAlert = [holder shouldShowAlertForEvent];
        if ( shouldAlert )
        {
            if ( _alertView )
            {
                [_alertView dismissWithClickedButtonIndex:_alertView.cancelButtonIndex animated:YES];
            }
        
            NSString *format = NSLocalizedString(@"%@\n%@: %@", nil);
        
            _alertView = [[SWBlockAlertView alloc]
                initWithTitle:NSLocalizedString(@"Alarm", nil)
                message:[NSString stringWithFormat:format, newEvent.getTimeStampString, newEvent.labelText, newEvent.commentText ]
                delegate:nil
                cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                otherButtonTitles:@"Show List", nil];
            
            __weak SWEventCenter *weakSelf = self;
            [_alertView setResultBlock:^(BOOL success, NSInteger index)
            {
                NSLog( @"index: %ld", (long)index);
                SWPlayerCenter *playerCenter = [SWPlayerCenter defaultCenter];
                [playerCenter playSoundTextUrl:nil labelText:nil];  // aturem el so. seria millor tenir un 'context' en el player center
                
                if ( success )
                    [weakSelf _wantsEventListDisplay];
                
                weakSelf.alertView = nil;
            }];
            
            [_alertView show];
        }
        
        NSString *fullSoundUrl = [holder fullSoundUrlTextForEvent];
        BOOL shouldPlay = (fullSoundUrl.length>0);
        if ( shouldPlay )
        {
            SWPlayerCenter *playerCenter = [SWPlayerCenter defaultCenter];
            [playerCenter playSoundTextUrl:fullSoundUrl labelText:newEvent.labelText];
            [playerCenter setVisible:!shouldAlert];
        }
    }
}

- (void)eventsAddSystemEvent:(SWEvent*)event
//- (void)eventsAddSystemEventWithLabel:(NSString *)label comment:(NSString*)comment
{
    //SWEvent *event = [[SWEvent alloc] initWithLabel:label comment:comment active:NO];
    
    [_events insertObject:event atIndex:0];
    _mostRecentEvent = event;
    _numberOfUnacknowledgedEvents += 1;
    
    [self _prepareAlarmNodesChange];
}


- (void)eventsAcknowledgeEvents
{
    _numberOfUnacknowledgedEvents = 0;
    NSMutableIndexSet *removalIndexes = nil;
    NSUInteger count = _events.count;
    
    for (NSUInteger i=0; i<count; i++)
    {
        SWEvent *alrm = [_events objectAtIndex:i];
        if (alrm.active)
        {
            if ( !alrm.acknowledged )
                _numberOfUnacknowledgedActiveEvents -= 1;
            
            alrm.acknowledged = YES;
        }
        else
        {
            if (removalIndexes == nil)
                removalIndexes = [[NSMutableIndexSet alloc] init];
            
            [removalIndexes addIndex:i];
        }
    }
    
    if (removalIndexes)
        [_events removeObjectsAtIndexes:removalIndexes];
    
    if (count)
        [self _prepareAlarmNodesChange];
}


- (NSString*)eventsMostRecentEventDescription
{
    NSString *descr = @"";
    if (_mostRecentEvent)
    {
        NSString *label = _mostRecentEvent.labelText;
        NSString *comment = _mostRecentEvent.commentText;
        descr = [NSString stringWithFormat:@"%@: %@", label, comment];
    }
    return descr;
}


- (NSString*)alarmNodesTotalActiveAlarmsDescription
{
    NSString *descr = @"";
    if (_numberOfActiveEvents > 0)
    {
        descr = [NSString stringWithFormat:NSLocalizedString( @"%dTotalActiveText", nil ), _numberOfActiveEvents];
    }
    return descr;
}

#pragma mark Private Methods

- (SWEvent *)_eventsAddNewEventForHolder:(id<SWEventHolder>)holder
{
    SWEvent *alrm = [[SWEvent alloc] initWithHolder:holder];
    
    [_events insertObject:alrm atIndex:0];
    _mostRecentEvent = alrm;
    _numberOfActiveEvents += 1;
    _numberOfUnacknowledgedEvents += 1;
    _numberOfUnacknowledgedActiveEvents += 1;
    
    [self _prepareAlarmNodesChange];
    return alrm;
}


- (void)_eventsRemoveEventsForHolder:(id<SWEventHolder>)holder
{
    BOOL needsCommit = NO;
    NSMutableIndexSet *removalIndexes = nil;
    NSUInteger count = _events.count;
    
    for (NSUInteger i=0; i<count; i++)
    {
        SWEvent *event = [_events objectAtIndex:i];
        
        if (holder == event.holder)
        {
            if (event.active)
            {
                if ( !event.acknowledged )
                    _numberOfUnacknowledgedActiveEvents -= 1;
                
                event.active = NO;
                _numberOfActiveEvents -= 1;
                needsCommit = YES;
            }
            
            if (event.acknowledged)
            {
                if (removalIndexes == nil)
                    removalIndexes = [[NSMutableIndexSet alloc] init];
                
                [removalIndexes addIndex:i];
            }
        }
    }
    
    if (removalIndexes)
    {
        [_events removeObjectsAtIndexes:removalIndexes];
        needsCommit = YES;
    }
    
    if (needsCommit)
        [self _prepareAlarmNodesChange];
}


- (void)_commitAlarmNodesChange
{
    for (id<SWEventCenterObserver> observer in _observers)
    {
        if ([observer respondsToSelector:@selector(eventCenterDidChangeEvents:)])
            [observer eventCenterDidChangeEvents:self];
    }
    
    _mostRecentEvent = nil;
}


- (void)_prepareAlarmNodesChange
{
    if (_pendingCommitAlarmNodesChange == NO)
    {
        _pendingCommitAlarmNodesChange = YES;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            @autoreleasepool
            {
                [self _commitAlarmNodesChange];
                _pendingCommitAlarmNodesChange = NO;
            }
        });
    }
}


- (void)_wantsEventListDisplay
{
    NSArray *observersCopy = [_observers copy];
    for (id<SWEventCenterObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(eventCenterWantsEventListDisplay:)])
            [observer eventCenterWantsEventListDisplay:self];
    }
}


@end
