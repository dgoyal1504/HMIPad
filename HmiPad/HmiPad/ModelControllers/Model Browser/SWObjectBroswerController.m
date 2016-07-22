//
//  SWItemBroswerController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWObjectBroswerController.h"
#import "SWObject.h"

#import "SWObjectDescription.h"
#import "SWPropertyDescriptor.h"

#import "SWTableViewMessage.h"

#import "SWTableSectionHeaderView.h"
#import "SWValueViewerCell.h"

#import "SWModelManager.h"
#import "SWNavBarTitleView.h"

#import "SWColor.h"
#import "Drawing.h"

static NSString *ValueViewerCellIdentifier = @"ValueViewerCell";


@implementation SWObjectBroswerController
{
    SWNavBarTitleView *_titleView;
    SWModelManager *_modelManager;
}

#pragma mark protocol SWModelBrowserViewController

//@synthesize browsingStyle = _browsingStyle;
//@synthesize delegate = _delegate;
@synthesize identifiyingObject = _identifiyingObject;

- (id)initWithObject:(id)object classIdentifierObject:(id)identifyingObject
{
    NSAssert( [object isKindOfClass:[SWObject class]], @"objecte erroni per controlador" );
    self = [self initWithModelObject:object];
    if ( self )
    {
        _identifiyingObject = identifyingObject;
    }
    return self;
}

- (id)identifiyingObject
{
    return _identifiyingObject;
}

#pragma mark controller lifecycle

@synthesize modelObject = _modelObject;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _browsingStyle = SWModelBrowsingStyleManagement;  // sempre hauria de ser SWModelBrowsingStyleSeeker, ho canvia el model manager
    }
    return self;
}

- (id)initWithModelObject:(SWObject*)modelObject
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _modelObject = modelObject;
        if ( _identifiyingObject == nil ) _identifiyingObject = modelObject;
        _modelManager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_modelObject.docModel];
        _browsingStyle = SWModelBrowsingStyleManagement;
        
        self.title = _modelObject.identifier;
        _titleView = [[SWNavBarTitleView alloc] init];
        _titleView.secondaryLabel.text = NSLocalizedString(@"Object Properties", nil);
        _titleView.mainLabel.text = self.title;
        [_titleView sizeToFit];
        self.navigationItem.titleView = _titleView;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.clearsSelectionOnViewWillAppear = NO;
    
    UITableView *table = self.tableView;
        
//    UINib *valueNib = [UINib nibWithNibName:@"SWValueViewerCell" bundle:nil];
//    [table registerNib:valueNib forCellReuseIdentifier:ValueViewerCellIdentifier];
    
    [self setModelObject:_modelObject];
    [self setSelectedValue:_selectedValue animated:NO];
    
    NSString *rightTitle = NSLocalizedString(@"Configure", nil);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStyleBordered
        target:self action:@selector(configuratorButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
//    SWNavBarTitleView *titleView = [[SWNavBarTitleView alloc] init];
//    titleView.secondaryLabel.text = NSLocalizedString(@"Object Properties", nil);
//    titleView.mainLabel.text = self.title;
//    [titleView sizeToFit];
//    self.navigationItem.titleView = titleView;
    
    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
    NSString *message = _browsingStyle == SWModelBrowsingStyleManagement ? @"ObjectBrowserFooter" : @"ObjectBrowserFooter2";
    [messageView setMessage:NSLocalizedString(message, nil)];
    [messageView setEmptyTitle:NSLocalizedString(@"No Entries", nil)];
    
    [table setBackgroundColor:[UIColor colorWithWhite:0.90f alpha:1.0]];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [table setTableFooterView:messageView];
    
    [_modelObject addObjectObserver:self];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( _browsingStyle == SWModelBrowsingStyleSeeker )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(modelManagerDidChangeAcceptedTypesNotification:) name:SWModelManagerDidChangeAcceptedTypesNotification object:nil];
    
        //SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_modelObject.docModel];
        SWValue *value = _modelManager.currentSeekedValue;
        [self setSelectedValue:value];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)modelManagerDidChangeAcceptedTypesNotification:(NSNotification*)note
{
    [self setModelObject:_modelObject];
}

- (void)dealloc
{
    //NSLog(@"DEALLOC %@",[self.class description]);
    
    [_modelObject removeObjectObserver:self];
}

#pragma mark Private Methods

- (SWPropertyDescriptor*)_attributeDescriptionForIndexPath:(NSIndexPath*)indexPath
{
    return [[_sectionDescriptors objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}


//- (void)_setSelectedBackgroundsForCell:(SWValueViewerCell *)cell
//{
//    if ( _browsingStyle == SWModelBrowsingStyleManagement )
//    {
//        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//        UIColor *color = UIColorWithRgb(MultipleSelectionColor);
//        selectionView.backgroundColor = color;
//        
//        [cell setSelectedBackgroundView:selectionView];
//        
//        cell.valuePropertyLabel.highlightedTextColor = cell.valuePropertyLabel.textColor;
//        cell.valueSemanticTypeLabel.highlightedTextColor = cell.valueSemanticTypeLabel.textColor;
//        cell.valueAsStringLabel.highlightedTextColor = cell.valueAsStringLabel.textColor;
//    }
//    
//    else if ( _browsingStyle == SWModelBrowsingStyleSeeker )
//    {
//        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//        //UIColor *color = UIColorWithRgb(MultipleSelectionColor);
//        UIColor *color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];  // white
//        selectionView.backgroundColor = color;
//        
//        [cell setSelectedBackgroundView:selectionView];
//
//        cell.valuePropertyLabel.highlightedTextColor = UIColorWithRgb(TangerineSelectionColor);
//        cell.valueSemanticTypeLabel.highlightedTextColor = cell.valueSemanticTypeLabel.textColor;
//        cell.valueAsStringLabel.highlightedTextColor = cell.valueAsStringLabel.textColor;
//    }
//}




#pragma mark - Properties


//- (void)setModelObjectV:(SWObject*)modelObject
//{
//    _modelObject = modelObject;
//    
//    if (!self.isViewLoaded || _modelObject == nil)
//        return;
//    
//    self.title = _modelObject.identifier;
//    
//    SWObjectDescription *objectDescription = [[_modelObject class] objectDescription];
//    
//    NSInteger sectionCount = objectDescription.depth + 1;
//    
//    _sectionObjects = [NSMutableArray array];
//    _sectionDescriptors = [NSMutableArray array];
//    
//    SWObjectDescription *itemInfo = objectDescription;
//    for (NSInteger i=0; i<sectionCount; ++i) 
//    {
//        //SWObjectDescription *itemInfo = [objectDescription superclassInfoAtLevel:i];
//        NSIndexSet *acceptedTypes = _modelManager.currentAcceptedTypes;
//        if (acceptedTypes != nil) 
//        {
//            NSMutableArray *acceptedValues = [NSMutableArray array];
//            
//            for (SWPropertyDescriptor *descriptor in itemInfo.propertyDescriptions) 
//            {
//                if ([acceptedTypes containsIndex:descriptor.type])
//                    [acceptedValues addObject:descriptor];
//            }
//            
//            if (acceptedValues.count > 0)
//            {
//                [_sectionObjects addObject:itemInfo];
//                [_sectionDescriptors addObject:acceptedValues];
//            }
//            
//        } 
//        else
//        {
//            NSInteger count = itemInfo.propertyDescriptions.count;
//            
//            if (count > 0)
//            {
//                [_sectionObjects addObject:itemInfo];
//                [_sectionDescriptors addObject:itemInfo.propertyDescriptions];
//            }
//        }
//        itemInfo = itemInfo.superClassInfo;
//    }
//    
//    if (self.isViewLoaded)
//        [self.tableView reloadData];
//}




- (void)setModelObject:(SWObject*)modelObject
{
    _modelObject = modelObject;
    
    if (!self.isViewLoaded || _modelObject == nil)
        return;
    
    self.title = _modelObject.identifier;
    
    SWObjectDescription *objectDescription = [[_modelObject class] objectDescription];
    
    NSInteger sectionCount = objectDescription.depth + 1;
    
    _sectionObjects = [NSMutableArray array];
    _sectionDescriptors = [NSMutableArray array];
    
    SWObjectDescription *itemInfo = objectDescription;
    NSIndexSet *acceptedTypes = nil;
    
#define displayAll true

    if ( !displayAll )
        acceptedTypes = _modelManager.currentAcceptedTypes;
    
    for (NSInteger i=0; i<sectionCount; ++i) 
    {
        //SWObjectDescription *itemInfo = [objectDescription superclassInfoAtLevel:i];
        if (acceptedTypes != nil)
        {
            NSMutableArray *acceptedValues = [NSMutableArray array];

            for (SWPropertyDescriptor *descriptor in itemInfo.propertyDescriptions) 
            {
                if ([acceptedTypes containsIndex:descriptor.type])
                    [acceptedValues addObject:descriptor];
            }

            if (acceptedValues.count > 0)
            {
                [_sectionObjects addObject:itemInfo];
                [_sectionDescriptors addObject:acceptedValues];
            }
        }
        else
        {
            NSInteger count = itemInfo.propertyDescriptions.count;
            
            if (count > 0)
            {
                [_sectionObjects addObject:itemInfo];
                [_sectionDescriptors addObject:itemInfo.propertyDescriptions];
            }
        }
        itemInfo = itemInfo.superClassInfo;
    }
    
    if (self.isViewLoaded)
        [self.tableView reloadData];
}


- (void)setSelectedValue:(SWValue *)selectedValue
{
    [self setSelectedValue:selectedValue animated:NO];
}

- (void)setSelectedValue:(SWValue *)selectedValue animated:(BOOL)animated
{

    if (selectedValue == nil || ![_modelObject.properties containsObject:selectedValue])
        return;
    
    _selectedValue = selectedValue;
    
    if (!self.isViewLoaded || _selectedValue == nil)
        return;
    
    SWPropertyDescriptor *descriptor = [_selectedValue valueDescription];
    
    NSIndexPath *indexPath = nil;
    
    NSInteger sectionCount = _sectionDescriptors.count;
    
    for (NSInteger i=0; i<sectionCount; ++i)
    {
        NSArray *rows = [_sectionDescriptors objectAtIndex:i];
        NSInteger row = [rows indexOfObjectIdenticalTo:descriptor];
        
        if (row != NSNotFound)
        {
            indexPath = [NSIndexPath indexPathForRow:row inSection:i];
            break;
        }
    }
    
    [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionMiddle];
}




#pragma mark Protocol ObjectObserver


- (void)willRemoveObject:(SWObject *)object
{
  //  if (_configuringObject == _page)
        [self removeFromContainerController];
}


- (void)identifierDidChangeForObject:(SWObject *)object
{
    if (object == _modelObject )
    {
        self.title = object.identifier;
        _titleView.mainLabel.text = self.title;
        [_titleView sizeToFit];
    }
}


#pragma mark - Configuration Button Action

- (void)configuratorButtonAction:(id)sender
{
    SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_modelObject.docModel];
    //[manager presentModelConfiguratorForObject:_modelObject animated:NO presentingControllerKey:nil];
    [manager presentModelConfiguratorOnControllerWithIdentifier:nil forObject:_modelObject animated:IS_IPHONE];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [_sectionDescriptors objectAtIndex:section];
    return array.count;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{    
//    SWObjectDescription *itemInfo = [_sectionObjects objectAtIndex:section];
//    return itemInfo.propertyDescriptions.count;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    SWValueViewerCell *cell = [tableView dequeueReusableCellWithIdentifier:ValueViewerCellIdentifier];
    
    if ( cell == nil )
    {
        UINib *nib = [UINib nibWithNibName:@"SWValueViewerCell" bundle:nil];
        cell = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        //[self _setSelectedBackgroundsForCell:cell];
        cell.accessory = _browsingStyle==SWModelBrowsingStyleManagement?SWValueCellAccessoryTypeGearIndicator:SWValueCellAccessoryTypeSeekerIndicator;
    }
    
    SWPropertyDescriptor *descriptor = [self _attributeDescriptionForIndexPath:indexPath];
    SWValue *value = [_modelObject valueWithSymbol:_modelObject.identifier property:descriptor.name];
    
    cell.value = value;
    
    NSIndexSet *acceptedTypes = _modelManager.currentAcceptedTypes;
    BOOL accepted = [acceptedTypes containsIndex:descriptor.type];
    cell.valuePropertyLabel.enabled = accepted;
    cell.valueAsStringLabel.enabled = accepted;
    //cell.selectionStyle = accepted?UITableViewCellSelectionStyleGray:UITableViewCellSelectionStyleNone;
        
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}




#define HIDE_SECTION_TITLES 1

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#if HIDE_SECTION_TITLES
    return nil;
#else
    SWObjectDescription *descriptor = [_sectionObjects objectAtIndex:section];
    SWTableSectionHeaderView *header = [[SWTableSectionHeaderView alloc] init];
    header.title = descriptor.localizedName;
    return header;
#endif
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
#if HIDE_SECTION_TITLES
    return 0;
#else
    return 30;
#endif
}


- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWPropertyDescriptor *descriptor = [self _attributeDescriptionForIndexPath:indexPath];
    NSIndexSet *acceptedTypes = _modelManager.currentAcceptedTypes;
    BOOL accepted = [acceptedTypes containsIndex:descriptor.type];
    if ( !accepted ) return nil;
    return indexPath;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:0.96f alpha:1.0f]];
    
    [(SWValueCell*)cell beginObservingModel];
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(SWValueCell*)cell endObservingModel];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWPropertyDescriptor *descriptor = [self _attributeDescriptionForIndexPath:indexPath];
    SWValue *value = [_modelObject valueWithSymbol:_modelObject.identifier property:descriptor.name];
    
    if ([_delegate respondsToSelector:@selector(modelBrowser:didSelectValue:)])
        [_delegate modelBrowser:self didSelectValue:value];
}

@end
