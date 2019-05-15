//
//  BCBaseFilter.h
//  BucketCam
//
//  Created by Mostafizur Rahman on 9/12/17.
//  Copyright © 2017 Mostafizur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface BCBaseFilterData : NSObject

@property (readwrite) NSString *_key;
@property (readwrite) NSString *_name;
@property (readwrite) CGFloat minimun_value;
@property (readwrite) CGFloat maximum_value;
@property (readwrite) CGFloat default_value;

-(instancetype)initWithKey:(NSString *)key name:(NSString *)name;
-(instancetype)initWithKey:(NSString *)key name:(NSString *)name
                  minValue:(const CGFloat)min_value
                  maxValue:(const CGFloat)max_value
              defaultValue:(const CGFloat)def_value;

@end

@interface FilterColorData : NSObject

@property (readwrite) NSString *_key;
@property (readwrite) CIColor *inputColor;

@end

@interface ColorComponents : NSObject

@property (readwrite) NSString *_key;
@property (readwrite) CIVector *inputCVector;

@end
