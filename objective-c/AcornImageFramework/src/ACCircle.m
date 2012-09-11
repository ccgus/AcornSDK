//
//  ACCircle.m
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "ACCircle.h"


@implementation ACCircle

- (NSBezierPath *)bezierPath {
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:[self bounds]];
    
    [path setLineWidth:[self lineWidth]];
    
    return path;
}

@end
