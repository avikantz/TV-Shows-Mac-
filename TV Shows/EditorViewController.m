//
//  EditorViewController.m
//  TV Shows
//
//  Created by Avikant Saini on 6/26/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "EditorViewController.h"
#import "NSImage+Blur.h"

@interface EditorViewController ()

@end

@implementation EditorViewController {
	BOOL showingSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
	
	self.titleLabel.stringValue = self.show.Title;
	showingSize = NO;
	self.textView.string = self.show.Detail;
	if (self.show.CURRENTLY_FOLLOWING) {
		self.dayPickerComboBox.stringValue = self.show.Day;
		self.dayPickerComboBox.hidden = NO;
	}
	else
		self.dayPickerComboBox.hidden = YES;
	
	
	
//	[self updateImages];
	
	if (![[NSImage alloc] initWithContentsOfFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-poster.jpg", self.show.Title]]]) {
		NSString *showString = [[[[self.show.Title lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"-"] stringByReplacingOccurrencesOfString:@"'" withString:@"-"] stringByReplacingOccurrencesOfString:@"." withString:@""];
		
		NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api-v2launch.trakt.tv/shows/%@/?extended=images", showString]];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
		[request setHTTPMethod:@"GET"];
		
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[request setValue:@"2" forHTTPHeaderField:@"trakt-api-version"];
		[request setValue:@"f918adf277bb8170a712bb18ce8b49714a571d94311be48352f3eeabbe30dc28" forHTTPHeaderField:@"trakt-api-key"];
		
		NSURLSession *session = [NSURLSession sharedSession];
		NSURLSessionDataTask *task = [session dataTaskWithRequest:request
												completionHandler:
									  ^(NSData *data, NSURLResponse *response, NSError *error) {
			  if (error) {
				  return;
			  }
			  
			  if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
				  NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
				  NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
			  }
			  
			  NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			  NSLog(@"Response Body:\n%@\n", body);
			  
			  NSMutableArray *imagesArray = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] valueForKey:@"images"];
			  if ([[imagesArray valueForKey:@"poster"] valueForKey:@"medium"] != nil)
				  self.show.imagePosterURL = [[imagesArray valueForKey:@"poster"] valueForKey:@"medium"];
//			  if ([[imagesArray valueForKey:@"banner"] valueForKey:@"full"] != nil)
//				  self.show.imageBannerURL = [[imagesArray valueForKey:@"banner"] valueForKey:@"full"];
//			  if ([[imagesArray valueForKey:@"fanart"] valueForKey:@"thumb"] != nil)
//				  self.show.imageFanartURL = [[imagesArray valueForKey:@"fanart"] valueForKey:@"thumb"];
			  
			  [self performSelectorInBackground:@selector(saveImages) withObject:nil];
			  
		  }];
		[task resume];
	}
}

-(void)viewDidDisappear {
//	[self doneAction:self];
}

-(void)saveImages {
	if (![[NSImage alloc] initWithContentsOfFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-poster.jpg", self.show.Title]]]) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSData *image = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.show.imagePosterURL]];
			if (image)
				[image writeToFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-poster.jpg", self.show.Title]] atomically:YES];
			
//			[self performSelectorOnMainThread:@selector(updateImages) withObject:nil waitUntilDone:NO];
		});
	}
//	if (![[NSImage alloc] initWithContentsOfFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-banner.jpg", self.show.Title]]]) {
//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//			NSData *image = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.show.imageBannerURL]];
//			if (image)
//				[image writeToFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-banner.jpg", self.show.Title]] atomically:YES];
//
//		});
//	}
//	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//		NSData *image = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.show.imageFanartURL]];
//		if (image)
//			[image writeToFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-fanart.jpg", self.show.Title]] atomically:YES];
//		
//	});
}

-(void)updateImages {
	if ([[NSImage alloc] initWithContentsOfFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-poster.jpg", self.show.Title]]]) {
		
		_backgroundImageView.image = [[[[NSImage alloc] initWithContentsOfFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-poster.jpg", self.show.Title]]] resizeImageWithSize:NSSizeFromCGSize(self.backgroundImageView.frame.size)] blurImageWithRadius:10.f];
		
		_textView.textColor = [NSColor whiteColor];
		_textView.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_textView.drawsBackground = YES;
		_titleLabel.textColor = [NSColor whiteColor];
	}
}

- (IBAction)doneAction:(id)sender {
	self.show.Detail = [self stringByRemovingName:self.show.Title FromString:self.textView.string];
//	NSLog(@"URLS: %@\n\n%@\n\n%@", self.show.imageBannerURL, self.show.imageFanartURL, self.show.imagePosterURL);
	
	[self.delegate didFinishEditingShowWithTitle:self.show.Title AndShow:self.show];
	
//	Old Delegate Method
//	[self.delegate didFinishEditingShowWithTitle:self.show.Title AndDetail:self.show.Detail AndDay:self.dayPickerComboBox.stringValue];
	
	[self dismissController:self];
}

- (IBAction)deleteAction:(id)sender {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:[NSString stringWithFormat:@"Delete \"%@\"?", self.show.Title]];
	[alert setInformativeText:@"This will remove the show from the data-source. This action is irreversible. Are you bloody sure you want to continue?"];
	[alert addButtonWithTitle:@"Nope"];
	[alert addButtonWithTitle:@"Yeah"];
	[alert setDelegate:self];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	if ([alert runModal] == NSAlertSecondButtonReturn) {
		[self.delegate didConfirmDeleteShowNamed:self.show.Title];
		[self dismissController:self];
	}
}

- (void)flagsChanged:(NSEvent *)theEvent {
	if ([theEvent modifierFlags] & NSAlternateKeyMask) {
		self.titleLabel.stringValue = [NSString stringWithFormat:@"%li Episode%@, avg. %.2f MB", self.show.Episodes, (self.show.Episodes>1)?@"s":@"", self.show.SizePEpisode];
	}
	else if ([theEvent modifierFlags] & NSFunctionKeyMask) {
		if ([[NSImage alloc] initWithContentsOfFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-poster.jpg", self.show.Title]]]) {
			_backgroundImageView.image = [[[[NSImage alloc] initWithContentsOfFile:[self imagesPathForFileName:[NSString stringWithFormat:@"%@-poster.jpg", self.show.Title]]] resizeImageWithSize:NSSizeFromCGSize(self.backgroundImageView.frame.size)] blurImageWithRadius:10.f];
			_textView.textColor = [NSColor whiteColor];
			_textView.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5];
			_textView.drawsBackground = YES;
			_titleLabel.textColor = [NSColor whiteColor];
		}
	}
	else {
		self.titleLabel.stringValue = self.show.Title;
		_backgroundImageView.image = nil;
		_textView.textColor = [NSColor blackColor];
		_textView.backgroundColor = [NSColor clearColor];
		_textView.drawsBackground = NO;
		_titleLabel.textColor = [NSColor blackColor];
	}
}

- (NSString *)stringByRemovingName:(NSString *)name FromString:(NSString *)string {
	NSString *newString = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ - ", name] withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	newString = [newString stringByReplacingOccurrencesOfString:@".mkv" withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".cbr" withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".avi" withString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@".srt" withString:@""];
	return newString;
}

- (NSString *)imagesPathForFileName:(NSString *)name {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [NSString stringWithFormat:@"%@", [paths lastObject]];
	[manager createDirectoryAtPath:[NSString stringWithFormat:@"%@/Listing (Mac)/Images", [paths lastObject]] withIntermediateDirectories:YES attributes:nil error:nil];
	return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Listing (Mac)/Images/%@", name]];
}

@end
