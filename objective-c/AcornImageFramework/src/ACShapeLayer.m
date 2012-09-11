//
//  ACShapeLayer.m
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "ACShapeLayer.h"
#import "ACLine.h"
#import "ACCircle.h"
#import "ACRect.h"
#import "ACText.h"
#import "ACShapeImage.h"

@implementation ACShapeLayer

- (void) dealloc {
    
    [_properties autorelease];
    _properties = 0x00;
    
    [super dealloc];
}

- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    [super loadPropertyListRepresentation:dict];
    
    [self setProperties:dict];
}


- (NSDictionary *)properties {
    return _properties; 
}
- (void)setProperties:(NSDictionary *)newProperties {
    [newProperties retain];
    [_properties release];
    _properties = newProperties;
}


- (void) drawInContext:(CGContextRef)context {
    
    NSGraphicsContext *currentNSContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:YES];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:currentNSContext];
    
    if (_compositingMode > 0) {
        CGContextSetBlendMode(context, [self compositingMode]);
    }
    
    if (_opacity != 1) {
        CGContextSetAlpha(context, _opacity);
        CGContextBeginTransparencyLayer(context, nil);
        
        // gotta do it again for some reason
        if (_compositingMode > 0) {
            CGContextSetBlendMode(context, [self compositingMode]);
        }
    }
    
    
    NSArray *graphics         = [_properties objectForKey:@"GraphicsList"];
    NSEnumerator *e           = [graphics reverseObjectEnumerator];
    NSDictionary *graphicDict = 0x00;
    
    while ((graphicDict = [e nextObject])) {
        
        NSString *className = [graphicDict objectForKey:@"Class"];
        
        ACGraphic *graphic = 0x00;
        
        if ([@"Line" isEqualToString:className]) {
            graphic = [[[ACLine alloc] init] autorelease];
        }
        else if ([@"Circle" isEqualToString:className]) {
            graphic = [[[ACCircle alloc] init] autorelease];
        }
        else if ([@"Rectangle" isEqualToString:className]) {
            graphic = [[[ACRect alloc] init] autorelease];
        }
        else if ([@"TextArea" isEqualToString:className]) {
            graphic = [[[ACText alloc] init] autorelease];
        }
        else if ([@"ShapeImage" isEqualToString:className]) {
            graphic = [[[ACShapeImage alloc] init] autorelease];
        }
        else {
            // ... ?
        }
        
        if (graphic) {
            [graphic loadPropertyListRepresentation:graphicDict];
            [graphic draw];
        }
    }
    
    
    
    if (_opacity != 1) {
        CGContextEndTransparencyLayer(context);
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
