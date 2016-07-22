//
//  SWSourceTitleCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWSourceTitleCell.h"


@interface SWSourceTitleCell ()

- (void)_sourceItemStatusChanged:(NSNotification*)notification;

@end

@implementation SWSourceTitleCell
@synthesize titleLabel = _titleLabel;

//@synthesize decorationSymbolEnabled = _decorationSymbolEnabled;
//@synthesize format = _format;
@synthesize decorationType = _decorationType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
//        _format = @"%@";
//        _decorationSymbolEnabled = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    _format = @"%@";
//    _decorationSymbolEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Properties

- (void)setDecorationType:(ItemDecorationType)decorationType
{
    UIView *view = [UIView decoratedViewWithFrame:CGRectMake(0, 0, 30, 30) forSourceItemDecoration:decorationType animated:YES];
    self.accessoryView = view;
    self.editingAccessoryView = view; // self.accessoryView;
}


#pragma mark - Overriden Methods

- (void)connectToSourceItem
{
    [self _update];
    [self _sourceItemStatusChanged:nil];
}


- (void)disconnectFromSourceItem
{
    [super disconnectFromSourceItem];
}


- (void)_update
{
    NSString *title = _sourceItem.identifier;
    if (!title) title = NSLocalizedString(@"<Undefined>",nil);
    NSString *format = NSLocalizedString(@"Connector: %@",nil);
    _titleLabel.text = [NSString stringWithFormat:format,title];
}


- (void)startObserving
{
    [super startObserving];
    [_sourceItem addObjectObserver:self];
    
    //if (_decorationSymbolEnabled)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(_sourceItemStatusChanged:) name:kFinsStateDidChangeNotification object:_sourceItem];
    }
}

- (void)stopObserving
{
    [super stopObserving];
    [_sourceItem removeObjectObserver:self];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //[nc removeObserver:self name:nil object:self.sourceItem];
    [nc removeObserver:self];
}

#pragma mark - Main Methods


#pragma mark - Base Item Observer

- (void)identifierDidChangeForObject:(SWObject *)object
{
    [self _update];
}

#pragma mark - Private Methods

- (void)_sourceItemStatusChanged:(NSNotification*)notification
{    
    [self setDecorationType: _sourceItem.decorationType];
}

@end
