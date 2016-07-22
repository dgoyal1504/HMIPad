//
//  SWConfigurationController.m
//  HmiPad
//
//  Created by Joan Martin on 8/28/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWConfigurationController.h"

//#import "SWFloatingPopoverManager.h"
#import "SWColor.h"

#import "SWObject.h"
#import "SWSystemItem.h"
#import "SWSourceItem.h"
#import "SWSourceNode.h"

#import "RoundedTextView.h"
#import "RoundedTextViewDelegate.h"
#import "SWTableFieldsController.h"
#import "SWTableFieldsControllerDelegate.h"
#import "SWExpressionInputController.h"
#import "SWModelManager.h"


// -- Subclasses --
#import "SWObjectConfiguratorController.h"
#import "SWSourceItemConfiguratorController.h"
#import "SWNodeConfiguratorController.h"

//static NSDictionary *_objectConfigurators = nil;


@interface SWConfigurationController()<SWExpressionInputControllerDelegate,UITextFieldDelegate,RoundedTextViewDelegate>

@end


@implementation SWConfigurationController
{
}

+ (SWConfigurationController*)configuratorForObject:(SWObject*)object
{
    Class ConfiguratorController = [self configuratorClassForObject:object];
    
    if (!ConfiguratorController)
        return nil;
    
    SWConfigurationController *confController = [[ConfiguratorController alloc] initWithConfiguringObject:object];
    
    if ( [object isKindOfClass:[SWSystemItem class]] )
        confController.notEditableName = YES;
    
    return confController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithConfiguringObject:nil];
}

- (id)initWithConfiguringObject:(id)object
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _configuringObjectInstance = object;
    }
    return self;
}

#pragma mark view lifecycle


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_rightButton stopWithCancel:YES animated:NO];
}


- (void)dealloc
{
    SWExpressionInputController *inputController = _modelManager.inputController;
    if (inputController.delegate == self)
        inputController.delegate = nil;
}


#pragma mark Private Methods

+ (Class)configuratorClassForObject:(id)object
{
    static NSArray *_objectConfigurators = nil;
    if (!_objectConfigurators)
    {
        _objectConfigurators = @[
            [SWSourceItem class], [SWSourceItemConfiguratorController class],
            [SWObject class], [SWObjectConfiguratorController class],
            [SWSourceNode class], [SWNodeConfiguratorController class]
        ];
    }

    if ([object isKindOfClass:[NSArray class]]) //<------ Si object és un array, agafarem qualsevol objecte contingut per a buscar el configurador
        object = [(NSArray*)object lastObject];
        
    NSInteger count = _objectConfigurators.count;
    for (NSInteger i=0; i<count; i+=2)
    {
        if ([object isKindOfClass:[_objectConfigurators objectAtIndex:i]])
            return [_objectConfigurators objectAtIndex:i+1];
    }
    
//    NSAssert(NO, @"Unsupported object to configure");
    NSLog(@"[uj231z] WARNING: NO EXISTING CONFIGURATOR FOR OBJECT CLASS <%@>. NOTHING WILL HAPPEN.", [[object class] description]);
    return nil;
}



#pragma mark RoundedTextViewDelegate

- (BOOL)roundedTextViewShouldReturn:(RoundedTextView *)roundedTextView
{
    [_rightButton stopWithCancel:NO animated:YES];
    return YES;
}

- (BOOL)roundedTextViewShouldBeginEditing:(RoundedTextView *)roundedTextView
{
    SWExpressionInputController *inputController = _modelManager.inputController;
    
    BOOL shouldBegin = [inputController shouldPrepareForTextResponder:roundedTextView];
    return shouldBegin;
}

- (void)roundedTextViewDidBeginEditing:(RoundedTextView *)roundedTextView
{
    [self.rightButton startAnimated:YES];
    
    RoundedTextView *currentTextView = (id)[_rightButton currentTextResponder];
    if ( [currentTextView respondsToSelector:@selector(setOverlay:)] )
        [currentTextView setOverlay:NO];
    
    [_rightButton recordTextResponder:roundedTextView];

    SWExpressionInputController *inputController = _modelManager.inputController;
    inputController.delegate = self;
    
    [inputController setTextResponder:roundedTextView];
    [_modelManager dismissModelSeekerFromControllerWithIdentifier:nil animated:YES];

    _editingIndexPath = [_rightButton indexPathforTextResponder:roundedTextView];
    [roundedTextView setOverlay:YES];
}

- (void)roundedTextViewDidEndEditing:(RoundedTextView *)roundedTextView
{
}

- (void)roundedTextViewDidChange:(RoundedTextView *)textView
{
}



#pragma mark - UITextFieldField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_rightButton stopWithCancel:NO animated:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.rightButton startAnimated:YES];
    
    RoundedTextView *currentTextView = (id)[_rightButton currentTextResponder];
    if ( [currentTextView respondsToSelector:@selector(setOverlay:)] )
        [currentTextView setOverlay:NO];
    
    [_rightButton recordTextResponder:textField];
    
    [_modelManager.inputController resignResponder];
    [_modelManager dismissModelSeekerFromControllerWithIdentifier:nil animated:YES];
    
    _editingIndexPath = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}


#pragma mark - SWExpressionInputControllerDelegate

- (void)expressionInputControllerApply:(SWExpressionInputController*)controller
{
    [_rightButton stopWithCancel:NO animated:YES];
}

- (void)expressionInputControllerCancel:(SWExpressionInputController*)controller
{
    [_rightButton stopWithCancel:YES animated:YES];
}



#pragma mark - SWTableFieldsController delegate and auxiliar methods

- (SWTableFieldsController *)rightButton
{
    if (_rightButton == nil)
        _rightButton = [[SWTableFieldsController alloc] initWithOwner:self];
    
    return _rightButton;
}

- (void)tableFieldsController:(SWTableFieldsController*)controller didProvideControl:(UIControl*)aControl animated:(BOOL)animated
{
    UIBarButtonItem *barItem = nil;
    
    if (aControl)
    {
        barItem = [[UIBarButtonItem alloc] initWithCustomView:aControl];
        _rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    }
    else
    {
        barItem = _rightBarButtonItem;
    }
    [self.navigationItem setRightBarButtonItem:barItem animated:animated];
}

- (void)tableFieldsControllerWillStopWithCancel:(BOOL)cancel
{
    RoundedTextView *currentTextView = (id)[_rightButton currentTextResponder];
    if ( [currentTextView respondsToSelector:@selector(setOverlay:)] )
        [currentTextView setOverlay:NO];
    
    _editingIndexPath = nil;
}




- (BOOL)tableFieldsController:(SWTableFieldsController*)controller validateField:(id)field forCell:(UITableViewCell*)cell
    atIndexPath:(NSIndexPath*)indexPath outErrorString:(NSString **)errorString
{
    // to override (no need to call super)
    return YES;
}

- (void)tableFieldsControllerApply:(SWTableFieldsController*)controller animated:(BOOL)animated
{
    // override and call supper
    [_modelManager.inputController resignResponder];
}

- (void)tableFieldsControllerCancel:(SWTableFieldsController *)controller animated:(BOOL)animated
{
    [_modelManager.inputController resignResponder];
}
























@end
