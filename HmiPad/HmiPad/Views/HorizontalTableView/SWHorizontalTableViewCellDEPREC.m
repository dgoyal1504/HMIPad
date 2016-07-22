//
//  SWHorizontalTableViewCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWHorizontalTableViewCell.h"

#import "SWCrossView.h"

#define TOP_PADDING 10
#define LEFT_PADDING 10
#define RIGHT_PADDING 10
#define BOTTOM_PADDING 10

#import "SWHorizontalTableView.h"

@interface SWHorizontalTableView (CellManipulation)

- (void)deleteButtonPushed:(id)sender;

@end


@implementation SWHorizontalTableView (CellManipulation)

- (void)deleteButtonPushed:(id)sender
{
    UIView *superview = sender;
    SWHorizontalTableViewCell *cell = nil;
    
    while (superview != nil) {
        if ([superview isKindOfClass:[SWHorizontalTableViewCell class]]) {
            cell = (SWHorizontalTableViewCell*)superview;
            superview = nil;
        } else {
            superview = superview.superview;
        }
    }
    
    if (cell) {
        NSInteger index = [self indexForCell:cell];        
        
        if ([self.dataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndex:)]) {
            [self.dataSource tableView:self commitEditingStyle:SWHorizontalTableViewCellEditingStyleDelete forRowAtIndex:index];
        }
        
    } else {
        NSLog(@"[udjsiq] Didn't find a cell in the superview chain.");
    }
}

@end

@implementation SWHorizontalTableViewCell

@synthesize style = _style;
@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize selectionStyle = _selectionStyle;
@synthesize selected = _selected;
@synthesize editing = _editing;

@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithStyle:SWHorizontalTableViewCellStyleDefault reuseIdentifier:nil];
}

- (id)initWithStyle:(SWHorizontalTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 100)];
    if (self) {
        
        _style = style;
        _reuseIdentifier = reuseIdentifier;
        _selectionStyle = SWHorizontalTableViewCellSelectionStyleBlue;
        _selected = NO;
        _editing = NO;
        self.userInteractionEnabled = YES;
        
        switch (_style) {
            case SWHorizontalTableViewCellStyleDefault:
                
                _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
                _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                _textLabel.numberOfLines = 0;
                _textLabel.font = [UIFont boldSystemFontOfSize:17];
                
                [self addSubview:_textLabel];
                
                break;
            case SWHorizontalTableViewCellStyleImage:
                
                _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(TOP_PADDING, 
                                                                           LEFT_PADDING, 
                                                                           self.frame.size.width - LEFT_PADDING - RIGHT_PADDING, 
                                                                           self.frame.size.height - TOP_PADDING - BOTTOM_PADDING)];
                _imageView.contentMode = UIViewContentModeScaleAspectFill;
                _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                _imageView.backgroundColor = [UIColor grayColor];
                _imageView.clipsToBounds = YES;
                
                [self addSubview:_imageView];
                
                break;
            default:
                break;
        }
        
        self.backgroundColor = [UIColor redColor];
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

#pragma mark - Properties

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

#pragma mark - Overriden Methods

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (_selected) {
        UIBezierPath *path = nil;
        
        if (_style == SWHorizontalTableViewCellStyleImage) {
            path = [UIBezierPath bezierPathWithRect:self.imageView.frame];
            [[UIColor blueColor] setStroke];
            [path setLineWidth:10];
            [path stroke];
        }
    }
}

- (void)prepareForReuse
{
    self.imageView.image = nil;
    self.textLabel.text = nil;
    [self setSelected:NO animated:NO];
    [self setEditing:NO animated:NO];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // TODO : Animations
    
    _selected = selected;
    
    if (_style == SWHorizontalTableViewCellStyleImage) {
        [self setNeedsDisplay];
        return;
    }
    
    if (_selected) {
        _lastColor = self.backgroundColor;
        
        UIColor *color = nil;
        switch (_selectionStyle) {
            case SWHorizontalTableViewCellSelectionStyleNone:
                color = _lastColor;
                break;
            case SWHorizontalTableViewCellSelectionStyleBlue:
                color = [UIColor blueColor];
                break;
            case SWHorizontalTableViewCellSelectionStyleGray:
                color = [UIColor grayColor];
                break;
            default:
                break;
        }
        
        self.backgroundColor = color;
        
    } else {
        self.backgroundColor = _lastColor;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    _editing = editing;
    
    if (editing) {
        _crossButton = [[SWCrossView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [_crossButton addTarget:self.superview action:@selector(deleteButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_crossButton];
    } else {
        [_crossButton removeFromSuperview];
        _crossButton = nil;
    }
    
}

@end
