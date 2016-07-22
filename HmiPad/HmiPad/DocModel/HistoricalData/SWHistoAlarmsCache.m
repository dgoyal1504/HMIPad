//
//  SWHistoAlarmsCache.m
//  HmiPad
//
//  Created by Joan Lluch on 19/05/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWHistoAlarmsCache.h"

#import "SWEvent.h"
#import "SWHistoAlarmsDatabaseContext.h"

#define MAX_CONTEXTS 5

@interface SWHistoAlarmsCache()
{
    NSArray *_dbContexts;
    NSInteger _numberOfRowss[MAX_CONTEXTS];
}

@end


@implementation SWHistoAlarmsCache
{
    NSString *_searchText;
    NSRange _cachedRanges[MAX_CONTEXTS];
    NSArray *_eventss[MAX_CONTEXTS];
    NSMutableIndexSet *_isWaitingResponses;
    NSMutableIndexSet *_isReloadingDatas;
    NSMutableIndexSet *_hasPendingRequests;
}


- (id)init
{
    self = [super init];
    if ( self )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(_histoAlarmsdidAddEvent:) name:kSWHistoAlarmsDidAddEventNotification object:nil];
        
        _isWaitingResponses = [NSMutableIndexSet indexSet];
        _isReloadingDatas = [NSMutableIndexSet indexSet];
        _hasPendingRequests = [NSMutableIndexSet indexSet];
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    for ( int i=0 ; i<MAX_CONTEXTS ; i++ )   // << suposo que no cal pero per si de cas
        _eventss[i] = nil;
}


- (NSInteger)numberOfSections
{
    NSInteger count = [_dbContexts count];
    return count;
}


- (NSInteger)numberOfRowsForSection:(NSInteger)section
{
    [self _fetchForRange:_cachedRanges[section] forSection:section filterString:_searchText];
    
    // tornem el que tenim per ara
    return _numberOfRowss[section];
}


- (SWEvent*)eventAtRow:(NSInteger)row forSection:(NSInteger)section
{
    SWEvent *event = nil;
    NSInteger index = row-_cachedRanges[section].location;
    if ( index >= 0 && index < _cachedRanges[section].length )
    {
        SWEvent *anEvent = [_eventss[section] objectAtIndex:index];
        if ( (id)anEvent != [NSNull null] )
            event = anEvent;
    }
    else
    {
        const NSInteger length = 40;
        NSInteger beg = row-length/2;
        if ( beg<0 ) beg = 0;
        [self _fetchForRange:NSMakeRange(beg, length) forSection:section filterString:_searchText];
    }

    // tornem el que tenim per ara
    return event;
}


- (void)setSearchText:(NSString*)searchText
{
    _searchText = searchText;
    
    NSInteger count = [_dbContexts count];
    for ( NSInteger i=0 ; i<count ; i++ )
    {
        [self _fetchForRange:NSMakeRange(0, 40) forSection:i filterString:_searchText];
    }
}


- (void)setDbContexts:(NSArray *)dbContexts
{
    NSAssert(dbContexts.count<=MAX_CONTEXTS, @"no tants, si us plau");
    _dbContexts = dbContexts;
}


- (NSArray*)dbContexts
{
    return _dbContexts;
}


#pragma mark - private;

- (void)_fetchForRange:(NSRange)range forSection:(NSInteger)section filterString:(NSString*)filterString
{
    if ( _delegate == nil )
        return;
    
    if ( [_isReloadingDatas count] > 0 )
        return;

    if ( [_isWaitingResponses containsIndex:section] )
    {
        if ( ![_isReloadingDatas containsIndex:section] )
        {
            [_hasPendingRequests addIndex:section];
        }
    }

    else
    {
        [_isWaitingResponses addIndex:section];
        [_dbContexts[section] fetchEventsInRange:range filterString:filterString completion:^(NSArray *events, NSInteger totalRows)
        {
            _cachedRanges[section] = range;
            _cachedRanges[section].length = events.count;
            _eventss[section] = events;
            _numberOfRowss[section] = totalRows;
            
            [_isReloadingDatas addIndex:section];
            [_delegate histoAlarmsCache:self didUpdateSection:section];
            [_isReloadingDatas removeIndex:section];
            [_isWaitingResponses removeIndex:section];
            
            if ( [_hasPendingRequests containsIndex:section] )
            {
                [_hasPendingRequests removeIndex:section];
                [_isReloadingDatas addIndex:section];
                [_delegate histoAlarmsCache:self didUpdateSection:section];
                [_isReloadingDatas removeIndex:section];
            }
        }];
    }
}


#pragma mark - dbcontext notifications

- (void)_histoAlarmsdidAddEvent:(NSNotification *)note
{
    NSInteger section = [_dbContexts indexOfObjectIdenticalTo:[note object]];
    
    if ( section != NSNotFound )
    {
        [self _fetchForRange:_cachedRanges[section] forSection:section filterString:_searchText];
    }
}


@end
