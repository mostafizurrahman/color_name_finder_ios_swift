//
//  ViewController.h
//  ColorMagic
//
//  Created by Mostafizur Rahman on 9/16/17.
//  Copyright © 2017 Mostafizur Rahman. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCFilterGLView.h"
//#import "BCColorPickerView.h"
@interface CMFilterViewController : UIViewController
    
    @property (weak, nonatomic) IBOutlet BCFilterGLView *drawing_glk_view;
    //@property (weak, nonatomic) IBOutlet BCColorPickerView *colorPickerView;
    @property (weak, nonatomic) IBOutlet UISlider *slider;
    @property (readwrite, weak) UIImage *sourceImage;

@end

