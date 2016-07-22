//
//  SWPickerViewController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/16/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWPickerViewController.h"

@implementation SWPickerViewController

@dynamic pickerViewHeight;
@synthesize pickerView = _pickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithPickerDataSource:nil andPickerDelegate:nil];
}

- (id)initWithPickerDataSource:(id<UIPickerViewDataSource>)dataSource andPickerDelegate:(id<UIPickerViewDelegate>)delegate
{
    self = [super initWithNibName:@"SWPickerViewController" bundle:nil];
    if (self)
    {
        _dataSource = dataSource;
        _delegate = delegate;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    if (_dataSource)
    {
        [self.pickerView setDataSource:_dataSource];
    }
    else
    {
        [self.pickerView setDataSource:self];
    }

    if (_delegate)
    {
        [self.pickerView setDelegate:_delegate];
    }
        
    if (_initialState)
    {
        if (_initialState.count == self.pickerView.numberOfComponents)
        {
            for (NSInteger i=0; i<_initialState.count; ++i)
            {
                NSInteger selectedRow = [[_initialState objectAtIndex:i] integerValue];
                if (selectedRow < [self.pickerView numberOfRowsInComponent:i])
                {
                    [self.pickerView selectRow:selectedRow inComponent:i animated:NO];
                }
            }
        }
    }
}

- (void)viewDidUnload
{
    [self setPickerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//	return YES;
//}

#pragma mark - Properties

- (CGFloat)pickerViewHeight
{
    return 300;
}

#pragma mark - Main Methods

- (void)setInitialStateForPickerView:(NSArray*)initialState
{
    _initialState = initialState;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 0;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return nil;
}

@end
