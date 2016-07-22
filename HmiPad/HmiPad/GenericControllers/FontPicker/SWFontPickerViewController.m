//
//  SWFontPickerViewController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWFontPickerViewController.h"
#import "SWTableSectionHeaderView.h"
#import "SWColor.h"
@interface SWFontPickerViewController ()

@end

@implementation SWFontPickerViewController

@synthesize selectedFontName = _selectedFontName;
@synthesize delegate = _delegate;

- (void)doInit
{
    NSMutableArray *fontNames = [NSMutableArray array];
    _fontFamilyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *familyName in _fontFamilyNames)
    {
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        [fontNames addObject:names];
    }
    _fontList = [fontNames copy];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self setSelectedFontName:_selectedFontName];
    
    self.tableView.rowHeight = 34;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UITableView *table = self.tableView;
    
    [table scrollToRowAtIndexPath:[table indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

- (void)setSelectedFontName:(NSString *)selectedFontName
{
    _selectedFontName = selectedFontName;

    NSIndexPath *indexPath = [self indexPathForFontName:selectedFontName];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

#pragma mark Private Methods

- (NSIndexPath*)indexPathForFontName:(NSString*)fontName
{
    NSInteger section = 0;
    for (NSArray *fonts in _fontList) 
    {
        NSInteger row = 0;
        for (NSString *name in fonts) 
        {
            if ([name isEqualToString:fontName])
                return [NSIndexPath indexPathForRow:row inSection:section];
            
            ++row;
        }
        ++section;
    }
    
    return nil;
}

#pragma mark Protocol TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _fontList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray*)[_fontList objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if ( IS_IOS7 )
        {
        
        }
        else
        {
            cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            UIColor *color = UIColorWithRgb(getRgbValueForString(@"lightblue"));
            view.backgroundColor = color;
            [cell setSelectedBackgroundView:view];
        }
        
    }
    
    NSArray *fontFamilyNames = [_fontList objectAtIndex:indexPath.section];
    NSString *fontName = [fontFamilyNames objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:fontName size:15];
    cell.textLabel.text = fontName;
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SWTableSectionHeaderView *header = [[SWTableSectionHeaderView alloc] initWithHeight:30];
    header.title = [_fontFamilyNames objectAtIndex:section];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *mapping = [NSMutableArray array];
    
    NSInteger index = 0;
    
    for(NSString *section in _fontFamilyNames) 
    {
        NSString *firstLetter = [[section substringToIndex:1] uppercaseString];
        NSString *lastTitle = [titles lastObject];
        
        if (![firstLetter isEqualToString:lastTitle]) 
        {
            [titles addObject:firstLetter];
            [mapping addObject:[NSNumber numberWithInteger:index]];
        }
             
        ++index;
    }
    
    _indexTitles = [mapping copy];
    return [titles copy];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[_indexTitles objectAtIndex:index] integerValue];
}

#pragma mark Protocol TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedFontName = [(NSArray*)[_fontList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [_delegate fontPicker:self didSelectFontName:_selectedFontName];
}

@end
