//
//  SWSourceDetailsController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWSourceItemConfiguratorController.h"

#import "SWSourceItem.h"
#import "SWPropertyDescriptor.h"
#import "SWTableSelectionController.h"
#import "SWTableFieldsControllerDelegate.h"

#import "SWModelManager.h"
//#import "SWExpressionInputController.h"
#import "SWSourceItem.h"

#import "SWSourceFieldCell.h"
#import "SWExpressionCell.h"
#import "SWNavBarTitleView.h"

#import "SWTableViewMessage.h"
#import "SWIdentifierHeaderView.h"
#import "SWTableView.h"

#import "SWSourceItem.h"
#import "SWPlcDevice.h"
#import "SWDocumentModel.h"
#import "RpnBuilder.h"
#import "SWColor.h"

#import "SWTableFieldsController.h"
#import "SWTableSectionHeaderView.h"

#import "RoundedTextView.h"
#import "SWKeyboardListener.h"

#import "FPPopoverController.h"

//static NSString *titleCellIdentifier = @"titleCellIdentifier";
//static NSString *sourceFieldCellIdentifier = @"SourceFieldCellIdentifier";

enum
{
    SWSectionConfiguration,
    SWSectionProtocolExtras,
    SWSectionCount
};

enum
{
    SWCellRowProtocol = 0,
    SWCellRowLocalEx,
    SWCellRowRemoteEx,
    SWCellRowUpdateRate,
    SWCellRowValidationTag,
    SWCellRowValidationCode,
    SWCellRowEncoding,
    SWCellRowConfigurationCount,
    
        SWCellRowLocal,
        SWCellRowRemote,
        SWCellRowLocalPort,
        SWCellRowRemotePort,
};

enum
{
    SWCellRowSiemensS7ControllerSlot = 0,
//    SWCellRowSiemensS7TagLanguage,
    SWCellRowSiementS7Count
};

enum
{
    SWCellRowABEIPControllerSlot = 0,
    SWCellRowABEIPConnectedMode,
    SWCellRowABEIPCount
};

enum
{
    SWCellRowABPCCCConnectedMode = 0,
    SWCellRowABPCCCCount
};

enum
{
    SWCellRowModbusRTUMode = 0,
    SWCellRowModbusWordSwap,
    SWCellRowModbusByteSwap,
    SWCellRowModbusStringByteSwap,
    SWCellRowModbusCommandSizeLimit,
    SWCellRowModbusCount
};


@interface SWSourceItemConfiguratorController()<SWTableSelectionControllerDelegate>
@end

@interface SWSourceItemConfiguratorController (CustomObservation)<SourceItemObserver>
@end

@interface SWSourceItemConfiguratorController (CustomDelegates)<SWTableFieldsControllerDelegate,SWExpressionCellDelegate,SWModelManagerDelegate, SWModelManagerDataSource/*, RoundedTextViewDelegate,UITextFieldDelegate*//*,SWExpressionInputControllerDelegate*/>
@end

@interface SWSourceItemConfiguratorController (UIProtocols)<UIPopoverControllerDelegate,FPPopoverControllerDelegate>
@end


@interface SWSourceItemConfiguratorController()

@end


@implementation SWSourceItemConfiguratorController
{
    //__weak SWModelManager *_modelManager;
    //UIBarButtonItem *_rightBarButtonItem;
    SWNavBarTitleView *_titleView;
    UIPopoverController *_popover;
    FPPopoverController *_fpPopover;
    BOOL _updatingValue;
}

@synthesize tableView = _tableView;

- (id)initWithConfiguringObject:(SWSourceItem*)object
{
    self = [super initWithConfiguringObject:object];
    if (self)
    {
        //self.title = NSLocalizedString(@"Configuration",nil);
        _sourceItem = _configuringObjectInstance;
        _modelManager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_sourceItem.docModel];
        
        self.title = [NSString stringWithFormat:@"%@",object.identifier];
        _titleView = [[SWNavBarTitleView alloc] init];
        _titleView.secondaryLabel.text = NSLocalizedString(@"PLC Configurator", nil);
        _titleView.mainLabel.text = self.title;
        [_titleView sizeToFit];
        self.navigationItem.titleView = _titleView;
        
        //self.contentSizeForViewInPopover = CGSizeMake(320, 480);
        self.preferredContentSize = CGSizeMake(320, 480);
        //_viewWillDisappearToReturn = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView
{
    //[super loadView];
    
//    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,100,100) style:UITableViewStylePlain];
    UITableView *tableView = [[SWTableView alloc] initWithFrame:CGRectMake(0,0,100,100) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    self.view = tableView;
    _tableView = tableView;
    
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
    
    [_tableView setBackgroundColor:[UIColor colorWithWhite:0.90f alpha:1.0]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    SWTableViewMessage *messageView = [[SWTableViewMessage alloc] initForTableFooter];
    [messageView setMessage:NSLocalizedString(@"SourceItemConfigurationFooter", nil)];
    [messageView setEmptyTitle:NSLocalizedString(@"No Values", nil)];
    
    [_tableView setTableFooterView:messageView];
    //NSLog( @"tableViewVDL:\n%@\n", _tableView );
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog( @"tableViewVWA:\n%@", _tableView );

    [super viewWillAppear:animated];
    
    
    NSString *identifier = _sourceItem.identifier;
    _identifierHeaderView.textField.text = identifier;
    
    [_sourceItem addObjectObserver:self];
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[_rightButton stopWithCancel:YES animated:NO];
    
    [_sourceItem removeObjectObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}





#pragma mark - PLC Protocol Dependent Extras (private)

static NSString *_stringForBool(BOOL value)
{
    if ( value )
        return NSLocalizedString(@"YES",nil);
    
    return NSLocalizedString(@"NO",nil);
}

static BOOL _boolForString(NSString *string)
{
    return ( NSOrderedSame == [string caseInsensitiveCompare:_stringForBool(YES)] );
}

static NSString *_stringForLanguage(BOOL value)
{
    if ( value )
        return NSLocalizedString(@"English",nil);
    
    return NSLocalizedString(@"German",nil);
}

static BOOL _languageForString(NSString *string)
{
    return ( NSOrderedSame == [string caseInsensitiveCompare:_stringForLanguage(YES)] );
}


//- (void)template
//{
//    switch ( _sourceItem.protocol )
//    {
//        case kProtocolTypeEIP:
//            break;
//            
//        case kProtocolTypeEIP_PCCC:
//            break;
//            
//        case kProtocolTypeMelsec:
//            break;
//            
//        case kProtocolTypeModbus:
//            break;
//            
//        case kProtocolTypeOmronFins:
//            break;
//            
//        case kProtocolTypeOptoForth:
//            break;
//            
//        case kProtocolTypeSiemensISO_TCP:
//            break;
//            
//        default:
//            break;
//    }
//}

@end




#pragma mark - Protocol Custom Observation

@implementation SWSourceItemConfiguratorController (CustomObservation)

#pragma mark - SWObjectObserver

- (void)identifierDidChangeForObject:(SWObject *)object 
{
    NSString *identifier = object.identifier;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:SWCellRowIdentifier inSection:0];
//    SWSourceFieldCell *fieldCell = (SWSourceFieldCell*)[_tableView cellForRowAtIndexPath:indexPath];  // JLZ - fieldCell sera nil si no es visible
//    if (fieldCell)
//    {
//        UITextField *textField = fieldCell.textField;
//        textField.text = identifier;
//    }
//    
//    self.title = identifier;
//    _titleView.mainLabel.text = identifier;
//    [_titleView sizeToFit];
    
    _identifierHeaderView.textField.smartText = identifier;
    self.title = identifier;
    _titleView.mainLabel.text = identifier;
    [_titleView sizeToFit];
}


- (void)willRemoveObject:(SWObject *)object
{
    //[_modelManager removeModelConfiguratorForObject:_sourceItem animated:YES presentingControllerKey:nil];
    [_modelManager removeModelConfiguratorFromControllerWithIdentifier:nil forObject:_sourceItem animated:YES];
}

#pragma mark - SourceItemObserver

- (void)plcDeviceDidChange:(SWPlcDevice*)plcDevice
{
    UITableView *table = _tableView;
    //[table reloadRowsAtIndexPaths:[table indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    [table reloadData];  // aqui
}

@end


#pragma mark - Protocol Custom Delegates

@implementation SWSourceItemConfiguratorController (CustomDelegates)


#pragma mark - extras private

- (BOOL)_extrasTableFieldsControllerApplyCellWrapper:(SWCellWrapper*)cellWrap options:(NSInteger*)options
{
    BOOL optionsChange = NO;
    SWSourceFieldCell *cell = (id)cellWrap->cell;
    NSString *text =  cell.textField.text;
    NSInteger row = cellWrap->indexPath.row;
    switch ( _sourceItem.protocol )
    {
        case kProtocolTypeEIP:
            switch ( row )
            {
                case SWCellRowABEIPControllerSlot:
                    *options &= ~kPlcEIPSlotNumberMask;
                    *options |= [text integerValue]&kPlcEIPSlotNumberMask;
                    optionsChange = YES;
                    break;
                    
                case SWCellRowABEIPConnectedMode:
                    *options &= ~kPlcEIPConnected;
                    *options |= _boolForString(text)?kPlcEIPConnected:0;
                    optionsChange = YES;
                    break;
            }
            break;
            
        case kProtocolTypeEIP_PCCC:
            switch ( row )
            {
                case SWCellRowABPCCCConnectedMode:
                    *options &= ~kPlcEIPConnected;
                    *options |= _boolForString(text)?kPlcEIPConnected:0;
                    optionsChange = YES;
                    break;
            }
            break;
            
        case kProtocolTypeMelsec:
            break;
            
        case kProtocolTypeModbus:
            switch ( row )
            {
                case SWCellRowModbusRTUMode:
                    *options &= ~kPlcModbusRtuFlag;
                    *options |= _boolForString(text)?kPlcModbusRtuFlag:0;
                    optionsChange = YES;
                    break;
                    
                case SWCellRowModbusWordSwap:
                    *options &= ~kPlcModbusWordSwapType;
                    *options |= _boolForString(text)?kPlcModbusWordSwapType:0;
                    optionsChange = YES;
                    break;
                
                case SWCellRowModbusByteSwap:
                    *options &= ~kPlcModbusByteSwapType;
                    *options |= _boolForString(text)?kPlcModbusByteSwapType:0;
                    optionsChange = YES;
                    break;
                    
                case SWCellRowModbusStringByteSwap:
                    *options &= ~kPlcModbusStringByteSwapType;
                    *options |= _boolForString(text)?kPlcModbusStringByteSwapType:0;
                    optionsChange = YES;
                    break;
                    
                case SWCellRowModbusCommandSizeLimit:
                    *options &= ~kPlcModbusCommandSizeLimitMask;
                    *options |= ([text integerValue]<<8)&kPlcModbusCommandSizeLimitMask;
                    optionsChange = YES;
            }
            break;
            
        case kProtocolTypeOmronFins:
            break;
            
        case kProtocolTypeOptoForth:
            break;
            
        case kProtocolTypeSiemensISO_TCP:
            switch (row)
            {
                case SWCellRowSiemensS7ControllerSlot:
                    *options &= ~(kPlcS7SlotNumberMask|kPlcS7RackNumber);
                    *options |= [text integerValue]&(kPlcS7SlotNumberMask|kPlcS7RackNumber);
                    optionsChange = YES;
                    break;
                    
//                case SWCellRowSiemensS7TagLanguage:
//                    *options = ~kPlcS7English;
//                    *options |= _languageForString(text)?kPlcS7English:0;
//                    optionsChange = YES;
//                    break;
            }
            break;
            
        default:
            break;
    }

    return optionsChange;
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
        [_modelManager showModelPickerOnPresentingControllerWithIdentifier:nil forObject:_sourceItem withValue:value context:indexPath delegate:self dataSource:self animated:YES];
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





#pragma mark - SWTableFieldsController delegate and auxiliar methods


- (BOOL)tableFieldsController:(SWTableFieldsController*)controller validateField:(id)field forCell:(UITableViewCell*)cell
    atIndexPath:(NSIndexPath*)indexPath outErrorString:(NSString **)errorString
{
    BOOL valid = YES;
    
    
    NSString *cellIdentifier = cell.reuseIdentifier;
    NSString *text = [(UITextField*)field text];
    
    if ([text isEqualToString:@""] && field != _identifierHeaderView.textField /*_identifierView.identifierField*/)
        return  YES;
    
    if ( field == _identifierHeaderView.textField )
    {
        valid = [SWObject isValidIdentifier:text outErrString:errorString];
    }
    else if ([cellIdentifier isEqualToString:ExpressionCellIdentifier] )
    {
        RpnBuilder *builder = _sourceItem.docModel.builder;
        valid = [RpnBuilder isValidExpressionSource:text forBuilderInstance:builder outErrString:errorString];
    }

// TO DO
    
    else
    {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        switch (section)
        {
            case SWSectionConfiguration:
        
                switch (row)
                {
                    case SWCellRowProtocol:
                        break;
                    
                    case SWCellRowLocal:
                        break;
                    
                    case SWCellRowRemote:
                        break;
                    
                    case SWCellRowLocalPort:
                        break;
                    
                    case SWCellRowRemotePort:
                        break;
                    
                    case SWCellRowUpdateRate:
                        break;
                    
                    case SWCellRowValidationTag:
                        valid = [SWPlcDevice isValidValidationTagString:text forProtocol:_sourceItem.protocol outErrorString:errorString];
                        break;
                    
                    case SWCellRowValidationCode:
                        break;
                    
                    case SWCellRowEncoding:
                        break;
                    
                    default:
                        break;
                }
                break;
        
            case SWSectionProtocolExtras:
                break;
        
            default:
                break;
        }
    }

    
    return valid;
}



- (void)tableFieldsControllerApply:(SWTableFieldsController*)controller animated:(BOOL)animated
{
    //SWPlcDevice *plcDevice = self.configuringObject.plcDevice;
    NSArray *cellWrappers = [controller cellWrappers];
    
    NSString *localIPExtStr = nil;
    NSString *remoteHostExtStr = nil;
    
    NSString *protocolStr = nil;
    NSString *localHostStr = nil;
    NSString *remoteHostStr = nil;
    NSString *localPortStr = nil;
    NSString *remotePortStr = nil;
    NSString *validationTagIdStr = nil;
    NSString *validationCodeStr = nil;
    NSString *encodingStr = nil;
    
    BOOL deviceChange = NO;
    BOOL optionsChange = NO;
    NSInteger options = _sourceItem.plcDevice->options;
    
    for (SWCellWrapper *cellWrap in cellWrappers)
    {
        NSInteger section = cellWrap->indexPath.section;
        NSInteger row = cellWrap->indexPath.row;
        
        NSString *cellIdentifier = cellWrap->cell.reuseIdentifier;
        
        if ([cellIdentifier isEqualToString:ExpressionCellIdentifier])
        {
            SWExpressionCell *exprCell = (id)cellWrap->cell;
                    
            SWExpression *expression = exprCell.value;
            NSString *sourceString = exprCell.expressionTextView.text;
                    
            if ( sourceString.length == 0 )
            {
                SWValue *defaultValue = [expression getDefaultValue];
                sourceString = [defaultValue getSourceString];
            }

            [_sourceItem updateExpression:expression fromString:sourceString];
            NSString *valueAsString = [expression valueAsString];
            
            if ( expression == _sourceItem.localIPExpression )
                localIPExtStr = valueAsString;
            
            if ( expression == _sourceItem.remoteHostExpression )
                remoteHostExtStr = valueAsString;
            
            deviceChange = YES;
        }
        
        else
        {
            SWSourceFieldCell *cell = (id)cellWrap->cell;
            NSString *text =  cell.textField.text;
            switch (section)
            {
                case SWSectionConfiguration:
                    switch (row)
                    {
                        case SWCellRowProtocol:
                            protocolStr = text;
                            deviceChange = YES;
                            break;
                        case SWCellRowLocal:
                            localHostStr = text;
                            deviceChange = YES;
                            break;
                        case SWCellRowRemote:
                            remoteHostStr = text;
                            deviceChange = YES;
                            break;
                        case SWCellRowLocalPort:
                            localPortStr = text;
                            deviceChange = YES;
                            break;
                        case SWCellRowRemotePort:
                            remotePortStr = text;
                            deviceChange = YES;
                            break;
                        case SWCellRowUpdateRate:
                            [_sourceItem setPollRate:[text intValue]];
                            break;
                        case SWCellRowValidationTag:
                            validationTagIdStr = text;
                            deviceChange = YES;
                            break;
                        case SWCellRowValidationCode:
                            validationCodeStr = text;
                            deviceChange = YES;
                            break;
                        case SWCellRowEncoding:
                            encodingStr = text;
                            deviceChange = YES;
                            break;
                    
                        default:
                            break;
                    }
                    break;
             
                case SWSectionProtocolExtras:
                    optionsChange = [self _extrasTableFieldsControllerApplyCellWrapper:cellWrap options:&options];
                    break;
            
                default:
                    break;
            }
        }
    }
    
    if ( deviceChange || optionsChange )
    {
        SWPlcDevice *plcDevice = [_sourceItem.plcDevice newDevice];
        
        if (localIPExtStr) [plcDevice setLocalHostExtAsString:localIPExtStr];
        if (remoteHostExtStr) [plcDevice setRemoteHostExtAsString:remoteHostExtStr];
    
        if (protocolStr) [plcDevice setProtocolAsString:protocolStr];
        if (localHostStr) [plcDevice setLocalHost:localHostStr];
        if (remoteHostStr) [plcDevice setRemoteHost:remoteHostStr];
        if (localPortStr) plcDevice->localPort = [localPortStr intValue];
        if (remotePortStr) plcDevice->remotePort = [remotePortStr intValue];
        if (validationTagIdStr) [plcDevice setValidationTagAsString:validationTagIdStr];
            //[plcDevice setValidationTagId:[validationTagIdStr intValue]];
        
        if (validationCodeStr)
        {
            unsigned int intValue = 0 ;
            [[NSScanner scannerWithString:validationCodeStr] scanHexInt:&intValue] ;
            plcDevice->validationCode = [PlcDevice encriptCode:intValue];
        }
        
        if (encodingStr)
            [plcDevice setEncodingAsString:encodingStr];
        
        if ( optionsChange )
            plcDevice->options = options;
    
        [_sourceItem setPlcDevice:plcDevice];
    }
    
    // Fem el setter de l'identificador, si cal
    if ([controller.textResponders containsObject:_identifierHeaderView.textField])
    {
        [_sourceItem setIdentifier:_identifierHeaderView.textField.text];
    }

    [super tableFieldsControllerApply:controller animated:animated];
}


//#pragma mark - SWExpressionInputControllerDelegate

//- (void)expressionInputControllerApply:(SWExpressionInputController*)controller
//{
//    [_rightButton stopWithCancel:NO animated:YES];
//}

//- (void)expressionInputControllerCancel:(SWExpressionInputController*)controller
//{
//    [_rightButton stopWithCancel:YES animated:YES];
//}



#pragma mark - SWTableSelectionController delegate

- (void)tableSelection:(SWTableSelectionController *)controller didSelectOption:(NSString *)option
{
    NSInteger section = controller.swtag0;
    NSInteger row = controller.swtag1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[SWSourceFieldCell class]])
    {
        SWSourceFieldCell *fieldCell = (SWSourceFieldCell*)cell;
        UITextField *textField = fieldCell.textField;
        
        SWTableFieldsController *rightButton = self.rightButton;
        [rightButton startAnimated:YES];
        [rightButton recordTextResponder:textField];
        textField.text = option;
    }
    
    //[self.navigationController popViewControllerAnimated:YES];

    [_popover dismissPopoverAnimated:YES];
    [_fpPopover dismissPopoverAnimated:YES];
    //_popover = nil;
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark Protocol ModelManagerDelegate


- (SWExpression *)_expressionAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    SWExpression *expression = nil;
    if ( section == SWSectionConfiguration )
    {
        switch (row)
        {
            case SWCellRowLocalEx:
                expression = _sourceItem.localIPExpression;
                break;
                    
            case SWCellRowRemoteEx:
                expression = _sourceItem.remoteHostExpression;
                break;
                    
            default:
                expression = nil;
                break;
        }
    }

    return expression;
}


- (SWPropertyDescriptor*)_attributeDescriptionForIndexPath:(NSIndexPath*)indexPath
{
    SWExpression *expression = [self _expressionAtIndexPath:indexPath];
    SWPropertyDescriptor *descriptor = [expression valueDescription];
    return descriptor;
}


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
            [_sourceItem updateExpression:expression fromString:bindableValue];
        }
        else if ( propertyType == SWPropertyTypeValue )
        {
            SWValue *theValue = configuringCell.value;
            SWValue *newValue = [_sourceItem.builder valueWithSourceString:bindableValue outErrString:nil];
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


#pragma mark - UI Protocols

@implementation SWSourceItemConfiguratorController (UIProtocols)


#pragma mark - extras private

- (NSInteger)_extrasRowCount
{
    NSInteger extrasRowCount = 0;
    switch ( _sourceItem.protocol )
    {
        case kProtocolTypeEIP:
            extrasRowCount = SWCellRowABEIPCount;
            break;
            
        case kProtocolTypeEIP_PCCC:
            extrasRowCount = SWCellRowABPCCCCount;
            break;
        
        case kProtocolTypeMelsec:
            break;
            
        case kProtocolTypeModbus:
            extrasRowCount = SWCellRowModbusCount;
            break;
            
        case kProtocolTypeOmronFins:
            break;
            
        case kProtocolTypeOptoForth:
            break;
            
        case kProtocolTypeSiemensISO_TCP:
            extrasRowCount = SWCellRowSiementS7Count;
            break;
            
        default:
            break;
    }
    return extrasRowCount;
}


- (void)_extrasSetupCell:(SWSourceFieldCell*)fieldCell atRow:(NSInteger)row
{
    SWTextField *textField = fieldCell.textField;
    UILabel *detailLabel = fieldCell.detailLabel;
    SWPlcDevice *plcDevice = _sourceItem.plcDevice;
    switch ( _sourceItem.protocol )
    {
        case kProtocolTypeEIP:
            switch ( row )
            {
                case SWCellRowABEIPControllerSlot:
                    detailLabel.text = NSLocalizedString(@"Controller Slot", nil);
                    textField.smartText = [NSString stringWithFormat:@"%d", plcDevice->options&kPlcEIPSlotNumberMask];
                    textField.placeholder = NSLocalizedString(@"slot number", nil);
                    break;
                    
                case SWCellRowABEIPConnectedMode:
                    fieldCell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    textField.enabled = NO;
                    detailLabel.text = NSLocalizedString(@"Connected Mode", nil);
                    textField.smartText = [NSString stringWithFormat:@"%@", _stringForBool((plcDevice->options&kPlcEIPConnected)!=0)];
                    textField.placeholder = nil;
                    break;
            }
            break;
            
        case kProtocolTypeEIP_PCCC:
            switch ( row )
            {
                case SWCellRowABPCCCConnectedMode:
                    fieldCell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    textField.enabled = NO;
                    detailLabel.text = NSLocalizedString(@"Connected Mode", nil);
                    textField.smartText = [NSString stringWithFormat:@"%@", _stringForBool((plcDevice->options&kPlcEIPConnected)!=0)];
                    textField.placeholder = nil;
                    break;
            }
            break;
            
        case kProtocolTypeMelsec:
            break;
            
        case kProtocolTypeModbus:
            switch ( row )
            {
                case SWCellRowModbusRTUMode:
                    fieldCell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    textField.enabled = NO;
                    detailLabel.text = NSLocalizedString(@"RTU Mode", nil);
                    textField.smartText = [NSString stringWithFormat:@"%@", _stringForBool((plcDevice->options&kPlcModbusRtuFlag)!=0)];
                    textField.placeholder = nil;
                    break;
                    
                case SWCellRowModbusWordSwap:
                    fieldCell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    textField.enabled = NO;
                    detailLabel.text = NSLocalizedString(@"Word Swap", nil);
                    textField.smartText = [NSString stringWithFormat:@"%@", _stringForBool((plcDevice->options&kPlcModbusWordSwapType)!=0)];
                    textField.placeholder = nil;
                    break;
                
                case SWCellRowModbusByteSwap:
                    fieldCell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    textField.enabled = NO;
                    detailLabel.text = NSLocalizedString(@"Byte Swap", nil);
                    textField.smartText = [NSString stringWithFormat:@"%@", _stringForBool((plcDevice->options&kPlcModbusByteSwapType)!=0)];
                    textField.placeholder = nil;
                    break;
                    
                case SWCellRowModbusStringByteSwap:
                    fieldCell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    textField.enabled = NO;
                    detailLabel.text = NSLocalizedString(@"String Byte Swap", nil);
                    textField.smartText = [NSString stringWithFormat:@"%@", _stringForBool((plcDevice->options&kPlcModbusStringByteSwapType)!=0)];
                    textField.placeholder = nil;
                    break;
                    
                case SWCellRowModbusCommandSizeLimit:
                    //detailLabel.text = NSLocalizedString(@"Command Size Limit", nil);
                    detailLabel.text = NSLocalizedString(@"Register Grouping Limit", nil);
                    textField.smartText = [NSString stringWithFormat:@"%d", (plcDevice->options&kPlcModbusCommandSizeLimitMask)>>8];
                    textField.placeholder = NSLocalizedString(@"registers", nil);
                    break;
                    
            }
            break;
            
        case kProtocolTypeOmronFins:
            break;
            
        case kProtocolTypeOptoForth:
            break;
            
        case kProtocolTypeSiemensISO_TCP:
            switch ( row )
            {
                case SWCellRowSiemensS7ControllerSlot:
                    detailLabel.text = NSLocalizedString(@"Controller Slot", nil);
                    textField.smartText = [NSString stringWithFormat:@"%d", plcDevice->options&(kPlcS7SlotNumberMask|kPlcS7RackNumber)];
                    textField.placeholder = NSLocalizedString(@"rack|slot number", nil);
                    break;
                    
//                case SWCellRowSiemensS7TagLanguage:
//                    fieldCell.selectionStyle = UITableViewCellSelectionStyleBlue;
//                    textField.enabled = NO;
//                    detailLabel.text = NSLocalizedString(@"Language Convention", nil);
//                    textField.smartText = [NSString stringWithFormat:@"%@", _stringForLanguage((plcDevice->options&kPlcS7English)!=0)];
            }
            break;
            
        default:
            break;
    }
}



- (NSIndexPath*)_extrasWillSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath *returnIndexPath = nil;
    NSInteger row = indexPath.row;
    switch ( _sourceItem.protocol )
    {
        case kProtocolTypeEIP:
            if ( row == SWCellRowABEIPConnectedMode )
                returnIndexPath = indexPath;
            break;
            
        case kProtocolTypeEIP_PCCC:
            if ( row == SWCellRowABPCCCConnectedMode )
                returnIndexPath = indexPath;
            break;
            
        case kProtocolTypeMelsec:
            break;
        
        case kProtocolTypeModbus:
            switch ( row )
            {
                case SWCellRowModbusRTUMode:
                case SWCellRowModbusWordSwap:
                case SWCellRowModbusByteSwap:
                case SWCellRowModbusStringByteSwap:
                    returnIndexPath = indexPath;
                    break;
            }
            break;
            
        case kProtocolTypeOmronFins:
            break;
            
        case kProtocolTypeOptoForth:
            break;
            
        case kProtocolTypeSiemensISO_TCP:
//            if ( row == SWCellRowSiemensS7TagLanguage )
//                returnIndexPath = indexPath;
            break;
            
        default:
            break;
    }

    return returnIndexPath;
}



- (void)_extrasDidSelectRow:(NSInteger)row outOptions:(NSArray**)options outTitle:(NSString**)title
{
    *options = nil;
    *title = nil;

    switch ( _sourceItem.protocol )
    {
        case kProtocolTypeEIP:
            if ( row == SWCellRowABEIPConnectedMode )
            {
                *options = @[_stringForBool(YES),_stringForBool(NO)];
                *title = NSLocalizedString(@"Connected Mode",nil);
            }
            break;
            
        case kProtocolTypeEIP_PCCC:
            if ( row == SWCellRowABPCCCConnectedMode )
            {
                *options = @[_stringForBool(YES),_stringForBool(NO)];
                *title = NSLocalizedString(@"Connected Mode",nil);
            }
            break;
            
        case kProtocolTypeMelsec:
            break;
            
        case kProtocolTypeModbus:
            switch ( row )
            {
                case SWCellRowModbusRTUMode:
                    *options = @[_stringForBool(YES),_stringForBool(NO)];
                    *title = NSLocalizedString(@"RTU Mode",nil);
                    break;
                    
                case SWCellRowModbusWordSwap:
                    *options = @[_stringForBool(YES),_stringForBool(NO)];
                    *title = NSLocalizedString(@"Word Swap",nil);
                    break;
                
                case SWCellRowModbusByteSwap:
                    *options = @[_stringForBool(YES),_stringForBool(NO)];
                    *title = NSLocalizedString(@"Byte Swap",nil);
                    break;
                    
                case SWCellRowModbusStringByteSwap:
                    *options = @[_stringForBool(YES),_stringForBool(NO)];
                    *title = NSLocalizedString(@"String Byte Swap",nil);
                    break;
            }
            break;
            
        case kProtocolTypeOmronFins:
            break;
            
        case kProtocolTypeOptoForth:
            break;
            
        case kProtocolTypeSiemensISO_TCP:
//            if ( row == SWCellRowSiemensS7TagLanguage )
//            {
//                *options = @[_stringForLanguage(NO),_stringForLanguage(YES)];
//                *title = NSLocalizedString(@"Language Convention",nil);
//            }
            break;
            
        default:
            break;
    }
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SWSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch ( section )
    {
        case SWSectionConfiguration:
            numberOfRows = SWCellRowConfigurationCount;
            break;
            
        case SWSectionProtocolExtras:
            numberOfRows = [self _extrasRowCount];
            break;
    }
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *identifier = nil;
    
    if ( section == SWSectionConfiguration && (row ==  SWCellRowLocalEx || row == SWCellRowRemoteEx) )
        identifier = ExpressionCellIdentifier;
    else
        identifier = SWSourceFieldCellIdentifier;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (_rightButton)
        cell = [_rightButton amendedCellFromCell:cell atIndexPath:indexPath];
    
    if (cell == nil)
    {
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
    
    if ( identifier == ExpressionCellIdentifier )
    {
        SWExpressionCell *expressionCell = (id)cell;
        //expressionCell.expressionTextView.delegate = self;
        expressionCell.delegate = self;
        
        BOOL bOverlay = [_editingIndexPath isEqual:indexPath];
        [expressionCell.expressionTextView setOverlay:bOverlay];
        
        SWExpression *expression = [self _expressionAtIndexPath:indexPath];
        expressionCell.value = expression;
    }
    
    else if ( identifier == SWSourceFieldCellIdentifier)
    {
        SWSourceFieldCell *fieldCell = (SWSourceFieldCell*)cell;
    
        SWTextField *textField = fieldCell.textField;
    
        if (textField.tag != 0)
            return cell;
    
        //textField.delegate = self;
    
        UILabel *detailLabel = fieldCell.detailLabel;
        SWPlcDevice *plcDevice = _sourceItem.plcDevice;
    

    
        CGFloat pointSize = textField.font.pointSize;
    
        fieldCell.accessoryType = UITableViewCellAccessoryNone;
        textField.font = [UIFont systemFontOfSize:pointSize];
        textField.enabled = YES;
        textField.secureTextEntry = NO;
    
        switch (section)
        {
            case SWSectionConfiguration:
        
                switch (row)
                {
                    case SWCellRowProtocol:
                        textField.font = [UIFont boldSystemFontOfSize:pointSize];
                        textField.enabled = NO;
                        detailLabel.text = NSLocalizedString(@"Protocol", nil);
                        textField.smartText = [plcDevice protocolAsString];
                        textField.placeholder = NSLocalizedString(@"Communications Protocol", nil);
                        break;
                    
                    case SWCellRowLocal:
                        detailLabel.text = NSLocalizedString(@"Local", nil);
                        textField.smartText = plcDevice->localHost;
                        textField.placeholder = @"192.168.250.0";
                        break;
                    
                    case SWCellRowRemote:
                        detailLabel.text = NSLocalizedString(@"Remote", nil);
                        textField.smartText = plcDevice->remoteHost;
                        textField.placeholder = @"myserver.dyndns.org";
                        break;
                    
                    case SWCellRowLocalPort:
                        detailLabel.text = NSLocalizedString(@"Local Port", nil);
                        textField.smartText = [NSString stringWithFormat:@"%d", plcDevice->localPort];
                        textField.placeholder = @"502";
                        break;
                    
                    case SWCellRowRemotePort:
                        detailLabel.text = NSLocalizedString(@"Remote Port", nil);
                        textField.smartText = [NSString stringWithFormat:@"%d", plcDevice->remotePort];
                        textField.placeholder = @"502";
                        break;
                    
                    case SWCellRowUpdateRate:
                        detailLabel.text = NSLocalizedString(@"Update Rate", nil);
                        textField.smartText = [NSString stringWithFormat:@"%d", plcDevice->pollRate];
                        textField.placeholder = NSLocalizedString(@"miliseconds", nil);
                        break;
                    
                    case SWCellRowValidationTag:
                        detailLabel.text = NSLocalizedString(@"Validation Tag", nil);
                        textField.smartText = [NSString stringWithFormat:@"%@", [plcDevice validationTagAsString]];
                        textField.placeholder = NSLocalizedString(@"tag", nil);
                        break;
                    
                    case SWCellRowValidationCode:
                        textField.secureTextEntry = YES;
                        detailLabel.text = NSLocalizedString(@"Validation Code", nil);
                        textField.smartText = nil; //[NSString stringWithFormat:@"%d", plcDevice->validationCode];
                        textField.placeholder = NSLocalizedString(@"hex", nil);
                        break;
                    
                    case SWCellRowEncoding:
                        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                        textField.enabled = NO;
                        //fieldCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        detailLabel.text = NSLocalizedString(@"PLC String Encoding", nil);
                        textField.smartText = [plcDevice encodingAsString];
                        textField.placeholder = NSLocalizedString(@"PLC string encoding", nil);
                        break;
                
                    default:
                        break;
                }
            
                break;
            
            case SWSectionProtocolExtras:
            
                [self _extrasSetupCell:fieldCell atRow:row];
                break;
            
            default:
                break;
        }
    }
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = nil;
    switch ( section )
    {
        case SWSectionConfiguration:
        {
            SWTableSectionHeaderView *tvh = [[SWTableSectionHeaderView alloc] init];
            tvh.title = NSLocalizedString(@"PLC CONFIGURATION",nil);
            view = tvh;
            break;
        }
        
        case SWSectionProtocolExtras:
        {
            SWTableSectionHeaderView *tvh = [[SWTableSectionHeaderView alloc] init];
            tvh.title = NSLocalizedString(@"PROTOCOL SPECIFIC PROPERTIES",nil);
            view = tvh;
            break;
        }
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    switch ( section )
    {
        case SWSectionConfiguration:
            height = 30;
            break;
            
        case SWSectionProtocolExtras:
            height = [self _extrasRowCount]>0 ? 30 : 0;
            break;
    }
    
    return height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self _expressionAtIndexPath:indexPath] != nil )
        return 102;
    
    return 44;
}



#pragma mark - Table view delegate

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

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *returnIndexPath = nil;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section)
    {
        case SWSectionConfiguration:
            switch (row)
            {
                case SWCellRowEncoding:
                    returnIndexPath = indexPath;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case SWSectionProtocolExtras:
            returnIndexPath = [self _extrasWillSelectRowAtIndexPath:indexPath];
            break;
    }
    
    return returnIndexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *options = nil;
    NSString *title = nil;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section)
    {
        case SWSectionConfiguration:
            switch (row)
            {
                case SWCellRowEncoding:
                    options = [SWPlcDevice stringEncodingsArray];
                    title = NSLocalizedString(@"String Encoding",nil);
                    break;
                
                default:
                    break;
            }
            break;
            
        case SWSectionProtocolExtras:
            [self _extrasDidSelectRow:row outOptions:&options outTitle:&title];
            break;
            
            
        default:
            break;
    }
    
    if ( options )
    {
        SWTableSelectionController *tsc = [[SWTableSelectionController alloc] initWithStyle:UITableViewStylePlain options:options];
        tsc.delegate = self;
        tsc.swtag0 = section;
        tsc.swtag1 = row;
        tsc.title = title;
        
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        
        if ([cell isKindOfClass:[SWSourceFieldCell class]])
        {
            SWSourceFieldCell *fieldCell = (SWSourceFieldCell*)cell;
            UITextField *textField = fieldCell.textField;
            tsc.swselectedOptionIndex = [options indexOfObject:textField.text];
        }
        
        CGFloat height = 44*options.count - 1;
        if ( height > 290 ) height = 290;
        else [tsc.tableView setScrollEnabled:NO];
        //[tsc setContentSizeForViewInPopover:CGSizeMake(200,height)];
        tsc.preferredContentSize = CGSizeMake(200,height);
        
        if ( IS_IPHONE )
        {
            _fpPopover = [[FPPopoverController alloc] initWithViewController:tsc];
            _fpPopover.border = NO;
            _fpPopover.tint = FPPopoverWhiteTint;
            _fpPopover.delegate = self;
            [_fpPopover presentPopoverFromView:cell];
        }
        else
        {
            _popover = [[UIPopoverController alloc] initWithContentViewController:tsc];
            _popover.delegate = self;
            [_popover presentPopoverFromRect:CGRectMake(320-44,0,44,44) inView:cell
                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

#pragma mark UIPopoverController & FPPopoverController

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popover = nil;
    _fpPopover = nil;
    
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
