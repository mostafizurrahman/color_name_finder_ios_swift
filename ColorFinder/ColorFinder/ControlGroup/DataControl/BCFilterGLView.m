//
//  BCFilterGLView.m
//  BucketCam
//
//  Created by Mostafizur Rahman on 9/12/17.
//  Copyright © 2017 Mostafizur Rahman. All rights reserved.
//

#import "BCFilterGLView.h"

#import <OpenGLES/gltypes.h>

#define MAINSCRN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define MAINSCRN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define MAINSCRN_SCALE [UIScreen mainScreen].scale

@interface BCFilterGLView(){
    CIContext *drawing_context;
    CIImage *source_ci_image;
    CIFilter *magicFilter;
    NSMutableArray *filterParamArray;
    CGRect source_extent;
    CGRect destination_extent;
    EAGLContext *eagl_context;
    CGAffineTransform r_transform;
    NSString *currentFilterName;
    BOOL shouldPreviewOriginalImage;
    BOOL isPerforming;
    UIBezierPath *drawing_path;
    CIImage *blackAndWhite;
    
}
@end

@implementation BCFilterGLView
@synthesize filterParamArray;


-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame context:eagl_context]){
        [self setupOpenGLContext];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self setupOpenGLContext];
    }
    return self;
}

-(void)setupOpenGLContext{
    r_transform = CGAffineTransformMakeRotation(0);
    self.clipsToBounds = YES;
    
    eagl_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    drawing_context = [CIContext contextWithEAGLContext:eagl_context];
    self.context = eagl_context;
    CAEAGLLayer* _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = NO;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys: kEAGLColorFormatRGBA8,
                                     kEAGLDrawablePropertyColorFormat, nil];
    [self bindDrawable];
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if (eagl_context != [EAGLContext currentContext])
        [EAGLContext setCurrentContext:eagl_context];
    self.enableSetNeedsDisplay = YES;
    shouldPreviewOriginalImage = NO;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (shouldPreviewOriginalImage){
        [drawing_context drawImage:source_ci_image inRect:destination_extent fromRect:source_extent];
    }
    else if(magicFilter){
        [drawing_context drawImage:magicFilter.outputImage inRect:destination_extent fromRect:source_extent];
    }
    [eagl_context presentRenderbuffer:GL_RENDERBUFFER];
    isPerforming = NO;
}

-(void)setDrawingExtent {
    const CGSize s_size = self.bounds.size;
    destination_extent = CGRectMake(0, 0, s_size.width * MAINSCRN_SCALE ,
                                    s_size.height * MAINSCRN_SCALE ) ;
    [self setNeedsDisplay];
}

//before drawing clear glk view
-(void)clearBackground{
    CGFloat r,g,b,a;
    [self.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    glClearColor((GLfloat)r, (GLfloat)g, (GLfloat)b, (GLfloat)a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

-(void)setSourceImage:(UIImage *)source_image{
    if(source_image){
        source_ci_image = [[CIImage alloc] initWithImage:source_image];
        source_extent = source_ci_image.extent;
        [self setCIFilter:@"CIColorMonochrome"];
        [self setNeedsDisplay];
    }
}

-(void)deleteContext{
    if (@available(iOS 10.0, *)) {
        [drawing_context clearCaches];
    } else {
        // Fallback on earlier versions
    }
    drawing_context = nil;
    magicFilter = nil;
}


//set filters and its attributes accodring to apples structure
-(void)setCIFilter:(NSString *)filter_name{

    filterParamArray = [[NSMutableArray alloc] init];
    magicFilter = [CIFilter filterWithName:filter_name];
    [magicFilter setValue:source_ci_image forKey:kCIInputImageKey];
    [magicFilter setDefaults];
    NSArray *inputKeys = magicFilter.inputKeys;
    NSDictionary *attributes = magicFilter.attributes;
    for(NSString *key in inputKeys){
        if([key isEqualToString:@"inputImage"]){
            continue;
        }
        
        NSDictionary *attribute = [attributes objectForKey:key];
        NSArray *allKeys = [attribute allKeys];
        NSString *displayName = [attribute valueForKey:@"CIAttributeDisplayName"];
        if([key containsString:@"Components"] || [key containsString:@"Vector"]){
            ColorComponents *comp = [[ColorComponents alloc] init];
            comp._key = key;
            comp.inputCVector = [attribute objectForKey:kCIAttributeDefault];
            [filterParamArray addObject:comp];
        }
        else if([key containsString:@"Color"]){
            FilterColorData *cdata = [[FilterColorData alloc] init];
            cdata._key = key;
            cdata.inputColor = [attribute objectForKey:kCIAttributeDefault];
            [filterParamArray addObject:cdata];
        } else {
            const CGFloat min_value = [allKeys containsObject:kCIAttributeSliderMin] ?
            [[attribute objectForKey:kCIAttributeSliderMin] floatValue] : 100000;
            const CGFloat max_value = [allKeys containsObject:kCIAttributeSliderMax] ?
            [[attribute objectForKey:kCIAttributeSliderMax] floatValue] : -100000;
            const CGFloat def_value = [allKeys containsObject:kCIAttributeDefault] ?
            [[attribute objectForKey:kCIAttributeDefault] floatValue] : 0;
            BCBaseFilterData *base_data = [[BCBaseFilterData alloc] initWithKey:key
                                                                           name:displayName
                                                                       minValue:min_value
                                                                       maxValue:max_value
                                                                   defaultValue:def_value];
            [filterParamArray addObject:base_data];
        }
        
        
    }
}

-(void)setColorComponent:(ColorComponents *)inputCVector{
    
    if(isPerforming) return;
    isPerforming = YES;
    [magicFilter setValue:inputCVector.inputCVector forKey:inputCVector._key];
    [self setNeedsDisplay];
}

-(void)setColorData:(FilterColorData *)inputColor{

    if(isPerforming) return;
    isPerforming = YES;
    [magicFilter setValue:inputColor.inputColor forKey:inputColor._key];
    [self setNeedsDisplay];
}
    
-(IBAction)onSliderValueChanged:(UISlider *)sender{
    if(isPerforming) return;
        isPerforming = YES;
        [self sliderValueDidChanged:sender.value forKey:sender.restorationIdentifier];
    
}

//redraw image in glk view for changing particular slider value
-(void)sliderValueDidChanged:(const CGFloat)current_value forKey:(NSString *)attributeKey{
    
    for(BCBaseFilterData *b_data in filterParamArray){
        if([b_data._key isEqualToString:attributeKey]){
            [magicFilter setValue:[NSNumber numberWithFloat:current_value] forKey:attributeKey];
            break;
        }
    }
    [self setNeedsDisplay];
    
}
    
-(UIImage *)getImage{
    CIImage *ci_image = magicFilter.outputImage;
    CGImageRef imageRef = [drawing_context createCGImage:ci_image fromRect:ci_image.extent];
    UIImage *outImage = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return outImage;
}

-(void)dealloc{
    //self
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    [EAGLContext setCurrentContext: nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event ];
    shouldPreviewOriginalImage = YES;
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event  {
    [super touchesEnded:touches withEvent:event];
    shouldPreviewOriginalImage = NO;
    [self setNeedsDisplay];
}

@end
