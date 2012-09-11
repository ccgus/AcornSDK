//
//  ACGraphic.m
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "ACGraphic.h"

NSString *ACClassKey            = @"Class";
NSString *ACBoundsKey           = @"Bounds";
NSString *ACDrawsFillKey        = @"DrawsFill";
NSString *ACHasShadow           = @"HasShadow";
NSString *ACShadowBlurRadius    = @"ShadowBlurRadius";
NSString *ACShadowOffset        = @"ShadowOffset";
NSString *ACFillColorKey        = @"FillColor";
NSString *ACDrawsStrokeKey      = @"DrawsStroke";
NSString *ACStrokeColorKey      = @"StrokeColor";
NSString *ACStrokeLineWidthKey  = @"StrokeLineWidth";
NSString *ACCompositingModeKey  = @"CompositingMode";
NSString *ACHasCornerRadiusKey  = @"HasCornerRadius";
NSString *ACCornerRadiusKey     = @"CornerRadius";

@implementation ACGraphic


- (void) draw {
    
    NSBezierPath *path = [self bezierPath];
    if (path) {
        
        if ([self compositingMode] > 0) {
            [NSGraphicsContext saveGraphicsState];
            [[NSGraphicsContext currentContext] setCompositingOperation:[self compositingMode]];
        }
        
        NSShadow *cshadow = nil;
        
        if ([self hasShadow]) {
            cshadow = [[[NSShadow alloc] init] autorelease];
            
            [cshadow setShadowOffset:[self shadowOffset]];
            [cshadow setShadowBlurRadius:[self shadowBlurRadius]];
            
            // eek! things get complicated with shadows
            
            if ([self drawsFill] && [self drawsStroke]) {
                // we don't want to draw the shadow twice..
                
                float strokeInset = -(_lineWidth/2.0f);
                
                // round down the inset value, so we don't get lines outside our stroke.
                strokeInset = ceil(strokeInset);
                
                [[self fillColor] set];
                [cshadow set];
                
                [path fill];
                
                // turn off the shadow.
                CGContextSetShadowWithColor((CGContextRef)([[NSGraphicsContext currentContext] graphicsPort]), CGSizeZero, 0, NULL);
                
                // stroke over everything else.
                [[self strokeColor] set];
                [path stroke];
            }
            else if ([self drawsStroke]) {
                [[self strokeColor] set];
                [cshadow set];
                [path stroke];
                
            }
            else if ([self drawsFill]) {
                
                [[self fillColor] set];
                
                if (![self fillColor]) {
                    [[NSColor blackColor] set];
                }
                
                [cshadow set];
                [path fill];
            }
            
            CGContextSetShadowWithColor((CGContextRef)([[NSGraphicsContext currentContext] graphicsPort]), CGSizeZero, 0, NULL);
            
        }
        else {
            
            if ([self drawsFill]) {
                [[self fillColor] set];
                [path fill];
            }
            
            if ([self drawsStroke]) {
                [[self strokeColor] set];
                [path stroke];
            }
        }
        
        if ([self compositingMode] > 0) {
            [NSGraphicsContext restoreGraphicsState];
        }
    }
}

- (NSBezierPath *)bezierPath {
    return nil;
}

- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    id obj;
    
    obj = [dict objectForKey:ACBoundsKey];
    if (obj) {
        [self setBounds:NSRectFromString(obj)];
    }
    obj = [dict objectForKey:ACFillColorKey];
    if (obj) {
        [self setFillColor:[NSUnarchiver unarchiveObjectWithData:obj]];
    }
    else {
        [self setFillColor:nil];
    }
    
    obj = [dict objectForKey:ACDrawsFillKey];
    if (obj) {
        [self setDrawsFill:[obj isEqualToString:@"YES"]];
    }
    obj = [dict objectForKey:ACStrokeColorKey];
    if (obj) {
        [self setStrokeColor:[NSUnarchiver unarchiveObjectWithData:obj]];
    }
    else {
        [self setStrokeColor:nil];
    }
    
    obj = [dict objectForKey:ACDrawsStrokeKey];
    if (obj) {
        [self setDrawsStroke:[obj isEqualToString:@"YES"]];
    }
    obj = [dict objectForKey:ACStrokeLineWidthKey];
    if (obj) {
        [self setLineWidth:[obj floatValue]];
    }
    
    
    if ((obj = [dict objectForKey:ACHasShadow])) {
        [self setHasShadow:[obj isEqualToString:@"YES"]];
    }
    
    if ((obj = [dict objectForKey:ACShadowOffset])) {
        [self setShadowOffset:NSSizeFromString(obj)];
    }
    
    if ((obj = [dict objectForKey:ACShadowBlurRadius])) {
        [self setShadowBlurRadius:[obj floatValue]];
    }
    
    if ((obj = [dict objectForKey:ACCompositingModeKey])) {
        [self setCompositingMode:[obj floatValue]];
    }
    
    
    if ((obj = [dict objectForKey:ACHasCornerRadiusKey])) {
        [self setHasCornerRadius:[obj boolValue]];
    }
    if ((obj = [dict objectForKey:ACCornerRadiusKey])) {
        [self setCornerRadius:[obj floatValue]];
    }
    
}



- (NSRect)bounds {
    return _bounds;
}
- (void)setBounds:(NSRect)newBounds {
    _bounds = newBounds;
}


- (float)lineWidth {
    return _lineWidth;
}
- (void)setLineWidth:(float)newLineWidth {
    _lineWidth = newLineWidth;
}


- (NSColor *)fillColor {
    return _fillColor; 
}
- (void)setFillColor:(NSColor *)newFillColor {
    [newFillColor retain];
    [_fillColor release];
    _fillColor = newFillColor;
}


- (NSColor *)strokeColor {
    return _strokeColor; 
}
- (void)setStrokeColor:(NSColor *)newStrokeColor {
    [newStrokeColor retain];
    [_strokeColor release];
    _strokeColor = newStrokeColor;
}


- (BOOL)hasShadow {
    return _hasShadow;
}
- (void)setHasShadow:(BOOL)flag {
    _hasShadow = flag;
}


- (float)shadowBlurRadius {
    return _shadowBlurRadius;
}
- (void)setShadowBlurRadius:(float)newShadowBlurRadius {
    _shadowBlurRadius = newShadowBlurRadius;
}


- (NSSize)shadowOffset {
    return _shadowOffset;
}
- (void)setShadowOffset:(NSSize)newShadowOffset {
    _shadowOffset = newShadowOffset;
}


- (int)compositingMode {
    return _compositingMode;
}
- (void)setCompositingMode:(int)newCompositingMode {
    _compositingMode = newCompositingMode;
}


- (BOOL)hasCornerRadius {
    return _hasCornerRadius;
}
- (void)setHasCornerRadius:(BOOL)flag {
    _hasCornerRadius = flag;
}


- (float)cornerRadius {
    return _cornerRadius;
}
- (void)setCornerRadius:(float)newCornerRadius {
    _cornerRadius = newCornerRadius;
}

- (BOOL)drawsFill {
    return _drawsFill;
}
- (void)setDrawsFill:(BOOL)flag {
    _drawsFill = flag;
}


- (BOOL)drawsStroke {
    return _drawsStroke;
}
- (void)setDrawsStroke:(BOOL)flag {
    _drawsStroke = flag;
}





@end
