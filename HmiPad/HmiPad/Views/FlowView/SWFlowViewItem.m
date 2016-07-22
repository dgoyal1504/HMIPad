//
//  SWFlowViewItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/8/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWFlowViewItem.h"
#import <QuartzCore/QuartzCore.h>

#import "SWCrossView.h"

@implementation SWFlowViewItem

#pragma mark - Properties

@synthesize contentView = _contentView;
@synthesize editing = _editing;
@synthesize editingStyle = _editingStyle;

@synthesize reuseIdentifier = _reuseIdentifier;

#pragma mark - Initializers

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame reuseIdentifier:nil];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(10, 10);
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        //self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _editing = NO;
        _editingStyle = SWFlowViewItemEditingStyleNone;
        
        _reuseIdentifier = reuseIdentifier;
        
        CGFloat size = 34;
        SWCrossView *crossView = [[SWCrossView alloc] initWithFrame:CGRectMake(-size/2, -size/2, size, size)];
        [self addSubview:crossView];
        [crossView addTarget:self action:@selector(crossButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)crossButtonPushed:(id)sender
{
    NSLog(@"Cross Button Pushed");
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

#pragma mark - Properties Overriding

- (void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    
    if (_contentView.superview)
        [_contentView removeFromSuperview];
        
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _contentView.frame = self.bounds;
    _contentView.clipsToBounds = YES;
    
    [self addSubview:_contentView];
    [self sendSubviewToBack:_contentView];
}

#pragma mark - Main Methods

- (void)prepareForReuse
{
    [self.contentView removeFromSuperview];
    self.contentView = nil;
    
    _editing = NO;
    _editingStyle = SWFlowViewItemEditingStyleNone;
}

- (void)enableUserInteraction
{
    self.contentView.userInteractionEnabled = YES;
}
- (void)disableUserInteraction
{
        self.contentView.userInteractionEnabled = NO;
}

@end
