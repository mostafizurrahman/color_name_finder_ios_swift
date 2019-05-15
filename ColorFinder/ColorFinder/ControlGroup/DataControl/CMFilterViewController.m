//
//  ViewController.m
//  ColorMagic
//
//  Created by Mostafizur Rahman on 9/16/17.
//  Copyright © 2017 Mostafizur Rahman. All rights reserved.
//



#import "CMFilterViewController.h"
#import "BCBaseFilterData.h"


@interface CMFilterViewController () {
    
}
@end

@implementation CMFilterViewController
@synthesize slider;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.drawing_glk_view setDrawingExtent];
    [self.drawing_glk_view setSourceImage:self.sourceImage];
    [self setSliders];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}


-(void)setSliders{
    
    for(id data in self.drawing_glk_view.filterParamArray){
        if([data isKindOfClass:[BCBaseFilterData class]]){
            BCBaseFilterData *bdata = (BCBaseFilterData *)data;
            [slider setMaximumValue:bdata.maximum_value];
            [slider setMinimumValue:bdata.minimun_value];
            [slider setValue:bdata.default_value];
            slider.restorationIdentifier = bdata._key;
        }
    }
}

-(IBAction)changeSliderValue:(UISlider *)sender{
    [self.drawing_glk_view onSliderValueChanged:sender];
}




//+(CGRect)getViewRect:(const CGSize)image_size
//      parentViewSize:(const CGSize)parent_view_size
//   withPaddingOffset:(const CGFloat)offset {
//    CGRect color_pop_rect;
//    const CGFloat image_ratio = image_size.width / image_size.height;
//    if(image_ratio < 1.f){
//        CGFloat origin_y = offset;
//        CGFloat height = parent_view_size.height - offset * 2.f;
//        CGFloat width = height * image_ratio;
//        if(width > parent_view_size.width - 2 * offset){
//            width = parent_view_size.width - 2 * offset;
//            height = width / image_ratio;
//            origin_y = parent_view_size.height / 2 - height / 2;
//            color_pop_rect = CGRectMake(offset, origin_y, width, height);
//        } else {
//            const CGFloat origin_x = parent_view_size.width / 2 - width / 2;
//            color_pop_rect = CGRectMake(origin_x, origin_y, width, height);
//        }
//    } else {
//        CGFloat origin_x = offset;
//        CGFloat width = parent_view_size.width - offset * 2.f;
//        CGFloat height = width / image_ratio;
//        if(height > parent_view_size.height - 2 * offset){
//            height = parent_view_size.height - 2 * offset;
//            width = height * image_ratio;
//            origin_x = parent_view_size.width / 2 - width / 2;
//            color_pop_rect = CGRectMake(origin_x, offset, width, height);
//        } else {
//            const CGFloat origin_y = parent_view_size.height / 2 - height / 2;
//            color_pop_rect = CGRectMake(origin_x, origin_y, width, height);
//        }
//    }
//    return color_pop_rect;
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
