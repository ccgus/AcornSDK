//
//  ACRect.m
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "ACRect.h"

@interface NSBezierPath (FMBezierPathAdditions)
+ (NSBezierPath*)bezierPathWithRoundRectInRect:(NSRect)aRect radius:(float)radius;
@end

@implementation NSBezierPath (FMBezierPathAdditions)


// where did I get this?
+ (NSBezierPath*)bezierPathWithRoundRectInRect:(NSRect)aRect radius:(float)radius {
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    float junk = MIN(NSWidth(aRect), NSHeight(aRect));
    
    radius = MIN(radius, 0.5f * junk);
    NSRect rect = NSInsetRect(aRect, radius, radius);
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect)) radius:radius startAngle:180.0 endAngle:270.0];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMinY(rect)) radius:radius startAngle:270.0 endAngle:360.0];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:  0.0 endAngle: 90.0];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle: 90.0 endAngle:180.0];
    [path closePath];
    return path;
}

@end

@implementation ACRect

- (NSBezierPath *)bezierPath {
    // draw between the pixels to get a non-antialiased line
    NSRect b = [self bounds];
    b.origin.x -= .5f;
    b.origin.y -= .5f;
    
    NSBezierPath *path = 0x00;
    
    if ([self hasCornerRadius]) {
        path = [NSBezierPath bezierPathWithRoundRectInRect:b radius:[self cornerRadius]];
    }
    else {
        path = [NSBezierPath bezierPathWithRect:b];
    }
    
    
    [path setLineWidth:[self lineWidth]];
    
    return path;
}
@end
