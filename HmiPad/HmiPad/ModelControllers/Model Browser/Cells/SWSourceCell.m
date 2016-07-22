//
//  SWSourceCell.m
//  HmiPad
//
//  Created by Joan Martin on 8/21/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSourceCell.h"
#import "SWPlcDevice.h"

#import "SWColor.h"
#import "UIView+DecoratorView.h"


@interface SWSourceCell()<SourceItemObserver>
@end

@implementation SWSourceCell

@dynamic modelObject;
@synthesize rightDetailType = _rightDetailType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _rightDetailType = SWSourceCellRightDetailTypeValueCount;
    }
    return self;
}

#pragma mark Overriden Methods

//- (void)reloadDetailTextLabel
//{
//    self.detailTextLabel.text = self.modelObject.plcDevice->remoteHost;
//    [self setNeedsLayout];
//}

//- (void)reloadRightDetailTextLabel
//{
//    if (_rightDetailType == SWSourceCellRightDetailTypeConnectionStatus)
//    {
//        UIColor *color = nil;
//        NSString *text = nil;
//        
//        if (self.modelObject.plcObjectLinked)
//        {
//            text = self.modelObject.monitorOn?NSLocalizedString(@"Connected",nil):nil;
//            color = self.modelObject.monitorOn?UIColorWithRgb(TheNiceGreenColor):nil;
//        }
//        else if (self.modelObject.plcObjectStarted)
//        {
//            text = self.modelObject.monitorOn?NSLocalizedString(@"Connecting..",nil):nil;
//            color = self.modelObject.monitorOn?UIColorWithRgb(getRgbValueForString(@"Orange")):nil;
//        }
//        else if (self.modelObject.plcObjectIgnited)
//        {
//            text = self.modelObject.monitorOn?NSLocalizedString(@"Starting..",nil):nil;
//            color = self.modelObject.monitorOn?UIColorWithRgb(getRgbValueForString(@"LightBlue")):nil;
//        }
//        else
//        {
//            text = self.modelObject.monitorOn?NSLocalizedString(@"Stopped",nil):nil;
//            color = self.modelObject.monitorOn?UIColorWithRgb(getRgbValueForString(@"DarkRed")):nil;
//        }
//        
//        self.rightDetailTextLabel.text = text;
//        self.rightDetailTintColor = color;
//    }
//    else if (_rightDetailType == SWSourceCellRightDetailTypeValueCount)
//    {
//        self.rightDetailTextLabel.text = [NSString stringWithFormat:@"%d tags",self.modelObject.sourceNodes.count];
//    }
//    
//    [self setNeedsLayout];
//}


- (void)reloadRightDetailTextLabel
{
    if (_rightDetailType == SWSourceCellRightDetailTypeConnectionStatus)
    {
        // [super reloadRightDetailTextLabel];                                      // ATENCIO: Descomentar això quan hi hagi properties de veritat
        self.rightDetailTextLabel.text = NSLocalizedString(@"", nil);     // ATENCIO: Treure això quan hi hagi properties de veritat
        
        SWSourceItem *sourceItem = self.modelObject;
        ItemDecorationType decorationType = sourceItem.decorationType;
        
        UIView *accessoryView = [UIView decoratedViewWithFrame:CGRectMake(0,0,12,12) forSourceItemDecoration:decorationType animated:YES];
        [self setAccessoryView:accessoryView];
    }
    else if (_rightDetailType == SWSourceCellRightDetailTypeValueCount)
    {
        self.rightDetailTextLabel.text = [NSString stringWithFormat:@"%lu tags",(unsigned long)self.modelObject.sourceNodes.count];
    }
    
    [self setNeedsLayout];
}


- (void)reloadDetailTextLabel
{
    [super reloadDetailTextLabel];
    
    SWSourceItem *sourceItem = self.modelObject;
    NSString *protocolString = [sourceItem.plcDevice protocolAsString];
    
    UILabel *label = self.detailTextLabel;
    [label setText:[label.text stringByAppendingFormat:@": %@", protocolString]];
}


- (void)didStartObservation
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc addObserver:self selector:@selector(_commsUpdate:) name:kFinsStateDidChangeNotification /*object:nil*/ object:self.modelObject];
}


- (void)didEndObservation
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc removeObserver:self name:kFinsStateDidChangeNotification object:nil];
}

#pragma mark Private Methods

- (void)_commsUpdate:(NSNotification*)notification
{    
    [self reloadRightDetailTextLabel];
}

#pragma mark Source Observer

// TODO: S'ha de fer observació del source por mostrar l'estat d'aquest? o es fa a través de notificacions?

//- (void)plcDeviceDidChange:(SWPlcDevice *)plcDevice
//{
//    NSLog(@"PLC DEVICE DID CHANGE");
//}
//
//- (void)plcTagDidChange:(SWPlcTag *)plcTag atIndex:(NSInteger)indx
//{
//    NSLog(@"PLC TAG DID CHANGE AT INDEX: %d",indx);
//}

#pragma mark ValueObserver

//- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
//{
//    [super value:value didEvaluateWithChange:changed];
//}

@end
