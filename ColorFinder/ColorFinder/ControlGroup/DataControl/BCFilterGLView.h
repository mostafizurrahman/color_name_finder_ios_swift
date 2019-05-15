//
//  BCFilterGLView.h
//  BucketCam
//
//  Created by Mostafizur Rahman on 9/12/17.
//  Copyright © 2017 Mostafizur Rahman. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "BCBaseFilterData.h"


@interface BCFilterGLView : GLKView

@property (readwrite) NSMutableArray *filterParamArray;

-(instancetype)initWithFrame:(CGRect)frame;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)setSourceImage:(UIImage *)source_image;
-(void)setCIFilter:(NSString *)filter_name;
-(void)sliderValueDidChanged:(const CGFloat)current_value
                      forKey:(NSString *)attributeKey;
-(void)setColorData:(FilterColorData *)inputColor;
-(void)setColorComponent:(ColorComponents *)inputCVector;
-(void)setDrawingExtent;
-(void)deleteContext;
-(IBAction)onSliderValueChanged:(UISlider *)sender;
-(UIImage *)getImage;
@end
