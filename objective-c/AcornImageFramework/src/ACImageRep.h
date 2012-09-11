//
//  ACImageRep.h
//  AcornImage
//
//  Created by Jonathan Wight on 02/18/08.
//  Copyright 2008 Toxic Software. All rights reserved.
//  Copyright 2008 Flying Meat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ACImage;

@interface ACImageRep : NSCustomImageRep {
	ACImage *_image;
}

- (ACImage *)image;
- (void)setImage:(ACImage *)value;

@end
