//
//  SWPropertyListTableViewController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/17/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWPropertyListTableViewController.h"

static NSString * const kOptionsKey = @"options";
static NSString * const kOptionsTitleKey = @"title";

@interface SWPropertyListTableViewController ()

@end

@implementation SWPropertyListTableViewController
@dynamic popoverSize;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithPropertyList:nil inBundle:nil style:style];
}

- (id)initWithPropertyList:(NSString*)propertyListFileName inBundle:(NSBundle*)bundle style:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSBundle *_bundle = bundle==nil?[NSBundle mainBundle]:bundle;
        _dictionary = [NSDictionary dictionaryWithContentsOfFile:[_bundle pathForResource:propertyListFileName ofType:@"plist"]];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary style:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _dictionary = dictionary;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

- (CGSize)popoverSize
{
    return CGSizeMake(320, 480);
    
//    CGFloat tableViewSize = 0.0;
//    
//    NSInteger sectionCount = [self numberOfSectionsInTableView:nil];
//    
//    for (NSInteger section=0; section < sectionCount; ++section) {
//        tableViewSize += self.tableView.sectionHeaderHeight;
//        NSInteger rowCount = [self tableView:nil numberOfRowsInSection:section];
//        tableViewSize += self.tableView.rowHeight * rowCount;
//    }
//    
//    CGFloat height = tableViewSize>480?480:tableViewSize;
//    
//    return CGSizeMake(320, height);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{       
    NSArray *rows = [_dictionary valueForKey:kOptionsKey];
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.numberOfLines = 0;
    }
        
    NSArray *rows = [_dictionary objectForKey:kOptionsKey];
    NSDictionary *dic = [rows objectAtIndex:indexPath.row];
    NSInteger optionsCount = [(NSArray*)[dic objectForKey:kOptionsKey] count];
        
    NSString *title = [[rows objectAtIndex:indexPath.row] valueForKey:kOptionsTitleKey];
    cell.textLabel.text = title;
    
    if (optionsCount == 0) {
        Class rowClass = NSClassFromString(title);
        if ([rowClass conformsToProtocol:@protocol(SWPropertyListTableViewDataSource)]) {
            cell.textLabel.text = [rowClass itemName];
            cell.detailTextLabel.text = [rowClass itemDescription];
            cell.imageView.image = [rowClass itemIcon];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *descriptionText = @"";
    
    NSArray *rows = [_dictionary objectForKey:kOptionsKey];
    NSDictionary *dic = [rows objectAtIndex:indexPath.row];
    NSInteger optionsCount = [(NSArray*)[dic objectForKey:kOptionsKey] count];
    
    NSString *title = [[rows objectAtIndex:indexPath.row] valueForKey:kOptionsTitleKey];
    
    if (optionsCount == 0) {
        Class rowClass = NSClassFromString(title);
        if ([rowClass conformsToProtocol:@protocol(SWPropertyListTableViewDataSource)]) {
            descriptionText = [rowClass itemDescription];
        } 
    }else {
        return 44;
    }
    
//    UIFont *cellFont = [UIFont fontWithName:@"Arial" size:15];
//    CGSize constraintSize = CGSizeMake(270.0f, MAXFLOAT);
//    CGSize labelSize = [descriptionText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
//    return labelSize.height + 45;  
    
    return 90;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
    NSArray *rows = [_dictionary objectForKey:kOptionsKey];
    NSDictionary *dic = [rows objectAtIndex:indexPath.row];
    NSInteger optionsCount = [(NSArray*)[dic objectForKey:kOptionsKey] count];
    
    NSString *title = [[rows objectAtIndex:indexPath.row] valueForKey:kOptionsTitleKey];
    
    if (optionsCount == 0) {
        [_delegate propertyListTableViewControllerDelegate:self didSelectOption:title];
    } else {
        SWPropertyListTableViewController *ctrl = [[SWPropertyListTableViewController alloc] initWithDictionary:dic style:self.tableView.style];
        ctrl.title = title;
        ctrl.delegate = _delegate;
        //ctrl.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
        ctrl.preferredContentSize = self.preferredContentSize;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

@end
