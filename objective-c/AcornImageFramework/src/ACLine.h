//
//  ACLine.h
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACGraphic.h"

@interface ACLine : ACGraphic {
    NSPoint _startPoint;
    BOOL _startsAtLowerLeft;
    NSBezierPath *_path;
}

- (NSPoint)startPoint;
- (void)setStartPoint:(NSPoint)newStartPoint;
- (BOOL)startsAtLowerLeft;
- (void)setStartsAtLowerLeft:(BOOL)flag;
- (NSBezierPath *)path;
- (void)setPath:(NSBezierPath *)value;



@end
