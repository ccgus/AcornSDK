//
//  ACText.m
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "ACText.h"


@implementation ACText

static NSLayoutManager *sharedDrawingLayoutManager() {
    // This method returns an NSLayoutManager that can be used to draw the contents of a TSTextArea.
    static NSLayoutManager *sharedLM = nil;
    if (!sharedLM) {
        NSTextContainer *tc = [[NSTextContainer allocWithZone:NULL] initWithContainerSize:NSMakeSize(1.0e6, 1.0e6)];
        
        sharedLM = [[NSLayoutManager allocWithZone:NULL] init];
        
        [tc setWidthTracksTextView:NO];
        [tc setHeightTracksTextView:NO];
        [sharedLM addTextContainer:tc];
        [tc release];
    }
    return sharedLM;
}


- (void) dealloc {
    
    [_contents autorelease];
    _contents = 0x00;
    
    [super dealloc];
    
}

- (NSTextStorage *)contents {
    return _contents; 
}
- (void)setContents:(NSTextStorage *)newContents {
    [newContents retain];
    [_contents release];
    _contents = newContents;
}


- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    id obj;
    
    [super loadPropertyListRepresentation:dict];
    
    obj = [dict objectForKey:@"Text"];
    if (obj) {
        [self setContents:[NSUnarchiver unarchiveObjectWithData:obj]];
    }
}



- (void) flipShadow {
    
    
    int length = [[self contents] length];
    
    if (length <= 0) {
        return;
    }
    
    NSRange r = NSMakeRange(0, 0);
    
    while (r.location + r.length < length) {
        
        NSDictionary *attributes = [[self contents] attributesAtIndex:r.location+r.length effectiveRange:&r];
        
        NSShadow *s = [attributes objectForKey:NSShadowAttributeName];
        
        if (s) {
            
            NSSize size = [s shadowOffset];
            
            size.height *= -1;
            
            [s setShadowOffset:size];
        }
        
        //f = [[NSFontManager sharedFontManager] convertFont:f toSize:[f pointSize] * scale];
        
        //[[self contents] addAttributes:[NSDictionary dictionaryWithObject:f forKey:NSFontAttributeName]
        //                         range:r];
    }
    
    
}

- (void) draw {
    NSRect bounds = [self bounds];
    
    CGContextRef contextRef = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSaveGState(contextRef);
    
    NSShadow *cshadow = nil;
    if ([self hasShadow]) {
        
        cshadow = [[[NSShadow alloc] init] autorelease];
        [cshadow setShadowOffset:[self shadowOffset]];
        [cshadow setShadowBlurRadius:[self shadowBlurRadius]];
        [cshadow set];
    }
    
    NSTextStorage *contents = [self contents];
    if ([contents length] > 0) {
        NSLayoutManager *lm = sharedDrawingLayoutManager();
        NSTextContainer *tc = [[lm textContainers] objectAtIndex:0];
        NSRange glyphRange;
        
        [tc setContainerSize:bounds.size];
        [contents addLayoutManager:lm];
        // Force layout of the text and find out how much of it fits in the container.
        glyphRange = [lm glyphRangeForTextContainer:tc];
        
        if (NSEqualRanges(glyphRange, NSMakeRange(0, 0))) {
            // make the fucker big temporarily.
            
            [tc setContainerSize:NSMakeSize(bounds.size.width, 5000)];
            //[contents addLayoutManager:lm];
            // Force layout of the text and find out how much of it fits in the container.
            glyphRange = [lm glyphRangeForTextContainer:tc];
            
            [[NSBezierPath bezierPathWithRect:bounds] addClip];
        }
        
        
        if (glyphRange.length > 0) {
            
            NSPoint textOrigin = bounds.origin;
            
            [lm drawBackgroundForGlyphRange:glyphRange atPoint:textOrigin];
            [lm drawGlyphsForGlyphRange:glyphRange atPoint:textOrigin];
            
        }
        [contents removeLayoutManager:lm];
    }
    
    if (cshadow) {
        CGContextSetShadowWithColor(contextRef, CGSizeZero, 0, NULL);
    }

    
    
    CGContextRestoreGState(contextRef);
}

@end
