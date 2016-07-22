//
//  SWItemCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItemCell.h"
#import "SWItem.h"

@implementation SWItemCell
@dynamic modelObject;

#pragma mark Overriden Methods

//<<<<<<< HEAD
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
//        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longPressGesutreRecognized:)];
//        [self addGestureRecognizer:recognizer];
    }
    return self;
}

//- (void)updateCell
//{
//    [super updateCell];
//    self.mark = self.modelObject.selected;
//}

//- (void)reloadDetailTextLabel
//{
//    SWItem *item = self.modelObject;
//    self.detailTextLabel.text = [item.class localizedName];
//    [self setNeedsLayout];
//}
//=======
// mmmmm
//- (void)reloadDetailTextLabel
//{
//    SWItem *item = self.modelObject;
//    self.detailTextLabel.text = [item.class localizedName];
//    [self setNeedsLayout];
//}
//>>>>>>> filewrapper

#pragma mark Private Methods

//- (void)_longPressGesutreRecognized:(UILongPressGestureRecognizer*)recognizer
//{
//    if (recognizer.state == UIGestureRecognizerStateBegan)
//    {
//        self.modelObject.selected = !self.modelObject.selected;
//    }
//}

#pragma mark - Protocls

#pragma mark SWItemObserver

//- (void)selectedDidChangeForItem:(SWItem *)item
//{
//    BOOL selected = item.selected;
//    self.mark = selected;
//}

@end
