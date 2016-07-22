//
//  SWTopFileViewerCell.m
//  HmiPad
//
//  Created by Joan on 14/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWFileViewerSimpleCurrentProjectView.h"
#import "ColoredButton.h"
#import "SWColor.h"

@implementation SWFileViewerSimpleCurrentProjectView
{
    //float _progressValue;
    //NSString *_progressText;
    //BOOL _shouldDissable;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_emptyLabel setTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
    [self setBackgroundColor:[UIColor colorWithWhite:0.98f alpha:1.0f]];
    
//    if ( IS_IOS7 )
//    {
//        [_labelFileName setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
//        [_labelFileIdent setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
//        [_labelModDate setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
//        [_labelSize setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
//    }
}





//-(void)fileViewCellDidTouchUploadButton:(SWTopFileViewerCell*)cell;



- (void)setDisabled:(BOOL)disabled
{
    _disabled = disabled;
    _labelFileName.hidden = disabled;
    _labelFileIdent.hidden = disabled;
    _labelModDate.hidden = disabled;
    _labelSize.hidden = disabled;
    _buttonInclude.hidden = disabled;
    _buttonImage.hidden = disabled;
    _labelPrompt1.hidden = disabled;
    _labelPrompt2.hidden = disabled;

    _emptyLabel.hidden = !disabled;
    
    NSString *text = nil;
    if ( disabled )
        //text = NSLocalizedString(@"FileViewerViewNoProject", nil);
        text = NSLocalizedString(@"You can open a project from the list below", nil);
    
    _emptyLabel.text = text;
    
}

- (IBAction)buttonIncludeTouched:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(simpleCurrentProjectViewDidTouchIncludeButton:)] )
    {
        [_delegate simpleCurrentProjectViewDidTouchIncludeButton:self];
    }
}


- (IBAction)buttonImageTouched:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(simpleCurrentProjectViewDidTouchImageButton:)] )
    {
        [_delegate simpleCurrentProjectViewDidTouchImageButton:self];
    }
}



@end
