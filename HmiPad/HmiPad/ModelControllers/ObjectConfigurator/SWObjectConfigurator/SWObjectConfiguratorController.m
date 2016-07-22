//
//  SWItemConfigurationController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/27/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWObjectConfiguratorController.h"
#import "SWPropertyDescriptor.h"

#import "SWItemConfiguratorHeader.h"
#import "SWTableViewMessage.h"

//#import "SWIdentifierView.h"

#import "RoundedTextView.h"

#import "SWEnumTypes.h"

// --- Cells --- //
#import "SWValueCell.h"
#import "SWValueTypeEnumCell.h"
#import "SWValueTypeRectCell.h"
#import "SWValueTypeBoolCell.h"
#import "SWExpressionCell.h"
// ------------- //

//#import "SWDocumentController.h"

//#import "SWSegmentController.h"
//#import "SWImagePickerController.h"
//#import "SWColorPickerViewController.h"
//#import "SWColorListPickerController.h"
//#import "SWFontPickerViewController.h"
#import "SWModelBrowserController.h"
#import "SWModelBrowserProtocols.h"

#import "SWIdentifierHeaderView.h"
#import "SWNavBarTitleView.h"

#import "SWTableFieldsController.h"
#import "SWTableFieldsControllerDelegate.h"
#import "SWExpressionInputController.h"

#import "RpnBuilder.h"
#import "SWColor.h"

#import "SWModelManager.h"
#import "SWTableView.h"

//#import "SWKeyboardListener.h"

//#import "SWExpressionCompleter.h"

static NSString * const ControllerNibName = @"SWItemConfigurationController";

//NSString * const SWItemConfigurationControllerDidStartEditingNotification = @"SWItemConfigurationControllerDidStartEditingNotification";
//NSString * const SWItemConfigurationControllerDidEndEditingNotification = @"SWItemConfigurationControllerDidEndEditingNotification";


NSString * const SWItemConfigurationControllerDidChangeNameNotification = @"SWItemConfigurationControllerDidChangeNameNotification";


@interface SWObjectConfiguratorController() <SWTableFieldsControllerDelegate, /*UITextFieldDelegate, RoundedTextViewDelegate,*/ SWObjectObserver, SWExpressionCellDelegate, SWValueTypeEnumCellDelegate,SWModelBrowserDelegate /*, SWExpressionInputControllerDelegate*/>
@end


@interface SWObjectConfiguratorController()
{
//    SWExpressionCompleter *_expressionCompleter;
//    UIPopoverController *_popover;
    //SWTableFieldsController *_rightButton;
    //SWExpressionInputController *_expressionInput;
    NSMutableArray *_sectionObjects;
    SWObjectDescription *_itemInfo;
    //UIBarButtonItem *_rightBarButtonItem;
    SWNavBarTitleView *_titleView;
}
@end

@interface SWObjectConfiguratorController (CustomProtocols) <SWModelManagerDelegate, SWModelManagerDataSource>
@end

@implementation SWObjectConfiguratorController
{
    BOOL _updatingValue;
    //__weak SWModelManager *_modelManager;
}

@synthesize tableView = _tableView;
@synthesize identifierHeaderView = _identifierHeaderView;

- (id)initWithConfiguringObject:(SWObject*)object
{
    self = [super initWithConfiguringObject:object];
    if (self)
    {
        _configuringObject = _configuringObjectInstance;
        _modelManager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_configuringObject.docModel];
        
        self.title = [NSString stringWithFormat:@"%@",object.identifier];
        _titleView = [[SWNavBarTitleView alloc] init];
        _titleView.secondaryLabel.text = NSLocalizedString(@"Object Configurator", nil);
        _titleView.mainLabel.text = self.title;
        [_titleView sizeToFit];
        self.navigationItem.titleView = _titleView;

        _itemInfo = [[_configuringObject class] objectDescription];
        
        NSInteger sectionCount = _itemInfo.depth + 1;
        
        _sectionObjects = [NSMutableArray array];
        SWObjectDescription *itemInfo = _itemInfo;
        for (NSInteger i=0; i<sectionCount; ++i) 
        {
            //SWObjectDescription *itemInfo = [_itemInfo superclassInfoAtLevel:i];
            NSInteger count = itemInfo.propertyDescriptions.count;
            
            if (count > 0)
                [_sectionObjects addObject:itemInfo];
            
            itemInfo = itemInfo.superClassInfo;
        }
        
        RpnBuilder *builder = _configuringObject.builder;
        [builder addGlobalSymbol:nil withHolder:nil];
        
        //self.contentSizeForViewInPopover = CGSizeMake(320, 480);
        self.preferredContentSize = CGSizeMake(320, 480);
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark View lifecycle

// zzz
- (void)loadView
{

//    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,100,100) style:UITableViewStylePlain];
    UITableView *tableView = [[SWTableView alloc] initWithFrame:CGRectMake(0,0,100,100) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    //tableView.delaysContentTouches = NO;
    _tableView = tableView;
    self.view = _tableView;

    NSString *nibName;
    if ( IS_IOS7 ) nibName = @"SWIdentifierHeaderView";
    else nibName = @"SWIdentifierHeaderView6";
    UINib *cellNib = [UINib nibWithNibName:nibName bundle:nil];
    _identifierHeaderView = [[cellNib instantiateWithOwner:self options:nil] objectAtIndex:0];
    [_identifierHeaderView setBackgroundColor:[UIColor colorWithWhite:0.96f alpha:1.0]];
    
    if ( _notEditableName )
    {
        UITextField *textField = _identifierHeaderView.textField;
        textField.enabled = NO;
        CGFloat fontSize = textField.font.pointSize;
        textField.font = [UIFont boldSystemFontOfSize:fontSize];
    }
    
    [_tableView setTableHeaderView:_identifierHeaderView];
}


- (UITableView*)tableView
{
    return (id)self.view;
}


- (void)viewDidLoad
{
    [super viewDidLoad]; 
    
    UITableView *table = _tableView;
    //table.separatorColor = [UIColor colorWithWhite:0.75 alpha:1.0];
    //self.navigationItem.titleView = _identifierField; <---- Aquesta línia afegeix la opció de modificar l'identifcador en la titleView del popover
    
    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
    [messageView setMessage:NSLocalizedString(@"ItemConfigurationFooter", nil)];
    [messageView setEmptyTitle:NSLocalizedString(@"No Values", nil)];
    
    
    [table setBackgroundColor:[UIColor colorWithWhite:0.90f alpha:1.0]];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [table setTableFooterView:messageView];
    
    //NSLog( @"tableViewVDL:\n%@\n", _tableView );
}

//- (void)viewDidUnload
//{
//    [self setIdentifierView:nil];
//    [super viewDidUnload];
//}

- (void)viewWillAppear:(BOOL)animated
{

    //NSLog( @"tableViewVWA:\n%@", _tableView );
    [super viewWillAppear:animated];
    
    NSString *identifier = _configuringObject.identifier;
    _identifierHeaderView.textField.text = identifier;
  
    [_configuringObject addObjectObserver:self];
    
    // descomentar aixo per posar un color especial
    //UIColor *color = DarkenedUIColorWithRgb(SystemDarkerBlueColor,1.2f);
    //[self.floatingPopoverController setTintColor:color];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[_configuringObject addAsleepObserver:self];
    //_identifierView.modelObject = _modelObject;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[self _endObservingModelForVisibleCells];
    
    [_rightButton stopWithCancel:YES animated:NO];
    [_configuringObject removeObjectObserver:self];
    //[_configuringObject removeAsleepObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES;
//}

#pragma mark Main Methods

- (void)headerAction:(id)sender
{
    SWItemConfiguratorHeader *header = sender;
    
    NSInteger section = [sender tag];
    NSInteger configurationTag = _configuringObject.configurationTag;
    
    BOOL isDisplayingRows = BitFromIntAtIndex(configurationTag, section);
    BOOL willDisplayRows = !isDisplayingRows;
    
    NSInteger currentRows = 0;
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    UITableView *tableView = _tableView;
    
    if (isDisplayingRows) 
    {
        currentRows = [self tableView:tableView numberOfRowsInSection:section];
        for (NSInteger i=0; i<currentRows; ++i)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }

    SetBitFromIntAtIndex(&configurationTag, section, willDisplayRows);
    _configuringObject.configurationTag = configurationTag;
    
    if (willDisplayRows) 
    {
        currentRows = [self tableView:tableView numberOfRowsInSection:section];
        for (NSInteger i=0; i<currentRows; ++i)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    if (willDisplayRows) 
    {
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [header expand:YES animated:YES];
    } 
    else
    {
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [header expand:NO animated:YES];
    }
    
    [_rightButton dismisInfoMessageAnimated:YES];
}

#pragma mark Private Methods

- (SWPropertyDescriptor*)_attributeDescriptionForIndexPath:(NSIndexPath*)indexPath
{
    SWObjectDescription *itemInfo = [_sectionObjects objectAtIndex:indexPath.section];    
    return [itemInfo.propertyDescriptions objectAtIndex:indexPath.row];
}


//- (void)_beginObservingModelForVisibleCells
//{
//    UITableView *table = _tableView;
//    for ( SWValueCell *cell in table.visibleCells )
//    {
//        [cell beginObservingModel];
//    }
//}
//
//- (void)_endObservingModelForVisibleCells
//{
//    UITableView *table = _tableView;
//    for ( SWValueCell *cell in table.visibleCells )
//    {
//        [cell endObservingModel];
//    }
//}

#pragma mark Protocol Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL displayRows = BitFromIntAtIndex(_configuringObject.configurationTag, section);
    
    if (!displayRows)
        return 0;
    
    SWObjectDescription *itemInfo = [_sectionObjects objectAtIndex:section];//[_itemInfo superclassInfoAtLevel:section];
    
    return itemInfo.propertyDescriptions.count;// itemInfo.propertyDescriptions.count + itemInfo.expressionDescriptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{        
    SWPropertyDescriptor *attrInfo = [self _attributeDescriptionForIndexPath:indexPath];
    SWValue *value = [_configuringObject valueWithSymbol:_configuringObject.identifier property:attrInfo.name];
    
    NSString *cellIdentifier = nil;
    NSString *nibName = nil;
    
    SWPropertyType propertyType = attrInfo.propertyType;
    SWType type = attrInfo.type;
    
    if ( propertyType == SWPropertyTypeExpression )
    {
        cellIdentifier = ExpressionCellIdentifier;
        nibName = IS_IOS7 ? ExpressionCellNibName : ExpressionCellNibName6;
    }
    
    else if ( propertyType == SWPropertyTypeNoEditableValue )
    {
        cellIdentifier = SWValueNoEditableCellIdentifier;
        nibName = SWValueNoEditableCellNibName;
    }

    else if ( propertyType == SWPropertyTypeValue )
    {
        switch ( type )
        {
            case SWTypeBool:
                cellIdentifier = SWValueTypeBoolCellIdentifier;
                nibName = SWValueTypeBoolCellNibName;
                break;
                
            case SWTypeRect:
                cellIdentifier = SWValueTypeRectCellIdentifier;
                nibName = SWValueTypeRectCellNibName;
                break;
                
            default:
                cellIdentifier = ExpressionCellIdentifier;
                nibName = IS_IOS7 ? ExpressionCellNibName : ExpressionCellNibName6;
                break;
        }
        
        if ( (type & SWEnumerationTypeMask) == SWEnumerationTypeYes )
        {
            cellIdentifier = SWValueTypeEnumCellIdentifier;
            nibName = IS_IOS7 ? SWValueTypeEnumCellNibName : SWValueTypeEnumCellNibName6;
        }
    }
    
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (_rightButton)
    {
        UITableViewCell *buttonedCell = [_rightButton amendedCellFromCell:cell atIndexPath:indexPath];
        cell = buttonedCell;
    }
        
    if (!cell) 
    {
        UINib *cellNib = [UINib nibWithNibName:nibName bundle:nil];
        cell = [[cellNib instantiateWithOwner:self options:nil] objectAtIndex:0];  // owner <- self, sets the textFields delegate to self
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    SWValueCell *valCell = (id)cell;
    valCell.delegate = self;
    
    if (cellIdentifier == SWValueTypeRectCellIdentifier) 
    {
        SWValueTypeRectCell *rectCell = (id)valCell;
        
        if ([_configuringObject isKindOfClass:[SWItem class]])
        {
            SWItem *item = (id)_configuringObject;
            rectCell.resizeMask = item.resizeMask;
        }
    }
    
    else if (cellIdentifier == ExpressionCellIdentifier)
    {
        SWExpressionCell *expCell = (id)valCell;
        expCell.showsAsValue =  (propertyType == SWPropertyTypeValue);
        
        BOOL bOverlay = [_editingIndexPath isEqual:indexPath];
        [expCell.expressionTextView setOverlay:bOverlay];
    }
    
    valCell.value = value;
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SWObjectDescription *itemInfo = [_sectionObjects objectAtIndex:section];//[_itemInfo superclassInfoAtLevel:section];
    
    NSString *nibName;
    if ( IS_IOS7 ) nibName = @"SWItemConfiguratorHeader";
    else nibName = @"SWItemConfiguratorHeader6";
    UINib *nib = [UINib nibWithNibName:@"SWItemConfiguratorHeader" bundle:nil];
    NSArray *views = [nib instantiateWithOwner:nil options:nil];
    
    SWItemConfiguratorHeader *header = [views objectAtIndex:0];
    
    header.title = itemInfo.localizedName;
    header.tag = section;
    [header setTarget:self andAction:@selector(headerAction:)];
    
    [header expand:BitFromIntAtIndex(_configuringObject.configurationTag, section) animated:NO];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    SWPropertyDescriptor *descriptor = [self attributeDescriptionForIndexPath:indexPath];
//    SWValue *value = [self.configuringObject valueWithSymbol:self.configuringObject.identifier property:descriptor.name];
//    
//    CGFloat height = 44;
//    
//    if ([value isKindOfClass:[SWExpression class]])
//    {
//        height = 88;
//    }
//    else
//    {
//        switch (descriptor.type) {
//            case SWTypeRect:
//                height = 102;
//                break;
//                
//            default:
//                height = 44;
//                break;
//        }
//    }
//    
//    return height;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    SWPropertyDescriptor *attrInfo = [self _attributeDescriptionForIndexPath:indexPath];
    SWPropertyType propertyType = attrInfo.propertyType;
    
    if ( propertyType == SWPropertyTypeNoEditableValue)
    {
        height = 44;
    }
    
    else if ( propertyType == SWPropertyTypeExpression )
    {
        height = 88;
        height = 102;
    }
    else if ( propertyType == SWPropertyTypeValue)
    {
        SWType type = attrInfo.type;
        switch ( type )
        {
            case SWTypeBool:
                height = 50;
                break;
        
            case SWTypeRect:
                height = 102;
                break;
                
            default:
                height = 88;
                height = 102;  // propietats editables
                break;
        }
        
        if ( (type & SWEnumerationTypeMask) == SWEnumerationTypeYes )
        {
            height = 50;
        }
    }
    
    return height;
}

#pragma mark Protocol Table view delegate



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    SWBackgroundViewCell *backgroundView = [[SWBackgroundViewCell alloc] initWithFrame:cell.backgroundView.bounds];
//    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    
//    cell.backgroundView = backgroundView;
    //[cell setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor colorWithWhite:0.96f alpha:1.0f]];
    
    [(SWValueCell*)cell beginObservingModel];
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( cell == [_rightButton currentResponderCell])  // woraround al radar 12307048 (https://bugreport.apple.com/cgi-bin/WebObjects/RadarWeb.woa)
        return;
        
    [(SWValueCell*)cell endObservingModel];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark ScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_rightButton dismisInfoMessageAnimated:YES];
}

//#pragma mark Protocol SWTableFieldsController

//- (SWTableFieldsController *)rightButton
//{
//    if (_rightButton == nil)
//        _rightButton = [[SWTableFieldsController alloc] initWithOwner:self];
//        
//    return _rightButton;
//}

//#pragma mark Protocol SWTableFieldsController delegate

//- (void)tableFieldsController:(SWTableFieldsController*)controller didProvideControl:(UIControl*)aControl animated:(BOOL)animated
//{
//    UIBarButtonItem *barItem = nil;
//    
//    if (aControl)
//    {
//        barItem = [[UIBarButtonItem alloc] initWithCustomView:aControl];
//        _rightBarButtonItem = self.navigationItem.rightBarButtonItem;
//    }
//    else
//    {
//        barItem = _rightBarButtonItem;
//    }
//    
//    [[self navigationItem] setRightBarButtonItem:barItem animated:animated];
//}


- (BOOL)tableFieldsController:(SWTableFieldsController*)controller validateField:(id)field 
        forCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath outErrorString:(NSString **)errorString
{
    BOOL valid = YES;

    NSString *cellIdentifier = cell.reuseIdentifier;
    NSString *text = [(SWTextField*)field text];
    
    if ([text isEqualToString:@""] && field != _identifierHeaderView.textField /*_identifierView.identifierField*/)
        return  YES;
    
    if ( field == _identifierHeaderView.textField )
    {
        valid = [SWObject isValidIdentifier:text outErrString:errorString];
    } 
    else if ([cellIdentifier isEqualToString:ExpressionCellIdentifier] ||
        //[cellIdentifier isEqualToString:SWValueEditableCellIdentifier] ||
        [cellIdentifier isEqualToString:SWValueTypeRectCellIdentifier] )
    {
        RpnBuilder *builder = [_configuringObject builder];
        valid = [RpnBuilder isValidExpressionSource:text forBuilderInstance:builder outErrString:errorString];
    }
    
    return valid;
}


//- (void)tableFieldsControllerWillStopWithCancel:(BOOL)cancel
//{
//    RoundedTextView *currentTextView = (id)[_rightButton currentTextResponder];
//    if ( [currentTextView respondsToSelector:@selector(setOverlay:)] )
//        [currentTextView setOverlay:NO];
//}


//- (void)tableFieldsControllerCancel:(SWTableFieldsController *)controller animated:(BOOL)animated
//{
//    [_modelManager.inputController resignResponder];
//}

- (void)tableFieldsControllerApply:(SWTableFieldsController*)controller animated:(BOOL)animated
{
    NSArray *cellWrappers = [controller cellWrappers];
    
    for (SWCellWrapper *cellWrap in cellWrappers)
    {
        NSString *cellIdentifier = cellWrap->cell.reuseIdentifier;
        
        if ([cellIdentifier isEqualToString:ExpressionCellIdentifier])
        { 
            SWExpressionCell *exprCell = (id)cellWrap->cell;
            ExpressionTextView *textView = exprCell.expressionTextView;
            NSString *sourceString = textView.text;
            NSIndexPath *indexPath = cellWrap->indexPath;
            SWPropertyDescriptor *attrInfo = [self _attributeDescriptionForIndexPath:indexPath];
            SWPropertyType propertyType = attrInfo.propertyType;
            
            if ( propertyType == SWPropertyTypeExpression )
            {
                SWExpression *expression = exprCell.value;
                if ([sourceString isEqualToString:@""])
                {
                    SWValue *defaultValue = [expression getDefaultValue];
                    sourceString = [defaultValue getSourceString];
                }
                [_configuringObject updateExpression:expression fromString:sourceString];
            }
            else if ( propertyType == SWPropertyTypeValue )
            {
                SWValue *theValue = exprCell.value;
                SWValue *newValue = nil;
                if ([sourceString isEqualToString:@""])
                    newValue = [theValue getDefaultValue];
                else
                    newValue = [_configuringObject.builder valueWithSourceString:sourceString outErrString:nil];
            
                [theValue setValueFromValue:newValue];
            }
            
        } 
//        else if ([cellIdentifier isEqualToString:SWValueEditableCellIdentifier]) 
//        {
//            SWValueEditableCell *propCell = (id)cellWrap->cell;
//            NSString *sourceString = propCell.textField.text;
//            
//            SWValue *theValue = propCell.value;
//            SWValue *newValue = nil;
//            
//            if (sourceString.length == 0)
//                newValue = [[propCell.value valueDescription] defaultValue];
//            
//            else
//            {
//                newValue = [self.configuringObject.builder valueWithSourceString:sourceString outErrString:nil];
//            }
//            
//            [theValue setValueFromValue:newValue];
//        }
        
        else if ([cellIdentifier isEqualToString:SWValueTypeRectCellIdentifier]) 
        {
            SWValueTypeRectCell *rectCell = (id)cellWrap->cell;
            SWValue *value = rectCell.value;
            CGRect defRect = [[value getDefaultValue] valueAsCGRect];
            
            NSString *fieldXStr = rectCell.fieldX.text;
            NSString *fieldYStr = rectCell.fieldY.text;
            NSString *fieldWStr = rectCell.fieldWidth.text;
            NSString *fieldHStr = rectCell.fieldHeight.text;
            
            CGFloat fieldX;
            CGFloat fieldY;
            CGFloat fieldW;
            CGFloat fieldH;
            
            RpnBuilder *builder = _configuringObject.builder;
            
            if ([fieldXStr isEqualToString:@""])
                fieldX = defRect.origin.x;
            else
                fieldX = [[builder valueWithSourceString:fieldXStr outErrString:nil] valueAsDouble];
            
            if ([fieldYStr isEqualToString:@""])
                fieldY = defRect.origin.y;
            else
                fieldY = [[builder valueWithSourceString:fieldYStr outErrString:nil] valueAsDouble];
            
            if ([fieldWStr isEqualToString:@""])
                fieldW = defRect.size.width;
            else
                fieldW = [[builder valueWithSourceString:fieldWStr outErrString:nil] valueAsDouble];
            
            if ([fieldHStr isEqualToString:@""])
                fieldH = defRect.size.height;
            else
                fieldH = [[builder valueWithSourceString:fieldHStr outErrString:nil] valueAsDouble];    
            
            CGRect finalFrame = CGRectMake(fieldX, fieldY, fieldW, fieldH);
            
            if ([_configuringObject isKindOfClass:[SWItem class]])
            {
                SWItem *item = (id)_configuringObject;
                
                if ( value == item.framePortrait)
                    [item setFrame:finalFrame withOrientation:UIInterfaceOrientationPortrait idiom:SWDeviceInterfaceIdiomPad];

                else if ( value == item.frameLandscape )
                    [item setFrame:finalFrame withOrientation:UIInterfaceOrientationLandscapeLeft idiom:SWDeviceInterfaceIdiomPad];
                
                if ( value == item.framePortraitPhone)
                    [item setFrame:finalFrame withOrientation:UIInterfaceOrientationPortrait idiom:SWDeviceInterfaceIdiomPhone];

                else if ( value == item.frameLandscapePhone )
                    [item setFrame:finalFrame withOrientation:UIInterfaceOrientationLandscapeLeft idiom:SWDeviceInterfaceIdiomPhone];

                else
                    value.valueAsCGRect = finalFrame;
            } 
            else
            {
                value.valueAsCGRect = finalFrame;
            }
        }
    }
    
    // Fem el setter de l'identificador, si cal
    if ([controller.textResponders containsObject:_identifierHeaderView.textField/*_identifierView.identifierField*/])
    {
//        SWTextField *textField = _identifierView.identifierField;
//        [self.configuringObject setIdentifier:textField.text];
        
        [_configuringObject setIdentifier:_identifierHeaderView.textField.text];
    }
    
//    [_modelManager.inputController resignResponder];
    [super tableFieldsControllerApply:controller animated:animated];
}






#pragma mark Protocol ObjectObserver

- (void)identifierDidChangeForObject:(SWObject *)object
{
    //_identifierView.identifierField.smartText = object.identifier;
    NSString *identifier = object.identifier;
    _identifierHeaderView.textField.smartText = identifier;
    self.title = identifier;
    _titleView.mainLabel.text = identifier;
    [_titleView sizeToFit];
    
    NSNotificationCenter *nc= [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SWItemConfigurationControllerDidChangeNameNotification object:nil];
}


- (void)willRemoveObject:(SWObject *)object
{
//    SWDocumentModel *docModel = _configuringObject.docModel;
//    SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:docModel];
    
    //[manager dismissModelConfiguratorForObject:_configuringObject animated:YES];
    //[_modelManager removeModelConfiguratorForObject:_configuringObject animated:YES presentingControllerKey:nil];
    [_modelManager removeModelConfiguratorFromControllerWithIdentifier:nil forObject:_configuringObject animated:YES];
}


#pragma mark Protocol SWExpressionCellDelegate

- (void)expressionCell:(SWExpressionCell*)cell presentExpressionConfiguratorFromView:(UIView*)view
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SWValue *value = cell.value;
    
    if (cell.expressionTextView.hasBullet)
    {
        //
    }
    else
    {
        [_modelManager showModelPickerOnPresentingControllerWithIdentifier:nil forObject:_configuringObject withValue:value context:indexPath delegate:self dataSource:self animated:YES];
    }
}



- (void)expressionCell:(SWExpressionCell*)cell presentMessage:(NSString*)msg fromView:(SWExpressionCell*)view
{
    [self.rightButton presentInfoMessage:msg fromView:view animated:YES];
}


- (void)expressionCellSourceStringDidChange:(SWExpressionCell *)cell
{
    if ( _updatingValue )
        return;
    
    // Actualitzar la seleccio del controlador del seeker amb el nou valor
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SWValue *value = cell.value;
    
    [_modelManager updateModelPickerForPresentingControllerWithIdentifier:nil forObject:_configuringObject withValue:value context:indexPath delegate:self dataSource:self animated:YES];
}


#pragma mark SWValueCellTypeEnumDelegate

- (NSArray*)optionsForEnumCell:(SWValueTypeEnumCell *)enumCell
{
    SWPropertyDescriptor *descriptor = enumCell.value.valueDescription;
    
//    NSMutableArray *array = [NSMutableArray array];
//    NSInteger count = numberOfOptionsForType(descriptor.type);
//    
//    for (NSInteger i=0; i<count; ++i) 
//    {
//        NSString *title = localizedNameForOption_type(i,descriptor.type);
//        [array addObject:title];
//    }
    
    NSArray *array = localizedNamesArrayForType(descriptor.type);
    return array;
}

//#pragma mark Protocol UIPopoverControllerDelegate
//
//- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
//{
//    _popover = nil;
//}

//#pragma mark Protocol SWFloatingPopoverControllerDelegate
//- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)floatingPopoverController
//{
//    SWExpressionCell *cell = (id)[self.tableView cellForRowAtIndexPath:_configuringIndexPath];
//    [cell.expressionTextView setOverlay:NO];
//    _configuringIndexPath = nil;
//}

@end

@implementation SWObjectConfiguratorController (CustomProtocols)

#pragma mark Protocol ModelManagerDelegate

- (void)modelManager:(SWModelManager *)manager didSelectValue:(SWValue *)value context:(id)context
{
    NSAssert(context != nil,nil);
    NSIndexPath *indexPath = (id)context;
        
    NSString *bindableValue = [value getBindableString];
    SWExpressionCell *configuringCell = (id)[_tableView cellForRowAtIndexPath:indexPath];
        
    _updatingValue = YES;
    if (configuringCell.expressionTextView.hasBullet)
    {
        ExpressionTextView *textView = configuringCell.expressionTextView;
            
        NSString *text = textView.text;
        NSRange range = textView.selectedRange;
        NSString *finalString = [text stringByReplacingCharactersInRange:range withString:bindableValue];
            
        textView.text = finalString;
    }
    else
    {
        SWPropertyDescriptor *attrInfo = [self _attributeDescriptionForIndexPath:indexPath];
        SWPropertyType propertyType = attrInfo.propertyType;
        if ( propertyType == SWPropertyTypeExpression )
        {
            SWExpression * expression = configuringCell.value;
            [_configuringObject updateExpression:expression fromString:bindableValue];
        }
        else if ( propertyType == SWPropertyTypeValue )
        {
            SWValue *theValue = configuringCell.value;
            SWValue *newValue = [_configuringObject.builder valueWithSourceString:bindableValue outErrString:nil];
            [theValue setValueFromValue:newValue];
        }
    }
    _updatingValue = NO;
}

- (void)modelManager:(SWModelManager *)manager willEndPickerForObject:(id)object value:(SWValue *)value context:(id)context
{
    NSIndexPath *indexPath = context;
    SWExpressionCell *oldCell = (id)[_tableView cellForRowAtIndexPath:indexPath];
    
    _editingIndexPath = nil;
    [oldCell.expressionTextView setOverlay:NO];
}


- (void)modelManager:(SWModelManager *)manager willBeginPickerForObject:(id)object value:(SWValue *)value context:(id)context
{
    NSIndexPath *indexPath = context;
    SWExpressionCell *cell = (id)[_tableView cellForRowAtIndexPath:indexPath];
    
    _editingIndexPath = indexPath;
    [cell.expressionTextView setOverlay:YES];
}


#pragma mark Protocol ModelManagerDataSource

- (UIView*)modelManager:(SWModelManager *)manager revealViewForObject:(id)object value:(SWValue *)value context:(id)context
{
    NSIndexPath *indexPath = context;
    SWExpressionCell *cell = (id)[_tableView cellForRowAtIndexPath:indexPath];
    return cell.detailButton;
}

@end
