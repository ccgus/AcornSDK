//
//  ACLayer.h
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ACLayer : NSObject {
    
    BOOL _visible;
    NSString *_layerName;
    float _opacity;
    int _compositingMode;
}

- (void)loadPropertyListRepresentation:(NSDictionary *)dict;
- (void) drawInContext:(CGContextRef)context;

- (BOOL)visible;
- (void)setVisible:(BOOL)flag;
- (NSString *)layerName;
- (void)setLayerName:(NSString *)newLayerName;
- (float)opacity;
- (void)setOpacity:(float)newOpacity;
- (int)compositingMode;
- (void)setCompositingMode:(int)newCompositingMode;


@end
