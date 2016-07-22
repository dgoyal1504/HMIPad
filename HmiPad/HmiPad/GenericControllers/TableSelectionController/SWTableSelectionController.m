//
//  SWTableSelectionController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/22/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWTableSelectionController.h"
#import "SWColor.h"


@implementation SWTableSelectionController

@synthesize swoptions = _swoptions;
@synthesize delegate = _delegate;
@synthesize swselectedOptionIndex = _swselectedOptionIndex;

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithStyle:style options:[NSArray array]];
}

- (id)initWithStyle:(UITableViewStyle)style options:(NSArray*)options
{
    self = [super initWithStyle:style];
    if (self) {
        _swoptions = options;
        _swselectedOptionIndex = NSNotFound;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UITableView *table = self.tableView;
    //[table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [table setSeparatorInset:UIEdgeInsetsZero];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setSelectedOptionIndex:_swselectedOptionIndex animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self setSelectedOptionIndex:_swselectedOptionIndex animated:animated];   // aixo ha d'estar des-comentat en iOS8 b4
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//	return YES;
//}


- (UIFont*)_defaultFont
{
    UIFont *font;
    if ( IS_IOS7 ) font = [UIFont systemFontOfSize:17];
    else font = [UIFont boldSystemFontOfSize:17];
    return font;
}

- (void)setPreferredContentSizeForViewInPopover
{
    CGSize size = CGSizeMake(200,0);
    UIFont *font = [self _defaultFont];
    
    for ( NSString *option in _swoptions )
    {
        //size.width = fminf(fmaxf([option sizeWithFont:font].width, size.width),320);
        size.width = fmin(fmax([option sizeWithAttributes:@{NSFontAttributeName:font}].width, size.width),320);
        size.width = ceil(size.width);
        size.height = ceil(size.height);
    }

    size.height = 44*_swoptions.count - 1;
    if ( size.height > 290 ) size.height = 290;
    else [self.tableView setScrollEnabled:NO];
    
    //[self setContentSizeForViewInPopover:size];
    [self setPreferredContentSize:size];
}



- (void)setSelectedOptionIndex:(NSInteger)selectedOptionIndex
{
    [self setSelectedOptionIndex:selectedOptionIndex animated:NO];
}


- (void )setSelectedOptionIndex:(NSInteger)selectedOptionIndex animated:(BOOL)animated
{
    _swselectedOptionIndex = selectedOptionIndex;
    
    if ( self.isViewLoaded )
    {
        if ( _swselectedOptionIndex < _swoptions.count )   // inclou NSNotfound
        {
            UITableView *table = self.tableView;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_swselectedOptionIndex inSection:0];
           // [table selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
            
            [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:animated];
        }
        else
        {
          //  [table deselectRowAtIndexPath:[table indexPathForSelectedRow] animated:animated];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _swoptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel *textLabel = cell.textLabel;
        if ( IS_IOS7 )
        {
            UIColor *tintColor = [tableView tintColor];
            textLabel.textColor = tintColor;
            textLabel.highlightedTextColor = [tintColor colorWithAlphaComponent:0.2];
            textLabel.textAlignment = NSTextAlignmentCenter;
        }
        else
        {
            textLabel.textColor = UIColorWithRgb(TextDefaultColor);
        }
        textLabel.font = [self _defaultFont];
    }
    
    NSString *option = [_swoptions objectAtIndex:indexPath.row];
    cell.textLabel.text = option;
    
    if (indexPath.row == _swselectedOptionIndex )
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //cell.selected = YES;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString *option = [_swoptions objectAtIndex:row];
    
    if ( _swselectedOptionIndex < _swoptions.count )  // inclou NSNotFound
    {
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:_swselectedOptionIndex inSection:indexPath.section];
        [tableView cellForRowAtIndexPath:selectedIndexPath].accessoryType = UITableViewCellAccessoryNone;
    }
    
    _swselectedOptionIndex = row;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;

    if ([_delegate respondsToSelector:@selector(tableSelection:didSelectOption:)])
        [_delegate tableSelection:self didSelectOption:option];
    
    if ([_delegate respondsToSelector:@selector(tableSelection:didSelectOptionAtIndex:)])
        [_delegate tableSelection:self didSelectOptionAtIndex:row];
}

@end
