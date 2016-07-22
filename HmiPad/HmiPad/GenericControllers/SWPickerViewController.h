//
//  SWPickerViewController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/16/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    id <UIPickerViewDataSource> _dataSource;
    id <UIPickerViewDelegate> _delegate;
    
    NSArray *_initialState;
}

- (id)initWithPickerDataSource:(id<UIPickerViewDataSource>)dataSource andPickerDelegate:(id<UIPickerViewDelegate>)delegate;

- (void)setInitialStateForPickerView:(NSArray*)initialState;

@property (readonly) CGFloat pickerViewHeight;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@end
