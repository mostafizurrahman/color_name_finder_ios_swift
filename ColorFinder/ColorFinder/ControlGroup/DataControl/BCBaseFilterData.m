//
//  BCBaseFilter.m
//  BucketCam
//
//  Created by Mostafizur Rahman on 9/12/17.
//  Copyright © 2017 Mostafizur Rahman. All rights reserved.
//

#import "BCBaseFilterData.h"

@implementation BCBaseFilterData

-(instancetype)initWithKey:(NSString *)key
                      name:(NSString *)name{
    self = [super init];
    self._key = key;
    self._name = name;
    return self;
}

-(instancetype)initWithKey:(NSString *)key name:(NSString *)name
                  minValue:(const CGFloat)min_value
                  maxValue:(const CGFloat)max_value
              defaultValue:(const CGFloat)def_value {
    
    self = [super init];
    self._key = key;
    self._name = name;
    self.default_value = def_value;
    self.maximum_value = max_value;
    self.minimun_value = min_value;
    return self;
}

@end

@implementation FilterColorData



@end
@implementation ColorComponents
@end
