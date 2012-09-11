//
//  RandomCG.m
//  RandomCG
//
//  Created by August Mueller on 10/15/07.
//  Copyright Flying Meat Inc 2007 . All rights reserved.
//

#import "RandomCG.h"

#define PI 3.14159265358979323846

@implementation RandomCG

+ (id)plugin {
    return [[[self alloc] init] autorelease];
}

- (void) willRegister:(id<ACPluginManager>)pluginManager {
    
    [pluginManager addFilterMenuTitle:@"Random CG Calls"
                   withSuperMenuTitle:@"Generator"
                               target:self
                               action:@selector(make:userObject:)
                        keyEquivalent:@""
            keyEquivalentModifierMask:0
                           userObject:nil];
}

- (void)didRegister {
    
}

- (CIImage*)make:(CIImage*)image userObject:(id)uo {
    
    int w = [image extent].size.width;
    int h = [image extent].size.height;
    
    CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
    CGContextRef context = CGBitmapContextCreate(nil, w, h, 8, 0, cs, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
    
    CGColorSpaceRelease(cs);
    
    // Fill with a random color
    CGContextSetRGBFillColor(context, (rand()%256)/255.0, (rand()%256)/255.0, (rand()%256)/255.0, 1);
    CGContextBeginPath(context);
    CGContextAddRect(context, CGRectMake(0, 0, w, h));
    CGContextFillPath(context);
    
    for (int i = 0; i < 20; i++) {
        int numberOfSegments = rand() % 8;
        int j;
        float sx, sy;
        
        CGContextBeginPath(context);
        sx = rand()%w; sy = rand()%h;
        CGContextMoveToPoint(context, rand()%w, rand()%h);
        for (j = 0; j < numberOfSegments; j++) {
            if (j % 2) {
                CGContextAddLineToPoint(context, rand()%w, rand()%h);
            }
            else {
                CGContextAddCurveToPoint(context, rand()%w, rand()%h,  
                                         rand()%w, rand()%h,  rand()%h, rand()%h);
            }
        }
        if(i % 2) {
            CGContextAddCurveToPoint(context, rand()%w, rand()%h,
                                     rand()%w, rand()%h,  sx, sy);
            CGContextClosePath(context);
            CGContextSetRGBFillColor(context, (float)(rand()%256)/255, 
                                     (float)(rand()%256)/255, (float)(rand()%256)/255, 
                                     (float)(rand()%256)/255);
            CGContextFillPath(context);
        }
        else {
            CGContextSetLineWidth(context, (rand()%10)+2);
            CGContextSetRGBStrokeColor(context, (float)(rand()%256)/255, 
                                       (float)(rand()%256)/255, (float)(rand()%256)/255, 
                                       (float)(rand()%256)/255);
            CGContextStrokePath(context);
        }
    }
    
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    CIImage *returnImage = [CIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (NSNumber*)worksOnShapeLayers:(id)userObject {
    return [NSNumber numberWithBool:NO];
}

- (NSNumber*)validateForLayer:(id<ACLayer>)layer {
    
    if ([layer layerType] == ACBitmapLayer) {
        [NSNumber numberWithBool:YES];
    }
    
    return [NSNumber numberWithBool:NO];
}

@end
