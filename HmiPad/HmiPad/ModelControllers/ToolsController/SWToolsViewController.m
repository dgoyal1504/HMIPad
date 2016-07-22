//
//  SWToolsViewController.m
//  HmiPad
//
//  Created by Joan on 24/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWToolsViewController.h"
#import "ControlViewCell.h"
#import "SWDocumentModel.h"


#import "SWTableSelectionController.h"
#import "FPPopoverController.h"



@class ButtonViewCell;

@protocol ButtonViewCellDelegate<NSObject>

- (void)buttonViewCell:(ButtonViewCell*)buttonViewCell didSelectOption:(NSInteger)option;

@end


@interface ButtonViewCell : ControlViewCell

@property (nonatomic,weak) id<ButtonViewCellDelegate>delegate;
@property (nonatomic) NSArray *options;
@property (nonatomic) NSInteger choice;

@end


@interface ButtonViewCell()<SWTableSelectionControllerDelegate,FPPopoverControllerDelegate,UIPopoverControllerDelegate>
{
    UIButton *_button;
    FPPopoverController *_fpPopover;
    UIPopoverController *_popover;
}
@end

@implementation ButtonViewCell

- (id)initWithReuseIdentifier:(NSString *)identifier
{
    self = [super initWithReuseIdentifier:identifier];
    if ( self )
    {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button setFrame:CGRectMake(0, 0, 120, 40)];
        [_button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_button.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self setRightView:_button];
    }
    return self;
}

- (void)setChoice:(NSInteger)choice
{
    NSString *option = nil;
    if ( choice >= 0 && choice < _options.count )
    {
        _choice = choice;
        option = _options[choice];
    }
    [_button setTitle:option forState:UIControlStateNormal];
}

- (void)setOptions:(NSArray *)options
{
    _options = options;
    [self setChoice:_choice];
}

- (void)buttonAction:(id)sender
{
    
    SWTableSelectionController *tsc = [[SWTableSelectionController alloc] initWithStyle:UITableViewStylePlain options:_options];
    [tsc.tableView setScrollEnabled:NO];
    
    tsc.preferredContentSize = CGSizeMake(200,_options.count*44-1);
    tsc.delegate = self;
    tsc.swselectedOptionIndex = _choice;
    
    if ( IS_IPHONE )
    {
        _fpPopover = [[FPPopoverController alloc] initWithViewController:tsc];
        _fpPopover.border = NO;
        _fpPopover.tint = FPPopoverWhiteTint;
        _fpPopover.delegate = self;
        [_fpPopover presentPopoverFromView:_button];
    }
    else
    {
        _popover = [[UIPopoverController alloc] initWithContentViewController:tsc];
        _popover.delegate = self;
        [_popover presentPopoverFromRect:_button.bounds inView:_button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark SWTableSelectionControllerDelegate

- (void)tableSelection:(SWTableSelectionController *)controller didSelectOption:(NSString *)option
{
    [_button setTitle:option forState:UIControlStateNormal];
}

- (void)tableSelection:(SWTableSelectionController *)controller didSelectOptionAtIndex:(NSInteger)index
{
    [_popover dismissPopoverAnimated:YES];
    [_fpPopover dismissPopoverAnimated:YES];
    
    _choice = index;
    if ( [_delegate respondsToSelector:@selector(buttonViewCell:didSelectOption:)] )
        [_delegate buttonViewCell:self didSelectOption:index];
}

#pragma mark popover

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popover = nil;
    _fpPopover = nil;
}

@end



@interface SWToolsViewController ()<DocumentModelObserver,ButtonViewCellDelegate>

@end

@implementation SWToolsViewController
{
    SwitchViewCell *_cellMultipleSelection;
    SwitchViewCell *_cellAutoAlignment;
    SwitchViewCell *_cellFrameEdition;
    SwitchViewCell *_cellFineFramePositioning;
    SwitchViewCell *_cellErrorFrame;
    SwitchViewCell *_cellShowHiddenItems;
    
    ButtonViewCell *_cellInterfaceIdiom;
    
    SWDocumentModel *_docModel;
}



enum rowsInMainSection
{
    kRowMultipleSelection = 0,
    kRowAutoAlignment,
    kRowFrameEdition,
    kRowFineFramePositioning,
    kRowShowErrorFrame,
    kRowShowHiddenItems,
    kRowInterfaceIdiom,
    kTotalRowsInMainSection
};



- (id)initWithDocument:(SWDocumentModel*)documentModel;
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _docModel = documentModel;
    }
    return self;
}


- (void)loadView
{
    [super loadView];
    _cellMultipleSelection = [[SwitchViewCell alloc] initWithReuseIdentifier:nil];
    _cellAutoAlignment = [[SwitchViewCell alloc] initWithReuseIdentifier:nil];
    _cellFrameEdition = [[SwitchViewCell alloc] initWithReuseIdentifier:nil];
    _cellFineFramePositioning = [[SwitchViewCell alloc] initWithReuseIdentifier:nil];
    _cellErrorFrame = [[SwitchViewCell alloc] initWithReuseIdentifier:nil];
    _cellShowHiddenItems = [[SwitchViewCell alloc] initWithReuseIdentifier:nil];
    _cellInterfaceIdiom = [[ButtonViewCell alloc] initWithReuseIdentifier:nil];
    
    [_cellMultipleSelection.switchv addTarget:self action:@selector(_actionSwitch:) forControlEvents:UIControlEventValueChanged];
    [_cellAutoAlignment.switchv addTarget:self action:@selector(_actionSwitch:) forControlEvents:UIControlEventValueChanged];
    [_cellFrameEdition.switchv addTarget:self action:@selector(_actionSwitch:) forControlEvents:UIControlEventValueChanged];
    [_cellFineFramePositioning.switchv addTarget:self action:@selector(_actionSwitch:) forControlEvents:UIControlEventValueChanged];
    [_cellErrorFrame.switchv addTarget:self action:@selector(_actionSwitch:) forControlEvents:UIControlEventValueChanged];
    [_cellShowHiddenItems.switchv addTarget:self action:@selector(_actionSwitch:) forControlEvents:UIControlEventValueChanged];
    [_cellInterfaceIdiom setDelegate:self];
    
    _cellMultipleSelection.mainText = NSLocalizedString(@"Allow Multiple Selection", nil);
    _cellAutoAlignment.mainText = NSLocalizedString(@"Enable Auto Align Rulers", nil);
    _cellFrameEdition.mainText = NSLocalizedString(@"Allow Frame Edition", nil);
    _cellFineFramePositioning.mainText = NSLocalizedString(@"Enable Fine Frame Positioning", nil);
    _cellErrorFrame.mainText = NSLocalizedString(@"Error Frames When Editing", nil);
    _cellShowHiddenItems.mainText = NSLocalizedString(@"Display Hidden Items", nil);
    _cellInterfaceIdiom.mainText = NSLocalizedString(@"Interface Idiom", nil);
    
    UITableView *table = self.tableView;
    [table setScrollEnabled:IS_IPHONE];
    CGFloat tableHeight = kTotalRowsInMainSection * table.rowHeight;
    CGSize popoverSize = CGSizeMake(320, tableHeight);
    //[self setContentSizeForViewInPopover:popoverSize];
    [self setPreferredContentSize:popoverSize];
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [_docModel addObserver:self];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [_docModel removeObserver:self];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kTotalRowsInMainSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    ControlViewCell *cell = nil;
    
    NSInteger row = [indexPath row];
    switch ( row )
    {
        case kRowMultipleSelection:
            cell = _cellMultipleSelection;
            [_cellMultipleSelection.switchv setOn:_docModel.allowsMultipleSelection];
            break;
            
        case kRowFrameEdition:
            cell = _cellFrameEdition;
            [_cellFrameEdition.switchv setOn:_docModel.allowFrameEditing];
            break;
            
        case kRowFineFramePositioning:
            cell = _cellFineFramePositioning;
            [_cellFineFramePositioning.switchv setOn:_docModel.enableFineFramePositioning];
            break;
            
        case kRowShowErrorFrame:
            cell = _cellErrorFrame;
            [_cellErrorFrame.switchv setOn:_docModel.showsErrorFrameInEditMode];
            break;
            
        case kRowShowHiddenItems:
            cell = _cellShowHiddenItems;
            [_cellShowHiddenItems.switchv setOn:_docModel.showsHiddenItemsInEditMode];
            break;
            
        case kRowAutoAlignment:
            cell = _cellAutoAlignment;
            [_cellAutoAlignment.switchv setOn:_docModel.autoAlignItems];
            break;
            
        case kRowInterfaceIdiom:
            cell = _cellInterfaceIdiom;
            NSArray *options = localizedNamesArrayForType(SWTypeEnumDeviceInterfaceIdiom);
            [_cellInterfaceIdiom setOptions:options];
            [_cellInterfaceIdiom setChoice:_docModel.interfaceIdiom];
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}



#pragma mark - DocumentModelObserver

- (void)documentModelEditingPropertiesDidChange:(SWDocumentModel*)docModel
{
    [_cellMultipleSelection.switchv setOn:docModel.allowsMultipleSelection animated:YES];
    [_cellAutoAlignment.switchv setOn:docModel.autoAlignItems animated:YES];
    [_cellFrameEdition.switchv setOn:docModel.allowFrameEditing animated:YES];
    [_cellFineFramePositioning.switchv setOn:docModel.enableFineFramePositioning animated:YES];
    [_cellErrorFrame.switchv setOn:docModel.showsErrorFrameInEditMode animated:YES];
    [_cellShowHiddenItems.switchv setOn:docModel.showsHiddenItemsInEditMode animated:YES];
}

- (void)documentModelInterfaceIdiomDidChange:(SWDocumentModel *)docModel
{
    [_cellInterfaceIdiom setChoice:_docModel.interfaceIdiom];
}

#pragma mark - Switch Actions

- (void)_actionSwitch:(UISwitch*)switchv
{
    if ( switchv == _cellMultipleSelection.switchv )
        _docModel.allowsMultipleSelection = switchv.isOn;
    
    else if ( switchv == _cellAutoAlignment.switchv )
        _docModel.autoAlignItems = switchv.isOn;
    
    else if ( switchv == _cellFrameEdition.switchv )
        _docModel.allowFrameEditing = switchv.isOn;
    
    else if ( switchv == _cellFineFramePositioning.switchv )
        _docModel.enableFineFramePositioning = switchv.isOn;
    
    else if ( switchv == _cellErrorFrame.switchv )
        _docModel.showsErrorFrameInEditMode = switchv.isOn;
    
    else if ( switchv == _cellShowHiddenItems.switchv )
        _docModel.showsHiddenItemsInEditMode = switchv.isOn;
    
    if ( [_delegate respondsToSelector:@selector(toolsViewControllerDidChangeSelection:)] )
        [_delegate toolsViewControllerDidChangeSelection:self];
}

#pragma mark - ButtonViewCellDelegate

- (void)buttonViewCell:(ButtonViewCell *)buttonViewCell didSelectOption:(NSInteger)option
{
    if ( buttonViewCell == _cellInterfaceIdiom )
        _docModel.interfaceIdiom = option;
    
    if ( [_delegate respondsToSelector:@selector(toolsViewControllerInterfaceIdiomDidChange:)] )
        [_delegate toolsViewControllerInterfaceIdiomDidChange:self];
}


@end
