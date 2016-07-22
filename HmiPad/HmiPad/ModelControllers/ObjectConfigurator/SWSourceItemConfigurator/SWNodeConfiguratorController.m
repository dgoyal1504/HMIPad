//
//  SWNodeConfiguratorController.m
//  HmiPad
//
//  Created by Joan Martin on 9/19/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWNodeConfiguratorController.h"

#import "SWDocumentModel.h"
#import "SWPlcTag.h"
#import "SWSourceNode.h"
#import "SWSourceItem.h"

#import "SWTableFieldsController.h"
#import "SWTableFieldsControllerDelegate.h"
#import "SWExpressionInputController.h"

#import "SWSourceFieldCell.h"
#import "SWExpressionCell.h"

#import "RoundedTextView.h"
#import "SWTableViewMessage.h"

#import "SWTableSectionHeaderView.h"
#import "SWTableSelectionController.h"
#import "SWTableView.h"

#import "SWIdentifierHeaderView.h"
#import "SWNavBarTitleView.h"

#import "SWModelManager.h"

//#import "SWKeyboardListener.h"

#define block_return return

// Defining sections
enum
{
    expressionSection = 0,
    plcTagSection,
    extraSection,
    scalingSection,
    sectionCount,
};

// Defining rows

// Section 1 (expressionSection)
enum
{
    writtingExpressionCellRow = 0,
    expressionSectionCount,
};

// Section 2 (typeSection)
enum
{

    addressCellRow = 0,
    typeSCellRow,
    //typeCellRow,
    //arraySizeCellRow,
    plcTagSectionRowCount,
};


enum
{
    modbusSlaveRow = 0,
    modbusSectionCount
};

    // Section 3 (scalingSection)
enum
{
    rawMinValueCellRow = 0,
    rawMaxValueCellRow,
    engineeringMinValueCellRow,
    engineeringMaxValueCellRow,
    scalingSectionCount,
};

@interface SWNodeConfiguratorController()
{
    SWSourceItem *_sourceItem;
    
    //SWTableFieldsController *_rightButton;
    //SWExpressionInputController *_expressionInput;
    //UIBarButtonItem *_defaultRightButton;
    
    UIPopoverController *_popover;
    SWNavBarTitleView *_titleView;
}
@end

@interface SWNodeConfiguratorController (CustomObservation) <SourceItemObserver,ValueObserver/*,SWAsleepObserver*/>
@end

@interface SWNodeConfiguratorController (CustomDelegates) <SWModelManagerDelegate, SWModelManagerDataSource, SWExpressionCellDelegate, /*RoundedTextViewDelegate,*/ SWTableFieldsControllerDelegate, SWTableSelectionControllerDelegate /*,SWExpressionInputControllerDelegate*/>
@end

@interface SWNodeConfiguratorController (UIProtocols) <UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate,UIPopoverControllerDelegate>
@end

@interface SWNodeConfiguratorController()
@end

@implementation SWNodeConfiguratorController
{
    //__weak SWModelManager *_modelManager;
    BOOL _updatingValue;
}

@synthesize tableView = _tableView;

//- (void) dealloc
//{
//    SWExpressionInputController *inputController = _modelManager.inputController;
//    if (inputController.delegate == self)
//    {
//        inputController.delegate = nil;
//    }
//}


- (id)initWithConfiguringObject:(NSArray*)object
{
    self = [super initWithConfiguringObject:object];
    if ( self )
    {
        _configuringObjects = _configuringObjectInstance;

        Class SourceNode = [SWSourceNode class];
        SWSourceItem *sourceItem = nil;
    
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (id item in _configuringObjects)
        {
            NSAssert([item isKindOfClass:SourceNode], nil);  // <---- Petem si algun objecte no es un SWSourceNode
            SWSourceNode *node = item;
        
            if (!sourceItem)
                sourceItem = node.sourceItem;
        
            NSAssert(sourceItem == node.sourceItem, nil); // <----- Tots els nodes han de procedir d'un mateix source item
        
            [indexSet addIndex:[sourceItem.sourceNodes indexOfObjectIdenticalTo:node]];
        }
    
        _sourceItem = sourceItem;
        _nodesIndexes = indexSet;
        _modelManager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_sourceItem.docModel];
        
        self.title = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
        {
            SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
            block_return node.name;
        }];
        
        _titleView = [[SWNavBarTitleView alloc] init];
        _titleView.secondaryLabel.text = NSLocalizedString(@"TAG Configurator", nil);
        _titleView.mainLabel.text = self.title;
        [_titleView sizeToFit];
        self.navigationItem.titleView = _titleView;
        
        //self.contentSizeForViewInPopover = CGSizeMake(320, 480);
        self.preferredContentSize = CGSizeMake(320, 480);
       // _viewWillDisappearToReturn = NO;
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)loadView
{
    //[super loadView];

    UITableView *tableView = [[SWTableView alloc] initWithFrame:CGRectMake(0,0,100,100) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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
    [_tableView setTableHeaderView:_identifierHeaderView];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    // Registrem el SWSourceFieldCell i SWExpressionCell
//    [_tableView registerNib:[UINib nibWithNibName:SWSourceFieldCellNibName bundle:nil] forCellReuseIdentifier:SWSourceFieldCellIdentifier];
//    
//    NSString *nibName = IS_IOS7 ? ExpressionCellNibName : ExpressionCellNibName6;
//    [_tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:ExpressionCellIdentifier];

    [_tableView setBackgroundColor:[UIColor colorWithWhite:0.90f alpha:1.0]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
    [messageView setMessage:NSLocalizedString(@"SourceNodeConfigurationFooter", nil)];
    [messageView setEmptyTitle:NSLocalizedString(@"No Values", nil)];
    
    [_tableView setTableFooterView:messageView];
}


- (UITableView*)tableView
{
    return (id)self.view;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *identifier = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
    {
        SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
        block_return node.name;
    }];
    
    _identifierHeaderView.textField.text = identifier;
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
    [_sourceItem addObjectObserver:self];
    
//    if ( _nodesIndexes.count == 1 )
//    {
//        int nodeIndex = [_nodesIndexes firstIndex];
//        SWSourceNode *node = [_sourceItem.sourceNodes objectAtIndex:nodeIndex];
//        SWValue *readExpr = (id)node.readExpression;
//        [readExpr addObserver:self];
//    }
    
    if ( _configuringObjects.count == 1 )
    {
        SWSourceNode *node = [_configuringObjects objectAtIndex:0];
        SWValue *readExpr = (id)node.readExpression;
        [readExpr addObserver:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    

        [_rightButton stopWithCancel:YES animated:NO]; // <---- No accepta els canvis
    
    [_sourceItem removeObjectObserver:self];
    
//    if ( _nodesIndexes.count == 1 )
//    {
//        int nodeIndex = [_nodesIndexes firstIndex];
//        SWSourceNode *node = [_sourceItem.sourceNodes objectAtIndex:nodeIndex];
//        SWValue *readExpr = (id)node.readExpression;
//        [readExpr removeObserver:self];
//    }
    
    if ( _configuringObjects.count == 1 )
    {
        SWSourceNode *node = [_configuringObjects objectAtIndex:0];
        SWValue *readExpr = (id)node.readExpression;
        [readExpr removeObserver:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark Private Methods



static NSString *MultipleValuesText = @"MultipleValuesText";

- (void)_setValuesUsingBlock:(void (^)(SWSourceItem *source, NSUInteger i))block
{
    [_nodesIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        block(_sourceItem, idx);
    }];
}

- (NSString*)_getStringValueUsingBlock:(NSString* (^)(SWSourceItem *source, NSUInteger i))block
{
    return [self _multipleValuesTextFromText:[self _primitiveStringValueUsingBlock:block]];
}

- (NSString*)_multipleValuesTextFromText:(NSString*)text
{
    if (text == MultipleValuesText)
        return NSLocalizedString(@"Multiple Values", nil);
    
    return text;
}

- (NSString*)_primitiveStringValueUsingBlock:(NSString* (^)(SWSourceItem *source, NSUInteger i))block
{
    __block NSString *_text = nil;
    
    [_nodesIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
         NSString *text = block(_sourceItem, idx);
         
         if (_text == nil)
         {
             _text = text;
         }
         else
         {
             if (![_text isEqualToString:text])
             {
                 _text = MultipleValuesText;
                 *stop = YES;
             }
         }
     }];
    
    return _text;
}

@end


#pragma mark - Protocol Custom Observation

@implementation SWNodeConfiguratorController (CustomObservation)

// TODO


#pragma mark - Protocol ValueObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
   // [self _updateValue];
}

- (void)valueDidChangeName:(SWValue *)value
{
    NSString *identifier = value.property;
    _identifierHeaderView.textField.smartText = identifier;
    
    self.title = value.property;
    _titleView.mainLabel.text = self.title;
    [_titleView sizeToFit];
   
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:identifierCellRow inSection:variableSection];
//    SWSourceFieldCell *fieldCell = (SWSourceFieldCell*)[_tableView cellForRowAtIndexPath:indexPath];
//    if (fieldCell)
//    {
//        SWTextField *textField = fieldCell.textField;
//        textField.smartText = identifier;
//    }

}

#pragma mark - SourceItemObserver

- (void)sourceItem:(SWSourceItem *)source willRemoveSourceNodesAtIndexes:(NSIndexSet *)indexes
{
    NSArray *sourceNodes = _sourceItem.sourceNodes;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWSourceNode *node = [sourceNodes objectAtIndex:idx];
        if ([_configuringObjects containsObject:node] )
        {
            [_modelManager removeModelConfiguratorFromControllerWithIdentifier:nil forObject:_configuringObjects animated:YES];
            *stop = YES;
        }
    }];
}


- (void)sourceItem:(SWSourceItem*)source plcTagDidChange:(SWPlcTag *)plcTag atIndex:(NSInteger)indx
{
    NSArray *sourceNodes = _sourceItem.sourceNodes;
    SWSourceNode *node = [sourceNodes objectAtIndex:indx];
    
    if ( [_configuringObjects containsObject:node] )
    {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:plcTagSection];
        [indexSet addIndex:scalingSection];
        [indexSet addIndex:extraSection];
        [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }
}


@end

#pragma mark - Protocol Custom Delegates

@implementation SWNodeConfiguratorController (CustomDelegates)

#pragma mark SWModelManagerDelegate

- (void)modelManager:(SWModelManager *)manager didSelectValue:(SWValue *)value context:(id)context
{
    //NSAssert( _configuringIndexPath != nil, nil );
    NSAssert( context != nil, nil );
    NSIndexPath *indexPath = context;
    
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
        NSAssert( [indexPath isEqual:[NSIndexPath indexPathForRow:writtingExpressionCellRow inSection:expressionSection]], nil);
        [self _setValuesUsingBlock:^(SWSourceItem *source, NSUInteger i)
        {
            [source updateWExpressionAtIndex:i withString:bindableValue];
        }];
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
    
    UIView *revealView = nil;
    SWExpressionCell *cell = (id)[_tableView cellForRowAtIndexPath:indexPath];
    if ( cell.value == value )
    {
        revealView = cell.detailButton;
    }
    return revealView;
}

#pragma mark SWExpressionCellDelegate


- (void)expressionCell:(SWExpressionCell *)cell presentExpressionConfiguratorFromView:(UIView *)view
{
    UITableView *tableView = _tableView;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    SWValue *value = cell.value;
    
    if (cell.expressionTextView.hasBullet)
    {
        //
    }
    else
    {        
        [_modelManager showModelPickerOnPresentingControllerWithIdentifier:nil forObject:_configuringObjects withValue:value context:indexPath delegate:self dataSource:self animated:YES];
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
    
    // Volem dismissar el seeker si hi ha un canvi (ex per undo) en el source string d'algun item, en particular del que s'esta sekejant.
    
    [_modelManager dismissModelSeekerFromControllerWithIdentifier:nil animated:YES];
}



#pragma mark TableFieldsControllerDelgate and auxiliar methods


- (BOOL)tableFieldsController:(SWTableFieldsController*)controller validateField:(id)field forCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath outErrorString:(NSString **)errorString
{
    BOOL valid = YES;
    
    NSString *text = [(UITextField*)field text];
    
    if ( field == _identifierHeaderView.textField )
    {
        valid = [SWObject isValidIdentifier:text outErrString:errorString];
        return valid;
    }

    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
//    if (section == variableSection)
//    {
//        switch (row)
//        {
//            case identifierCellRow:
//                
//                valid = [SWObject isValidIdentifier:text outErrString:errorString];
//                break;
//                
//            default:
//                break;
//        }
//    }
//    else
    if (section == expressionSection)
    {
        switch (row)
        {
            case writtingExpressionCellRow:
            {
                if ([text isEqualToString:@""])
                {
                    valid = YES;
                }
                else
                {
                    RpnBuilder *builder = _sourceItem.docModel.builder;
                    valid = [RpnBuilder isValidExpressionSource:text forBuilderInstance:builder outErrString:errorString];
                }
                break;
            }
            default:
                break;
        }
    }
    
    else if (section == plcTagSection)
    {
        switch (row)
        {
            case addressCellRow:
            {
                // per comprobar la adressa fem el possible per trobar el texte del tipus que pot estar a mig editar en aquest indexPath
                NSString *typeString = nil;
                NSIndexPath *typeIndexPath = [NSIndexPath indexPathForRow:typeSCellRow inSection:plcTagSection];
                
                // potser la celda esta visible (editantse o no)
                SWSourceFieldCell *fieldCell = (id)[self.tableView cellForRowAtIndexPath:typeIndexPath];
                
                // si no es visible, potser esta editant-se i registrada per el fields controller
                if ( fieldCell == nil ) fieldCell = (id)[controller cellForIndexPath:indexPath];
                
                // si encara no el tenim, el type string el determinem a partir dels tags per aquest controlador
                if ( fieldCell == nil )
                {
                    typeString = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
                    {
                        SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
                        block_return [node.plcTag typeAsString];
                    }];
                }
                else
                {
                    typeString = fieldCell.textField.text;
                }
            
                valid = [SWPlcTag isValidAddress:text withType:typeString forProtocol:_sourceItem.protocol outErrString:errorString];
                break;
            }
            case typeSCellRow:
                valid = [SWPlcTag isValidType:text forProtocol:_sourceItem.protocol outErrString:errorString];
                break;
                
//            case typeCellRow:
//                // TODO
//                break;
//            case arraySizeCellRow:
//                // TODO
//                break;
            default:
                break;
        }
    }
    
    else if (section == extraSection)
    {
        // TODO
    }
    
    else if (section == scalingSection)
    {
        switch (row)
        {
            case rawMinValueCellRow:
                // TODO
                break;
            case rawMaxValueCellRow:
                // TODO
                break;
            case engineeringMinValueCellRow:
                // TODO
                break;
            case engineeringMaxValueCellRow:
                // TODO
                break;
            default:
                break;
        }
    }
    
    return valid;
}

- (void)tableFieldsControllerApply:(SWTableFieldsController*)controller animated:(BOOL)animated
{
    NSArray *cellWrappers = [controller cellWrappers];
    
    NSString *addressStr = nil;
    NSString *typeSStr = nil;
    NSString *leadingCodeStr = nil;
    //NSString *typeStr = nil;
    //NSString *countStr = nil;
    
    NSString *rawMinStr = nil;
    NSString *rawMaxStr = nil;
    NSString *engMinStr = nil;
    NSString *engMaxStr = nil;
    
    BOOL tagChanged = NO;
    
    for (SWCellWrapper *cellWrap in cellWrappers)
    {        
        NSInteger section = cellWrap->indexPath.section;
        NSInteger row = cellWrap->indexPath.row;
        
        if (section == expressionSection)
        {
            switch (row)
            {
                case writtingExpressionCellRow:
                {
                    //[self _setSourceNodeWrittingExpressionSource:text];
                    
                    SWExpressionCell *exprCell = (id)cellWrap->cell;
                    
                    SWExpression *expression = exprCell.value;
                    NSString *sourceString = exprCell.expressionTextView.text;
                    
                    if ( sourceString.length == 0 )
                    {
                        SWValue *defaultValue = [expression getDefaultValue];
                        sourceString = [defaultValue getSourceString];
                    }
                    
                    [self _setValuesUsingBlock:^(SWSourceItem *source, NSUInteger i)
                    {
                        [source updateWExpressionAtIndex:i withString:sourceString];
                    }];
                    break;
                }
                default:
                    break;
            }
            continue;  // process next cellWrap
        }
        
        SWSourceFieldCell *cell = (SWSourceFieldCell *)(cellWrap->cell);
        NSString *text = cell.textField.text;
        
        if (section == plcTagSection)
        {
            switch (row)
            {
                case addressCellRow:
                    addressStr = text;
                    tagChanged = YES;
                    break;
                case typeSCellRow:
                    typeSStr = text;
                    tagChanged = YES;
                    break;
//                case typeCellRow:
//                    typeStr = text;
//                    tagChanged = YES;
//                    break;
//                case arraySizeCellRow:
//                    countStr = text;
//                    tagChanged = YES;
//                    break;
                default:
                    break;
            }
        }
        
        else if (section == extraSection)
        {
           if ( _sourceItem.protocol == kProtocolTypeModbus )
            {
                if (row == modbusSlaveRow)
                {
                    leadingCodeStr = text;
                    tagChanged = YES;
                    break;
                }
            }
        }
        
        else if (section == scalingSection)
        {
            switch (row)
            {
                case rawMinValueCellRow:
                    rawMinStr = text;
                    tagChanged = YES;
                    break;
                case rawMaxValueCellRow:
                    rawMaxStr = text;
                    tagChanged = YES;
                    break;
                case engineeringMinValueCellRow:
                    engMinStr = text;
                    tagChanged = YES;
                    break;
                case engineeringMaxValueCellRow:
                    engMaxStr = text;
                    tagChanged = YES;
                    break;
                default:
                    break;
            }
        }
    }
    
    if (tagChanged)
    {
        [self _setValuesUsingBlock:^(SWSourceItem *source, NSUInteger i)
        {
            SWPlcTag *tag = [source plcTagCopyAtIndex:i];
            
            if ( leadingCodeStr)
                tag->leadingCode = [leadingCodeStr integerValue];
            
            if ( addressStr || typeSStr )
                [tag setAddresAsString:addressStr typeString:typeSStr];
            
            if (rawMinStr) tag->scale.rmin = [rawMinStr doubleValue];
            if (rawMaxStr) tag->scale.rmax = [rawMaxStr doubleValue];
            if (engMinStr) tag->scale.emin = [engMinStr doubleValue];
            if (engMaxStr) tag->scale.emax = [engMaxStr doubleValue];
            
            [source replacePlcTagAtIndex:i byPlcTag:tag];
        }];
    }
    
    
    // Fem el setter de l'identificador, si cal
    if ([controller.textResponders containsObject:_identifierHeaderView.textField])
    {
        NSString *text = _identifierHeaderView.textField.text;
        [self _setValuesUsingBlock:^(SWSourceItem *source, NSUInteger i)
        {
            [source replaceNameAtIndex:i byName:text];
        }];
    }
    
    
    //[_modelManager.inputController resignResponder];
    [super tableFieldsControllerApply:controller animated:animated];
}


// #pragma mark - SWExpressionInputControllerDelegate

//- (void)expressionInputControllerApply:(SWExpressionInputController*)controller
//{
//    [_rightButton stopWithCancel:NO animated:YES];
//}

//- (void)expressionInputControllerCancel:(SWExpressionInputController*)controller
//{
//    [_rightButton stopWithCancel:YES animated:YES];
//}


#pragma mark SWTableSelectionControllerDelegate

- (void)tableSelection:(SWTableSelectionController*)controller didSelectOption:(NSString*)option
{
    NSInteger section = controller.swtag0;
    NSInteger row = controller.swtag1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[SWSourceFieldCell class]])
    {
        SWSourceFieldCell *fieldCell = (SWSourceFieldCell*)cell;
        SWTextField *textField = fieldCell.textField;
        
        [self.rightButton startAnimated:YES];
        [_rightButton recordTextResponder:textField];
        textField.text = option;
    }
    
    //[self.navigationController popViewControllerAnimated:YES];
    
    [_popover dismissPopoverAnimated:YES];
    _popover = nil;
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

#pragma mark - UI Protocols

@implementation SWNodeConfiguratorController (UIProtocols)

#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popover = nil;
    
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (section == expressionSection)
        count = expressionSectionCount;
    
    else if (section == plcTagSection)
        count = plcTagSectionRowCount;
    
    else if (section == extraSection)
    {
        if (_sourceItem.protocol == kProtocolTypeModbus)
            count = modbusSectionCount;
    }
    
    else if (section == scalingSection)
        count = scalingSectionCount;
    
    return count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *identifier = nil;
    
    if (section == expressionSection && row == writtingExpressionCellRow)
        identifier = ExpressionCellIdentifier;
    else
        identifier = SWSourceFieldCellIdentifier;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (_rightButton)
        cell = [_rightButton amendedCellFromCell:cell atIndexPath:indexPath];
    
    if (cell == nil )
    {
        // Sempre existeix cell ja que estan registrades com a nibs en el viewDidLoad
        
        UINib *cellNib = nil;
        NSString *nibName = nil;
        
        if (identifier == SWSourceFieldCellIdentifier) nibName = SWSourceFieldCellNibName;
        if (identifier == ExpressionCellIdentifier) nibName = ExpressionCellNibName;
        
        cellNib = [UINib nibWithNibName:nibName bundle:nil];
        cell = [[cellNib instantiateWithOwner:self options:nil] objectAtIndex:0];  // owner <- self, sets the textFields delegate to self
        
        NSAssert( [cell.reuseIdentifier isEqualToString:identifier], @"malu" );
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (section == expressionSection)
    {
        if (row == writtingExpressionCellRow)
        {
            SWExpressionCell *expressionCell = (id)cell;
            //expressionCell.expressionTextView.delegate = self;
            expressionCell.delegate = self;
            
            BOOL overlay = [_editingIndexPath isEqual:indexPath];
            [expressionCell.expressionTextView setOverlay:overlay];
            
            __block SWExpression *firstExpression = nil;
            
            NSString *sourceStr = [self _primitiveStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
            {
                SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
                SWExpression *writeExpr = node.writeExpression;

                if (firstExpression == nil)
                    firstExpression = writeExpr;
            
                block_return [writeExpr getSourceString];
            }];
            
            if (sourceStr == MultipleValuesText)
            {
                expressionCell.value = nil;
                expressionCell.expressionTextView.smartText = [self _multipleValuesTextFromText:sourceStr];
                expressionCell.valuePropertyLabel.text = firstExpression.property;
            }
            else
            {
                expressionCell.value = firstExpression;
            }
            
//            NSString *nameStr = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
//                                 {
//                                     SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
//                                     block_return [node name];
//                                 }];
//            
//            expressionCell.valuePropertyLabel.text = nameStr;
        }
    }
    
    else
    {
        SWSourceFieldCell *fieldCell = (id)cell;
        SWTextField *textField = fieldCell.textField;
        textField.delegate = self;
        textField.enabled = YES;

        if (section == plcTagSection)
        {
            if (row == addressCellRow)
            {
                fieldCell.detailLabel.text = NSLocalizedString(@"Address", nil);
                textField.smartText = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
                {
                    SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
                    block_return [node.plcTag addressAsString];
                }];
            }
            else if (row == typeSCellRow)
            {
                fieldCell.detailLabel.text = NSLocalizedString(@"Type", nil);
                textField.smartText = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
                {
                    SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
                    block_return [node.plcTag typeAsString];
                }];
            
            }
//            else if (row == typeCellRow)
//            {
//                fieldCell.detailLabel.text = NSLocalizedString(@"Type", nil);
//                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                textField.smartText = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
//                                       {
//                                           SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
//                                           block_return [node.plcTag tagTypeAsString];
//                                       }];
//                textField.enabled = NO;
//            }
//            else if (row == arraySizeCellRow)
//            {
//                fieldCell.detailLabel.text = NSLocalizedString(@"Array Size", nil);
//                textField.smartText = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
//                                       {
//                                           SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
//                                           block_return [NSString stringWithFormat:@"%d", [node.plcTag arraySize /*collectionCount*/]];
//                                       }];
//            }
        }
        
        else if (section == extraSection )
        {
            if ( _sourceItem.protocol == kProtocolTypeModbus )
            {
                if (row == modbusSlaveRow)
                {
                    fieldCell.detailLabel.text = NSLocalizedString(@"Slave id", nil);
                    textField.smartText = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
                    {
                        SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
                        block_return [NSString stringWithFormat:@"%d", node.plcTag->leadingCode];
                    }];
                }
            }
        }
        
        else if (section == scalingSection)
        {
            if (row == rawMinValueCellRow)
            {
                fieldCell.detailLabel.text = NSLocalizedString(@"Raw Min Value", nil);
                textField.smartText = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
                {
                    SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
                    block_return [NSString stringWithFormat:@"%g", node.plcTag->scale.rmin];
                }];
            }
            else if (row == rawMaxValueCellRow)
            {
                fieldCell.detailLabel.text = NSLocalizedString(@"Raw Max Value", nil);
                textField.smartText = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
                {
                    SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
                    block_return [NSString stringWithFormat:@"%g", node.plcTag->scale.rmax];
                }];
            }
            else if (row == engineeringMinValueCellRow)
            {
                fieldCell.detailLabel.text = NSLocalizedString(@"Engineering Min Value", nil);
                textField.smartText = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
                {
                    SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
                    block_return [NSString stringWithFormat:@"%g", node.plcTag->scale.emin];
                }];
            }
            else if (row == engineeringMaxValueCellRow)
            {
                fieldCell.detailLabel.text = NSLocalizedString(@"Engineering Max Value", nil);
                textField.smartText = [self _getStringValueUsingBlock:^NSString *(SWSourceItem *source, NSUInteger i)
                {
                    SWSourceNode *node = [source.sourceNodes objectAtIndex:i];
                    block_return [NSString stringWithFormat:@"%g", node.plcTag->scale.emax];
                }];
            }
        }
    }
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
//    if (section == variableSection)
//        return nil;
//    
//    else
    if (section == expressionSection)
        title = NSLocalizedString(@"WRITING EXPRESSION", nil);
    
    else if (section == plcTagSection)
        title = NSLocalizedString(@"TAG DESCRIPTION", nil);
    
    else if (section == extraSection)
    {
//        if ( _sourceItem.protocol == kProtocolTypeModbus)
//            title = NSLocalizedString(@"PROTOCOL SPECIFIC PROPERTIES", nil);
    }
    
    else if (section == scalingSection)
        title = NSLocalizedString(@"SCALING", nil);
    
    SWTableSectionHeaderView *tvh = [[SWTableSectionHeaderView alloc] init];
    tvh.title = title;
    
    return tvh;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 30;
    if ( section == extraSection )
    {
        //if ( _sourceItem.protocol != kProtocolTypeModbus)
            height = 0;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == expressionSection && indexPath.row == writtingExpressionCellRow)
        return 102;
    
    return 44;
}

#pragma mark TableView Delegate

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *returnIndexPath = nil;
    
//    if (indexPath.section == plcTagSection && indexPath.row == typeCellRow)
//        returnIndexPath = indexPath;
    
    return returnIndexPath;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:0.96f alpha:1.0f]];
    
    if ( [cell respondsToSelector:@selector(beginObservingModel)] )
    {
        [(id)cell beginObservingModel];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [cell respondsToSelector:@selector(endObservingModel)] )
    {
        [(id)cell endObservingModel];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
//    if (section == plcTagSection && row == typeCellRow)
//    {
//        NSArray *options = [SWPlcTag tagTypesArray];
//        SWTableSelectionController *tsc = [[SWTableSelectionController alloc] initWithStyle:UITableViewStylePlain options:options];
//        tsc.delegate = self;
//        tsc.swtag1 = row;
//        tsc.title = NSLocalizedString(@"Choose Type",nil);
//        
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        
//        if ([cell isKindOfClass:[SWSourceFieldCell class]])
//        {
//            SWSourceFieldCell *fieldCell = (SWSourceFieldCell*)cell;
//            UITextField *textField = fieldCell.textField;
//            tsc.swselectedOptionIndex = [options indexOfObject:textField.text];
//        }
//        
////        _viewWillDisappearToReturn = YES;
////        [self.navigationController pushViewController:tsc animated:YES];
//
//
//        [tsc setContentSizeForViewInPopover:CGSizeMake(200,310)];
//        _popover = [[UIPopoverController alloc] initWithContentViewController:tsc];
//        _popover.delegate = self;
//        [_popover presentPopoverFromRect:CGRectMake(320-44,0,44,44) inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_rightButton dismisInfoMessageAnimated:YES];
}

/*
if (section == expressionSection)
{
    if (row == writtingExpressionCellRow)
    {
        
    }
}
else if (section == variableSection)
{
    if (row == identifierCellRow)
    {
        
    }
}
else if (section == plcTagSection)
{
    if (row == addressCellRow)
    {
        
    }
    else if (row == typeCellRow)
    {
        
    }
    else if (row == arraySizeCellRow)
    {
        
    }
}
else if (section == scalingSection)
{
    if (row == rawMinValueCellRow)
    {
        
    }
    else if (row == rawMaxValueCellRow)
    {
        
    }
    else if (row == engineeringMinValueCellRow)
    {
        
    }
    else if (row == engineeringMaxValueCellRow)
    {
        
    }
}
*/

@end