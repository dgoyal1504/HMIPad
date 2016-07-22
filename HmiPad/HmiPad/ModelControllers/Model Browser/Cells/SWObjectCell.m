//
//  SWObjectCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWObjectCell.h"
#import "SWGroup.h"
#import "SWObjectDescription.h"
#import "SWPropertyDescriptor.h"
#import "SWColor.h"
#import "Drawing.h"

@implementation SWObjectCell
{
    UIImage *_backImage;
}

@synthesize modelObject = _modelObject;
@synthesize acceptedTypes = _acceptedTypes;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
//        // Initialization code
//        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//        UIColor *color = UIColorWithRgb(MultipleSelectionColor);
//        selectionView.backgroundColor = color;
//        
////        UIImageView *selectionView = [[UIImageView alloc] initWithImage:[self _backImage]];
//        
//        [self setSelectedBackgroundView:selectionView];
//        
//        self.textLabel.highlightedTextColor = self.textLabel.textColor;
//        self.detailTextLabel.highlightedTextColor = self.detailTextLabel.textColor;

        _groupDetailType = SWObjectCellGroupDetailTypeItemCount;

        UILabel *textLabel = self.textLabel;
        UILabel *detailTextLabel = self.detailTextLabel;
        
        textLabel.shadowColor = [UIColor whiteColor];
        textLabel.shadowOffset = CGSizeMake(0, 1);
        detailTextLabel.shadowColor = nil;
        detailTextLabel.shadowOffset = CGSizeMake(0, 0);
    }
    return self;
}



//-----------------------------------------------------------------------------
- (UIImage *)_backImage
{
    if ( _backImage == nil )
    {
        CGFloat radius = 1; 
        //UIColor *color = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1] ;   // aqua
        //UIColor *color = [UIColor colorWithRed:0.5 green:0.75 blue:1 alpha:1] ;   // ~= sky
        //UIColor *color = [UIColor colorWithRed:181.0f/255 green:213.0f/255 blue:1 alpha:1] ;   // selected text
        
        //UIColor *color = [UIColor colorWithRed:0.88 green:0.92 blue:0.98 alpha:1] ;   // selected text
        //UIColor *color = [UIColor colorWithRed:0.91 green:0.94 blue:0.98 alpha:1] ;   // selected text
        UIColor *color = UIColorWithRgb(MultipleSelectionColor);
        UIImage *image = glossyImageWithSizeAndColor( CGSizeMake(radius*2+2, 44), [color CGColor], NO, NO, radius, 1 /*2*/ ) ;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, radius+1, 0, radius+1)] ;
        _backImage = image ;
    }
    return _backImage ;
}




#pragma mark Properties

- (void)setModelObject:(SWObject *)modelObject
{
    //NSAssert( self.superview == nil, @"Esta prohibit cridar setValue si ja estem en un view!" );
    
    _modelObject = modelObject;
    [self updateCell];   // <--aqui
}

#pragma mark Overriden Methods

//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//    
//    if (newSuperview == nil) 
//    {
//        [_modelObject removeObjectObserver:self];
//        [self didEndObservation];
//    }
//    else 
//    {
//        [_modelObject addObjectObserver:self];
//        [self didStartObservation];
//    }
//}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil)  // woraround al radar 12307048 (https://bugreport.apple.com/cgi-bin/WebObjects/RadarWeb.woa)
    {
        [self endObservingModel];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self _setupHighlight:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self _setupHighlight:highlighted];
}


- (void)_setupHighlight:(BOOL)highlighted
{
    if ( !self.darkContext )
    {
        UIColor *shadowColor = [UIColor clearColor];
        if ( !highlighted ) shadowColor = [UIColor whiteColor];
        self.textLabel.shadowColor = shadowColor;
    }
}

#pragma mark Public Methods


- (void)beginObservingModel
{
    if ( !_isObserving )
    {
        _isObserving = YES;
        //NSLog( @"begin observing cell: %08x", (int)self);
        [_modelObject addObjectObserver:self];
        [self didStartObservation];
    }
}

- (void)endObservingModel
{
    if ( _isObserving )
    {
        _isObserving = NO;
        //NSLog( @"end observing cell: %08x", (int)self);
        [_modelObject removeObjectObserver:self];
        [self didEndObservation];
    }
}



- (void)updateCell
{
    [self reloadTextLabel];
    [self reloadDetailTextLabel];
    [self reloadRightDetailTextLabel];
}

- (void)reloadTextLabel
{
    self.textLabel.text = _modelObject.identifier;
    [self setNeedsLayout];
}

- (void)reloadDetailTextLabel
{
    // Override in subclasses
    self.detailTextLabel.text = [_modelObject.class localizedName];
    [self setNeedsLayout];
}

- (void)reloadRightDetailTextLabel
{
    NSInteger count = 0;
    NSString *propString = nil;

    if ( _modelObject.isGroupItem && _groupDetailType == SWObjectCellGroupDetailTypeItemCount )
    {
        count = [[(id<SWGroup>)_modelObject items] count];
        propString = count!=1?@"items":@"item";
    }
    else
    {
        count = [self _compatibleValuesCount];
        propString = count!=1?@"properties":@"property";
    }

    NSMutableString *string = [NSMutableString stringWithFormat:@"%ld ",(long)count];
    [string appendString:NSLocalizedString(propString, nil)];
    
    self.rightDetailTextLabel.text = string;
    [self setNeedsLayout];
}

- (void)didStartObservation
{
    // Override in subclasses and call super
}

- (void)didEndObservation
{
    // Override in subclasses and call super
}

#pragma mark Private Methods

//- (NSInteger)_compatibleValuesCount
//{
//    if (_acceptedTypes == nil)
//        return _modelObject.properties.count;
//    
//    SWObjectDescription *objectDescription = [[_modelObject class] objectDescription];
//    
//    NSInteger valueCount = 0;
//    
//    NSInteger sectionCount = objectDescription.depth + 1;
//    
//    for (NSInteger i=0; i<sectionCount; ++i)
//    {
//        SWObjectDescription *itemInfo = [objectDescription superclassInfoAtLevel:i];
//        
//        for (SWPropertyDescriptor *descriptor in itemInfo.propertyDescriptions)
//        {
//            if ([_acceptedTypes containsIndex:descriptor.type])
//                ++valueCount;
//        }
//    }
//    
//    return valueCount;
//}



- (NSInteger)_compatibleValuesCount
{
    if (_acceptedTypes == nil)
        return _modelObject.properties.count;
    
    SWObjectDescription *objectDescription = [[_modelObject class] objectDescription];
    
    NSInteger valueCount = 0;
    
    NSInteger sectionCount = objectDescription.depth + 1;
    
    SWObjectDescription *itemInfo = objectDescription;
    
    for (NSInteger i=0; i<sectionCount; ++i)
    {
        //SWObjectDescription *itemInfo = [objectDescription superclassInfoAtLevel:i];
        
        for (SWPropertyDescriptor *descriptor in itemInfo.propertyDescriptions)
        {
            if ([_acceptedTypes containsIndex:descriptor.type])
                ++valueCount;
        }
        
        itemInfo = itemInfo.superClassInfo;
    }
    
    return valueCount;
}







#pragma mark ObjectObserver

- (void)identifierDidChangeForObject:(SWObject *)object
{
    [self reloadTextLabel];
}

#pragma mark ValueObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    
}

@end
