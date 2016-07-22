//
//  SWValueCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueCell.h"
#import "SWModelTypes.h"
#import "SWPropertyDescriptor.h"

#import "SWColor.h"
#import "Drawing.h"
#import <QuartzCore/QuartzCore.h>

//#import "SWBackgroundViewCell.h"

#pragma mark - SWValueCell Class


NSString *SWValueNoEditableCellIdentifier = @"ValueNoEditableCellIdentifier";
NSString *SWValueNoEditableCellNibName = @"SWValueCell";

@implementation SWValueCell

@synthesize value = _value;

//@synthesize delegate = _delegate;   // DDDD
@synthesize valuePropertyLabel = _valuePropertyLabel;
@synthesize valueAsStringLabel = _valueAsStringLabel;

#pragma mark Initializers

- (void)doInit
{
    if ( IS_IOS7 )
    {
        [_valuePropertyLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [_valueSemanticTypeLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        [_valueAsStringLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [_valueAsStringLabel setTextColor:UIColorWithRgb(TextDefaultColorFixed)];
    }
    else
    {
        [_valueAsStringLabel setTextColor:UIColorWithRgb(TextDefaultColor)];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    [self doInit];
}

#pragma mark Properties

- (void)setValue:(SWValue *)value
{

    //NSAssert( self.superview == nil, @"Esta prohibit cridar setValue si ja estem en un view!" );
    // ^ Increible, en iOS6 resulta que la celda ja esta ficada en el tableview avans de tornar de cellForRowAtIndexPath, per tant hem de comentar aquest assert
    
    _value = value;
    
    [self refreshAll];
}

#pragma mark Overriden Methods 



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
        self.valuePropertyLabel.shadowColor = shadowColor;
    }
}



- (void)dealloc
{
    //NSLog( @"SWValueCell dealloc" );
}



- (void)layoutSubviewsV
{
    [super layoutSubviews];
    
//_valueAsStringLabel.backgroundColor = [UIColor greenColor];
    
    CGRect rectName = _valuePropertyLabel.frame;
    CGRect rectExpr = _valueAsStringLabel.frame;
    
    //CGSize size = [_valuePropertyLabel.text sizeWithFont:_valuePropertyLabel.font];
    CGSize size = CGSizeZero;
    if ( _valuePropertyLabel )
    {
        size = [_valuePropertyLabel.text sizeWithAttributes:@{NSFontAttributeName:_valuePropertyLabel.font}];
        size.width = ceil(size.width);
        size.height = ceil(size.height);
    }
    rectName.size.width = size.width;
    
    _valuePropertyLabel.frame = rectName;
    
    CGFloat maxAtLeft = rectName.origin.x + size.width;
    rectExpr.size.width = rectExpr.origin.x + rectExpr.size.width - maxAtLeft;
    rectExpr.origin.x = maxAtLeft;
    
//    NSLog(@"-------------------- %@ --------------------", _valuePropertyLabel.text);
//    NSLog(@"CURRENT FRAME: %@", NSStringFromCGRect(_valueAsStringLabel.frame));
//    NSLog(@"COMPUTEDFRAME: %@", NSStringFromCGRect(rectExpr));
    
    _valueAsStringLabel.frame = rectExpr;
}


- (void)layoutSubviewsV2
{
    [super layoutSubviews];
    
//_valueAsStringLabel.backgroundColor = [UIColor greenColor];
    
    CGRect rectName = _valuePropertyLabel.frame;
    CGRect rectType = _valueSemanticTypeLabel.frame;
    
    //CGSize size = [_valueSemanticTypeLabel.text sizeWithFont:_valueSemanticTypeLabel.font];
    CGSize size = CGSizeZero;
    if (_valueSemanticTypeLabel )
    {
        size = [_valueSemanticTypeLabel.text sizeWithAttributes:@{NSFontAttributeName:_valueSemanticTypeLabel.font}];
        size.width = ceil(size.width);
        size.height = ceil(size.height);
    }
    rectType.origin.x += rectType.size.width - size.width;
    rectType.size.width = size.width;
    _valueSemanticTypeLabel.frame = rectType;
    
    const CGFloat gap = 10;
    
    rectName.size.width = rectType.origin.x - rectName.origin.x - gap;
    
//    NSLog(@"-------------------- %@ --------------------", _valuePropertyLabel.text);
//    NSLog(@"CURRENT FRAME: %@", NSStringFromCGRect(_valueAsStringLabel.frame));
//    NSLog(@"COMPUTEDFRAME: %@", NSStringFromCGRect(rectExpr));
    
    _valuePropertyLabel.frame = rectName;
}


- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize contentSize = self.contentView.bounds.size;
    
    [_valuePropertyLabel sizeToFit];
    [_valueSemanticTypeLabel sizeToFit];
    
    CGRect nameRect = _valuePropertyLabel.frame;
    CGRect memoRect = _valueSemanticTypeLabel.frame;
    CGRect exprRect = _valueAsStringLabel.frame;
    
    //CGFloat exprWidth = [_valueAsStringLabel.text sizeWithFont:_valueAsStringLabel.font].width;
    CGFloat exprWidth = 0;
    if ( _valueAsStringLabel )
    {
        exprWidth = [_valueAsStringLabel.text sizeWithAttributes:@{NSFontAttributeName:_valueAsStringLabel.font}].width;
        exprWidth = ceil(exprWidth);
    }
    CGFloat nameRight = nameRect.origin.x+nameRect.size.width;
    CGFloat memoRight = memoRect.origin.x+memoRect.size.width;
    
    const int Gap = 8;
    
    CGFloat maxLeftWidth = fminf( contentSize.width-40, contentSize.width-exprWidth ) ;
    maxLeftWidth = fmaxf( maxLeftWidth, 100 );
    
    if ( nameRight > maxLeftWidth )
    {
        nameRect.size.width = maxLeftWidth;
        _valuePropertyLabel.frame = nameRect;
    }
    if ( memoRight > maxLeftWidth )
    {
        memoRect.size.width = maxLeftWidth;
        _valueSemanticTypeLabel.frame = memoRect;
    }
    
    CGFloat maxAtLeft = Gap + fmaxf( nameRect.origin.x+nameRect.size.width, memoRect.origin.x+memoRect.size.width);
   
    exprRect.size.width = exprRect.origin.x + exprRect.size.width - maxAtLeft;  // el mateix final
    exprRect.origin.x = maxAtLeft;  // nou origen
    
    _valueAsStringLabel.frame = exprRect;
}




- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    //NSLog( @"ValuePropertyLabel will move to superview:%@", _valuePropertyLabel.text);
    
    if (newSuperview == nil)  // woraround al radar 12307048 (https://bugreport.apple.com/cgi-bin/WebObjects/RadarWeb.woa)
    {
        [self endObservingModel];
    }
}




#pragma mark Public Methods

- (void)beginObservingModel
{
    if ( !_isObserving )
    {
        _isObserving = YES;
        //NSLog( @"begin observing cell: %08x", (int)self);
        //NSLog( @"ValuePropertyLabel: add observer %@", _valuePropertyLabel.text);
        [_value addObserver:self];
    }
}

- (void)endObservingModel
{
    if ( _isObserving )
    {
        _isObserving = NO;
        //NSLog( @"end observing cell: %08x", (int)self);
        //NSLog( @"ValuePropertyLabel: remove observer %@", _valuePropertyLabel.text);
        [_value removeObserver:self];
    }
}


- (void)refreshAll
{
    [self refreshValue];
    [self refreshValueName];
    [self refreshSemanticType];
}

- (void)refreshValue
{
    _valueAsStringLabel.text = [_value getValuePrintableString];
    [self setNeedsLayout];
}

- (void)refreshValueName
{
    _valuePropertyLabel.text = _value.property;
    [self setNeedsLayout];
}

- (void)refreshSemanticType
{
    SWPropertyDescriptor *descriptor = _value.valueDescription;
//    _valueSemanticTypeLabel.text = NSLocalizedStringFromSWType(descriptor.type);
    _valueSemanticTypeLabel.text = descriptor.typeAsString;
    [self setNeedsLayout];
}

- (void)setAccessory:(SWValueCellAccessoryType)accessory
{
    switch ( accessory )
    {
        case SWValueCellAccessoryTypeGearIndicator:
        {
            UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            UIColor *color = UIColorWithRgb(MultipleSelectionColor);
            selectionView.backgroundColor = color;
        
            [self setSelectedBackgroundView:selectionView];
        
            _valuePropertyLabel.highlightedTextColor = _valuePropertyLabel.textColor;
            _valueSemanticTypeLabel.highlightedTextColor = _valueSemanticTypeLabel.textColor;
            _valueAsStringLabel.highlightedTextColor = _valueAsStringLabel.textColor;
            break;
        }
    
        case SWValueCellAccessoryTypeNone:
        {
            [self setSelectedBackgroundView:nil];
        
            if ( IS_IOS7 )
            {
                _valuePropertyLabel.highlightedTextColor = _valuePropertyLabel.textColor;
                _valueSemanticTypeLabel.highlightedTextColor = _valueSemanticTypeLabel.textColor;
            }
            else
            {
                _valuePropertyLabel.highlightedTextColor = [UIColor whiteColor];
                _valueSemanticTypeLabel.highlightedTextColor = [UIColor whiteColor];
            }
            break;
        }
        
        case SWValueCellAccessoryTypeSeekerIndicator:
        {
            UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            UIColor *color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
            selectionView.backgroundColor = color;
        
            [self setSelectedBackgroundView:selectionView];

            _valuePropertyLabel.highlightedTextColor = UIColorWithRgb(TangerineSelectionColor);
            _valueSemanticTypeLabel.highlightedTextColor = _valueSemanticTypeLabel.textColor;
            _valueAsStringLabel.highlightedTextColor = _valueAsStringLabel.textColor;
            break;
        }
    }
}


#pragma mark Protocol ValueObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    [self refreshValue];
}

- (void)valueDidChangeName:(SWValue *)value
{
    [self refreshValueName];
}

@end
