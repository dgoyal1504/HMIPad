//
//  SWDocumentStatusView.m
//  HmiPad
//
//  Created by Joan Lluch on 05/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWDocumentStatusView.h"
#import "SWDocumentModel.h"
#import "SWSourceItem.h"
#import "SWEventCenter.h"
#import "UIView+DecoratorView.h"


@interface SWDocumentStatusView() <DocumentModelObserver,SWEventCenterObserver>
{
    BOOL _isObserving;
    BOOL _isTouchInside;
}

@end


@implementation SWDocumentStatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (void)awakeFromNibBO
{
    _imageViewTag.image = [_imageViewTag.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //_imageViewTag.tintColor = [UIColor grayColor];

    _contentView.backgroundColor = [UIColor clearColor];
    CALayer *layer = _contentView.layer;
    //layer.borderColor = [UIColor lightGrayColor].CGColor;
    layer.borderColor = [self tintColor].CGColor;
    layer.borderWidth = 1;
    layer.cornerRadius = 5;
}


- (void)awakeFromNib
{
    _imageViewTag.image = [_imageViewTag.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //_imageViewTag.tintColor = [UIColor grayColor];

    UIImage *alarmImg = [[UIImage imageNamed:@"719-alarm-clock-toolbar-selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imageViewAlarm setImage:alarmImg];
    
    //_contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    _contentView.backgroundColor = [UIColor clearColor];
    
    CALayer *layer = _contentView.layer;
    //layer.borderColor = [UIColor lightGrayColor].CGColor;
    layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    layer.borderWidth = 1;
    layer.cornerRadius = 5;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil)
    {
        [self endObservingModel];
    }
    else
    {
        [self _updateAll];
        [self beginObservingModel];
    }
}


- (void)beginObservingModel
{
    if ( !_isObserving )
    {
        _isObserving = YES;
        //NSLog( @"DocumentStatusView begin observing" );
        [_documentModel addObserver:self];
        [_documentModel.eventCenter addObserver:self];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
        [nc addObserver:self selector:@selector(_commStateChangeNotification:) name:kFinsStateDidChangeNotification object:nil];
       // [nc addObserver:self selector:@selector(_tagCountChangeNotification:) name:kFinsNumberOfTagsDidChangeNotification object:nil];
    }
}


- (void)endObservingModel
{
    if ( _isObserving )
    {
        _isObserving = NO;
        //NSLog( @"DocumentStatusView end observing" );
        [_documentModel removeObserver:self];
        [_documentModel.eventCenter removeObserver:self];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
    }
}


#pragma mark updating


- (void)_updateAll
{
    [self _updateAlarmBadge];
    [self _updateCommunicationsBadge];
//    [self _updateTagsBadge];
}


- (void)_updateAlarmBadge
{
    SWEventCenter *eventCenter = _documentModel.eventCenter;
    NSInteger total = eventCenter.events.count;
    NSInteger unAck = eventCenter.numberOfUnacknowledgedActiveEvents;
    NSInteger active = eventCenter.numberOfActiveEvents;
    NSString *badge = [NSString stringWithFormat:@"%ld/%ld", (long)active, (long)total];
    [_labelAlarm setText:badge];
   
    // NSString *imageName = active>0?(unAck>0?@"alarm20Red.png":@"alarm20DarkRed.png"):@"alarm20.png";
    //[_imageViewAlarm setImage:[UIImage imageNamed:imageName]];
    
    UIColor *color = active>0?(unAck>0?[UIColor redColor]:[UIColor colorWithRed:0.6 green:0 blue:0 alpha:1]):[UIColor lightGrayColor];
    [_imageViewAlarm setTintColor:color];
}




- (void)_updateCommunicationsBadge
{
    enum SWCommStateValues
    {
        kCommStateLinked = 0,
        kCommStateStop = 1,
        kCommStatePartialLink = 2,
        kCommStateError = 3,
    };
    
    NSArray *sourceItems = [_documentModel sourceItems];

    //int commState;
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
    
//    int commRoute;
//    commRoute = kCommRouteNoRemote;
//    if ( totalLocal>0 && totalLinked==totalLocal ) commRoute = kCommRouteAllLocalNoRemote;
//    if ( totalRemote>0 ) commRoute = kCommRouteSomeRemote;
//    if ( totalRemote>0 && totalLinked==totalRemote ) commRoute = kCommRouteAllRemote;
    
    NSInteger total = sourceItems.count;
    NSString *badge = [NSString stringWithFormat:@"%d/%ld", totalLinked, (long)total];
    [_labelConnection setText:badge];
    

//    UIView *tmpImageViewConnection = _imageViewConnection;
//    CGRect frame = tmpImageViewConnection.frame;
//    
//    _imageViewConnection = (id)[UIView decoratedViewWithFrame:frame forSourceItemDecoration:decoration animated:NO];
//    [_imageViewConnection setAlpha:0];
//    [self addSubview:_imageViewConnection];
//    
//    UIView *newImageViewConnection = _imageViewConnection;
//    
//    [UIView animateWithDuration:0.3 animations:^
//    {
//        [tmpImageViewConnection setAlpha:0];
//        [newImageViewConnection setAlpha:1];
//    }
//    completion:^(BOOL finished)
//    {
//        [tmpImageViewConnection removeFromSuperview];
//    }];
    
    CGRect frame = _imageViewConnection.frame;
    [_imageViewConnection removeFromSuperview];
    _imageViewConnection = (id)[UIView decoratedViewWithFrame:frame forSourceItemDecoration:decoration animated:YES];
    [self addSubview:_imageViewConnection];
}


//- (void)_updateTagsBadge
//{
//    int totalTags = 0;
//    int pollingTags = 0;
//    
//    NSArray *sourceItems = [_documentModel sourceItems];
//    for ( SWSourceItem *sourceItem in sourceItems )
//    {
//        totalTags += sourceItem.sourceNodes.count;
//        pollingTags += sourceItem.numberOfTags;
//    }
//
//    NSString *badge = [NSString stringWithFormat:@"%d/%d", pollingTags, totalTags];
//    [_labelTag setText:badge];
//}


#pragma mark StateChangeNotification

- (void)_commStateChangeNotification:(NSNotification*)note
{
    [self _updateCommunicationsBadge];
}

//- (void)_tagCountChangeNotification:(NSNotification*)note
//{
//    [self _updateTagsBadge];
//}

#pragma mark SWEventCenterObserver

- (void)eventCenterDidChangeEvents:(SWEventCenter *)alarmCenter
{
    [self _updateAlarmBadge];
}

#pragma mark SWDocumentObserver

- (void)documentModel:(SWDocumentModel *)docModel didInsertSourceItemsAtIndexes:(NSIndexSet *)indexes
{
    [self _updateCommunicationsBadge];
}

- (void)documentModel:(SWDocumentModel *)docModel didRemoveSourceItemsAtIndexes:(NSIndexSet *)indexes
{
    [self _updateCommunicationsBadge];
}

#pragma mark Private

- (void)_setTouchInside:(BOOL)touchInside
{
    _isTouchInside = touchInside;
    _contentView.backgroundColor = (touchInside?[UIColor colorWithWhite:0 alpha:0.2]:[UIColor clearColor]);
}


#pragma mark Touch


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    _contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    _isTouchInside = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect bounds = self.bounds;
    BOOL touchInside = CGRectContainsPoint( CGRectInset(bounds, -40, -40), point );
    if ( touchInside != _isTouchInside )
    {
        [self _setTouchInside:touchInside];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if ( _isTouchInside )
    {
        [self _setTouchInside:NO];
        if ( [_delegate respondsToSelector:@selector(documentStatusViewDidTouchUp:)] )
            [_delegate documentStatusViewDidTouchUp:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if ( _isTouchInside )
    {
        [self _setTouchInside:NO];
    }
}




@end
