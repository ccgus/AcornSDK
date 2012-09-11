//
//  ACLayer.m
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "ACLayer.h"


@implementation ACLayer

- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    // ... foo
    
    
    [self setVisible:[[dict objectForKey:@"visible"] boolValue]];
    [self setCompositingMode:[[dict objectForKey:@"compositingMode"] intValue]];
    [self setOpacity:[[dict objectForKey:@"opacity"] floatValue]];
    [self setLayerName:[dict objectForKey:@"layerName"]];
    
}

- (void) drawInContext:(CGContextRef)context {
    // ... foo
}


- (BOOL)visible {
    return _visible;
}
- (void)setVisible:(BOOL)flag {
    _visible = flag;
}


- (NSString *)layerName {
    return _layerName; 
}
- (void)setLayerName:(NSString *)newLayerName {
    [newLayerName retain];
    [_layerName release];
    _layerName = newLayerName;
}


- (float)opacity {
    return _opacity;
}
- (void)setOpacity:(float)newOpacity {
    _opacity = newOpacity;
}


- (int)compositingMode {
    return _compositingMode;
}
- (void)setCompositingMode:(int)newCompositingMode {
    _compositingMode = newCompositingMode;
}



@end
