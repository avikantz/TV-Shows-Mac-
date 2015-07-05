//
//  NSImage+Blur.h
//  TV Shows
//
//  Created by Avikant Saini on 7/4/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Blur)

- (NSImage *)blurImageWithRadius:(CGFloat)radius;
- (NSImage *)resizeImageWithSize:(NSSize)size;

@end
