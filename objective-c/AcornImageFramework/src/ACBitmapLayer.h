//
//  ACBitmapLayer.h
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACLayer.h"
#import <zlib.h>

@interface ACBitmapLayer : ACLayer {
    CGImageRef _imageRef;
    NSSize _size;
    NSPoint _drawDelta;
    
}

@end
