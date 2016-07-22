//
//  SWAlarmCenter.h
//  HmiPad
//
//  Created by Joan Martin on 8/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "QuickCoder.h"
//#import "SymbolicCoder.h"

#import "SWEventHolder.h"

@class SWAlarm;
@class SWEvent;
@class SWEventCenter;

@protocol SWEventCenterObserver <NSObject>

@optional
- (void)eventCenterDidChangeEvents:(SWEventCenter*)alarmCenter;
- (void)eventCenterWantsEventListDisplay:(SWEventCenter*)alarmCenter;

@end

@interface SWEventCenter : NSObject //<QuickCoding,SymbolicCoding>
{
}

- (void)addObserver:(id<SWEventCenterObserver>)object;
- (void)removeObserver:(id<SWEventCenterObserver>)object;

// Array of presented events. Objects are instances of SWEvent. Contains an ordered collection of presented events.
@property (nonatomic, readwrite, strong) NSMutableArray *events;

// Other properties
@property (nonatomic, readonly) SWEvent *mostRecentEvent;
@property (nonatomic, readonly) NSInteger numberOfActiveEvents;
@property (nonatomic, readonly) NSInteger numberOfUnacknowledgedEvents;
@property (nonatomic, readonly) NSInteger numberOfUnacknowledgedActiveEvents;

// -- Alarm Nodes -- //
- (void)updateEventsForHolder:(id<SWEventHolder>)holder;
- (void)eventsAddSystemEvent:(SWEvent*)event;
//- (void)eventsAddSystemEventWithLabel:(NSString *)label comment:(NSString*)comment;
- (void)eventsAcknowledgeEvents;
- (NSString*)eventsMostRecentEventDescription;

@end
