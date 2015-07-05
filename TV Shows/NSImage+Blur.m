//
//  NSImage+Blur.m
//  TV Shows
//
//  Created by Avikant Saini on 7/4/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NSImage+Blur.h"


@implementation NSImage (Blur)

- (NSImage *)blurImageWithRadius:(CGFloat)radius {
	
	NSImage *image = self;
	
	[image lockFocus];
	CIImage *beginImage = [[CIImage alloc] initWithData:[image TIFFRepresentation]];
	CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:kCIInputImageKey, beginImage, @"inputRadius", @(radius), nil];
	CIImage *output = [filter valueForKey:@"outputImage"];
	NSRect rect = NSMakeRect(-10, -10, self.size.width+20, self.size.height+20);
	NSRect sourceRect = NSMakeRect(0, 0, self.size.width, self.size.height);
	[output drawInRect:rect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
	[image unlockFocus];
	
	return image;
}

-(NSImage *)resizeImageWithSize:(NSSize)size {
	
	NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
	NSImage*  targetImage = [[NSImage alloc] initWithSize:size];
	
	NSSize sourceSize = [self size];
	
	float ratioH = size.height/ sourceSize.height;
	float ratioW = size.width / sourceSize.width;
	
	NSRect cropRect = NSZeroRect;
	if (ratioH >= ratioW) {
		cropRect.size.width = floor (size.width / ratioH);
		cropRect.size.height = sourceSize.height;
	} else {
		cropRect.size.width = sourceSize.width;
		cropRect.size.height = floor(size.height / ratioW);
	}
	
	cropRect.origin.x = floor( (sourceSize.width - cropRect.size.width)/2 );
	cropRect.origin.y = floor( (sourceSize.height - cropRect.size.height)/2 );
	
	
	
	[targetImage lockFocus];
	
	[self drawInRect:targetFrame
				   fromRect:cropRect       //portion of source image to draw
				  operation:NSCompositeCopy  //compositing operation
				   fraction:1.0              //alpha (transparency) value
			 respectFlipped:YES              //coordinate system
					  hints:@{NSImageHintInterpolation:
								  [NSNumber numberWithInt:NSImageInterpolationLow]}];
	
	[targetImage unlockFocus];
	
	return targetImage;}

@end