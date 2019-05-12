//
//  ColorCreator.h
//  ColorFinder
//
//  Created by NoboPay on 12/5/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

#ifndef ColorCreator_h
#define ColorCreator_h

#include <stdio.h>
#include <math.h>
typedef unsigned char BYTE; //define an "integer" that only stores 0-255 value

typedef struct _CRGB //Define a struct to store the 3 color values
{
    BYTE r;
    BYTE g;
    BYTE b;
}CRGB;
CRGB TransformH(const CRGB *data, const float fHue);
int getInt(void);
#endif /* ColorCreator_h */
