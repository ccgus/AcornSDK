//
//  ACLine.m
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "ACLine.h"


NSString *ACLineStartsAtLowerLeftKey = @"LineStartsAtLowerLeft";
NSString *ACStartPoint = @"StartPoint";
NSString *ACPathKey    = @"Path";

@implementation ACLine

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_path release];
    [super dealloc];
}


- (NSPoint) endPointFromBounds:(NSRect)bounds {
    
    NSPoint a = bounds.origin;
    NSPoint b = bounds.origin;
    
    b.x += bounds.size.width;
    
    if ([self startsAtLowerLeft]) {
        a.y += bounds.size.height;
    }
    else {
        b.y += bounds.size.height;
    }
    
    NSPoint endPoint = a;
    if (NSEqualPoints(endPoint, _startPoint)) {
        endPoint = b;
    }
    
    return endPoint;
}

- (NSPoint) endPoint {
    return [self endPointFromBounds:[self bounds]];
}

- (NSBezierPath *)bezierPath {
    
    if (_path) {
        return _path;
    }
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    
    if ([self startsAtLowerLeft]) {
        NSPoint start = [self startPoint];
        NSPoint end   = [self endPoint];
        
        [path moveToPoint:start];
        [path lineToPoint:end];
    }
    else {
        NSPoint start = [self startPoint];
        NSPoint end   = [self endPoint];
        
        [path moveToPoint:start];
        [path lineToPoint:end];
    }
    
    [path setLineWidth:[self lineWidth]];
    
    return path;
}

- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    [super loadPropertyListRepresentation:dict];
    
    id obj = [dict objectForKey:ACLineStartsAtLowerLeftKey];
    if (obj) {
        [self setStartsAtLowerLeft:[obj isEqualToString:@"YES"]];
    }
    
    obj = [dict objectForKey:ACStartPoint];
    if (obj) {
        _startPoint = NSPointFromString(obj);
    }
    
    obj = [dict objectForKey:ACPathKey];
    if (obj) {
        [self setPath:[NSUnarchiver unarchiveObjectWithData:obj]];
    }
    
}


- (NSPoint)startPoint {
    return _startPoint;
}
- (void)setStartPoint:(NSPoint)newStartPoint {
    _startPoint = newStartPoint;
}


- (BOOL)startsAtLowerLeft {
    return _startsAtLowerLeft;
}
- (void)setStartsAtLowerLeft:(BOOL)flag {
    _startsAtLowerLeft = flag;
}

- (NSBezierPath *) path {
    return _path;
}

- (void)setPath:(NSBezierPath *)value {
    if (_path != value) {
        [_path release];
        _path = [value retain];
    }
}





@end
