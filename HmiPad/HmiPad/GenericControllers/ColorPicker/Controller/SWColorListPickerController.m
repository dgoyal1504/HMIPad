//
//  SWColorListPickerController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/25/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWColorListPickerController.h"
#import "SWTableSectionHeaderView.h"
#import "SWColor.h"
#import "Drawing.h"

@interface SWColorListPickerController ()

@end

@implementation SWColorListPickerController

@synthesize color = _color;
@synthesize delegate = _delegate;
@synthesize colorPicker = _colorPicker;

//- (id)initWithStyleV:(UITableViewStyle)style andColor:(UIColor*)color
//{
//    self = [super initWithStyle:style];
//    if (self)
//    {
//        if (color) 
//            _color = color;
//        else
//            _color = [UIColor colorWithRed:(arc4random()%100)/100.0f 
//                                     green:(arc4random()%100)/100.0f
//                                      blue:(arc4random()%100)/100.0f
//                                     alpha:1.0];
//        
//        NSArray *sortedColors = [getAllColorStr() sortedArrayUsingSelector:@selector(compare:)];
//        
//        NSMutableDictionary *arraysByLetter = [NSMutableDictionary dictionary];
//        for (NSString *value in sortedColors) 
//        {
//            NSString *firstLetter = [[value substringWithRange:NSMakeRange(0, 1)] uppercaseString];
//            NSMutableArray *arrayForLetter = [arraysByLetter objectForKey:firstLetter];
//            if (arrayForLetter == nil) 
//            {
//                arrayForLetter = [NSMutableArray array];
//                [arraysByLetter setObject:arrayForLetter forKey:firstLetter];
//            }    
//            [arrayForLetter addObject:value];
//        }
//        
//        
//        _titles = [arraysByLetter.allKeys sortedArrayUsingSelector:@selector(compare:)];
//        NSMutableArray *colors = [NSMutableArray array];
//        
//        for (NSString *title in _titles) {
//            [colors addObject:[arraysByLetter objectForKey:title]];
//        }
//        _colors = [colors copy];
//    }
//    return self;
//}



- (id)initWithStyle:(UITableViewStyle)style andColor:(UIColor*)color
{
    self = [super initWithStyle:style];
    if (self)
    {
        if (color) 
            _color = color;
        else
            _color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        NSArray *sortedColors = [getAllColorStr() sortedArrayUsingSelector:@selector(compare:)];
        
        NSMutableArray *colors = [NSMutableArray array];
        NSMutableArray *titles = [NSMutableArray array];
        
        NSMutableArray *arrayForLetter = nil;
        NSString *currentFirstLetter = nil;
        
        for (NSString *value in sortedColors) 
        {
            NSString *firstLetter = [[value substringWithRange:NSMakeRange(0, 1)] uppercaseString];
            
            if ( ![currentFirstLetter isEqualToString:firstLetter] )
            {
                currentFirstLetter = firstLetter;
                arrayForLetter = [NSMutableArray array];
                [titles addObject:currentFirstLetter];
                [colors addObject:arrayForLetter];
            }
            [arrayForLetter addObject:value];
        }
        
        _titles = [titles copy];
        _colors = [colors copy];
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self setColor:_color];
    
    self.tableView.rowHeight = 40;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
//    return YES;
//}

#pragma mark Properties

- (void)setColor:(UIColor *)color
{
    _color = color;
    
//    NSString *str = getColorStrForRgbValue(rgbColorForUIcolor(_color));
//    NSIndexPath *indexPath = [self indexForColorString:str];
    
    NSIndexPath *indexPath = [self indexPathForColor:_color];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

#pragma mark Private Methods

- (NSIndexPath*)indexForColorString:(NSString*)colorString
{    
    NSString *firstLetter = [[colorString substringWithRange:NSMakeRange(0, 1)] uppercaseString];
    NSInteger section = [_titles indexOfObject:firstLetter];
    
    if (section == NSNotFound)
        return nil;
    
    NSArray *array = [_colors objectAtIndex:section];
    NSString *str2 = [colorString lowercaseString];
    
    NSInteger row = 0;
    for (NSString *string in array) 
    {
        NSString *str1 = [string lowercaseString];
        if ([str1 isEqualToString:str2]) 
        {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:section];
            return ip;
        }
        ++row;
    }
    return nil;
}

- (NSIndexPath*)indexPathForColor:(UIColor*)color
{
    NSString *colorStr = getColorStrForRgbValue(rgbColorForUIcolor(color));
    return [self indexForColorString:colorStr];
}

#pragma mark Protocol UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray*)[_colors objectAtIndex:section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if ( IS_IOS7 )
        {
            //cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
            cell.textLabel.font = [UIFont systemFontOfSize:17];;
        }
        else
        {
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17];

            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            UIColor *color = UIColorWithRgb(getRgbValueForString(@"lightblue"));
            view.backgroundColor = color;
            [cell setSelectedBackgroundView:view];
        }
        
        cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    }
    
    NSString *colorStr = [[_colors objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = colorStr;
    
    CGFloat side = tableView.rowHeight;
    UIImage *image = glossyImageWithSizeAndColor(CGSizeMake(side, side), [UIColorWithRgb(getRgbValueForString(colorStr)) CGColor], NO, NO, 0, 2);
    cell.imageView.image = image;
    
    return cell;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SWTableSectionHeaderView *header = [[SWTableSectionHeaderView alloc] init];
    header.title = [_titles objectAtIndex:section];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _titles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

#pragma mark Protocol UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSString *colorStr = [[_colors objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UInt32 rgbValue = getRgbValueForString(colorStr);
    UIColor *color = UIColorWithRgb(rgbValue);
    
    _color = color;
    
    [_colorPicker setColor:color];
    
    if ([_delegate respondsToSelector:@selector(colorPicker:didPickColor:)])
        [_delegate colorPicker:self didPickColor:_color];   
}

@end
