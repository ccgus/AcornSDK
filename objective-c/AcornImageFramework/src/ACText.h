//
//  ACText.h
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACGraphic.h"

@interface ACText : ACGraphic {
    NSTextStorage *_contents;
}

- (NSTextStorage *)contents;
- (void)setContents:(NSTextStorage *)newContents;


@end
