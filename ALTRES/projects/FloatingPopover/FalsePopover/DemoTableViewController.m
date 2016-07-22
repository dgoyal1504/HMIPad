//
//  DemoTableViewController.m
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "DemoTableViewController.h"

@implementation DemoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        NSMutableArray *data = [NSMutableArray array];
        for (unichar ch = 'A'; ch <= 'Z'; ch++)  {
            [data addObject:[NSString stringWithFormat:@"%C%C%C", ch, ch, ch]];
        }
        
        _array = [data copy];
    }
    return self;
}
- (void)viewDidLoad 
{
	[super viewDidLoad];
	[self.navigationItem setTitle:@"Demo"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
	return YES;
}

#pragma mark TableViewController DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [_array count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	cell.textLabel.text = [_array objectAtIndex:indexPath.row];

	return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath 
{	
	UIViewController *detailViewController = [[UIViewController alloc] init];
    detailViewController.title = [_array objectAtIndex:indexPath.row];
    detailViewController.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
	[self.navigationController pushViewController:detailViewController animated:YES];
}

@end
