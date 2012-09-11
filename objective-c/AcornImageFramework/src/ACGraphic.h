//
//  ACGraphic.h
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ACGraphic : NSObject {
    
    NSRect _bounds;
    float _lineWidth;
    NSColor *_fillColor;
    NSColor *_strokeColor;
    BOOL _drawsFill;
    BOOL _drawsStroke;
    BOOL _hasShadow;
    float _shadowBlurRadius;
    NSSize _shadowOffset;
    int _compositingMode;
    BOOL _hasCornerRadius;
    float _cornerRadius;
}

- (NSBezierPath *)bezierPath;
- (void) draw;
- (void)loadPropertyListRepresentation:(NSDictionary *)dict;


- (NSRect)bounds;
- (void)setBounds:(NSRect)newBounds;
- (float)lineWidth;
- (void)setLineWidth:(float)newLineWidth;
- (NSColor *)fillColor;
- (void)setFillColor:(NSColor *)newFillColor;
- (NSColor *)strokeColor;
- (void)setStrokeColor:(NSColor *)newStrokeColor;
- (BOOL)hasShadow;
- (void)setHasShadow:(BOOL)flag;
- (float)shadowBlurRadius;
- (void)setShadowBlurRadius:(float)newShadowBlurRadius;
- (NSSize)shadowOffset;
- (void)setShadowOffset:(NSSize)newShadowOffset;
- (int)compositingMode;
- (void)setCompositingMode:(int)newCompositingMode;
- (BOOL)hasCornerRadius;
- (void)setHasCornerRadius:(BOOL)flag;
- (float)cornerRadius;
- (void)setCornerRadius:(float)newCornerRadius;
- (BOOL)drawsFill;
- (void)setDrawsFill:(BOOL)flag;
- (BOOL)drawsStroke;
- (void)setDrawsStroke:(BOOL)flag;


@end
