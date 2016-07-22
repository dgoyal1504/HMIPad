//
//  SWPageCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWPageCell.h"

@implementation SWPageCell

@dynamic modelObject;
@synthesize rightDetailType = _rightDetailType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _rightDetailType = SWPageCellRightDetailTypeValueCount;
    }
    return self;
}
#pragma mark Overriden Methods

// mmmm
//- (void)reloadDetailTextLabel
//{
//    SWPage *page = self.modelObject;
//    self.detailTextLabel.text = page.title.valueAsString;
//    [self setNeedsLayout];
//}

- (void)reloadRightDetailTextLabel
{
    if (_rightDetailType == SWPageCellRightDetailTypeValueCount)
    {
        [super reloadRightDetailTextLabel];
    }
    else if (_rightDetailType == SWPageCellRightDetailTypeItemCount)
    {
        SWPage *page = self.modelObject;
        
        NSMutableString *string = [NSMutableString string];
        
        NSInteger count = page.items.count;
        [string appendFormat:@"%ld ",(long)count];
        [string appendString:count!=1?NSLocalizedString(@"items", nil):NSLocalizedString(@"item", nil)];
        self.rightDetailTextLabel.text = string;
        [self setNeedsLayout];
    }
}

#pragma mark Page Observer

- (void)page:(SWPage *)page didInsertItemsAtIndexes:(NSIndexSet *)indexes isGrouping:(BOOL)isGrouping
{
    if (_rightDetailType == SWPageCellRightDetailTypeItemCount)
        [self reloadRightDetailTextLabel];
}

- (void)page:(SWPage *)page didRemoveItemsAtIndexes:(NSIndexSet *)indexes isGrouping:(BOOL)isGrouping
{
    if (_rightDetailType == SWPageCellRightDetailTypeItemCount)
        [self reloadRightDetailTextLabel];
}

#pragma mark Overrides

// mmmm
//- (void)didStartObservation
//{
//    [super didStartObservation];
//    SWPage *page = self.modelObject;
//    [page.title addObserver:self];
//}
//
//- (void)didEndObservation
//{
//    [super didEndObservation];
//    SWPage *page = self.modelObject;
//    [page.title removeObserver:self];
//}
//
//#pragma mark ValueObserver
//
//- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
//{
//    SWPage *page = self.modelObject;
//    if (value == page.title)
//        [self reloadDetailTextLabel];
//    else
//        [super value:value didEvaluateWithChange:changed];
//}

@end
