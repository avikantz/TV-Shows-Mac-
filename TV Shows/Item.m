//
//  Item.m
//  LionTableViewTesting
//
//  Created by Tomaž Kragelj on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

@implementation Item

@synthesize itemDisplayName = _itemDisplayName;
@synthesize itemPath = _itemPath;
@synthesize itemKind = _itemKind;
@synthesize itemIcon = _itemIcon;
@synthesize itemSize = _itemSize;

- (void)dealloc {
	
}

- (NSString *)itemDisplayName {
	if (_itemDisplayName)
		return _itemDisplayName;
	_itemDisplayName = [[NSFileManager defaultManager] displayNameAtPath:self.itemPath];
	return _itemDisplayName;
}

- (NSString *)itemKind {
//	if (_itemKind)
//		return _itemKind;
	if ([self.itemDisplayName containsString:@".app"])
		_itemKind = @"Application";
	else if ([self.itemDisplayName containsString:@".mkv"])
		_itemKind = @"Matroska Video";
	else if ([self.itemDisplayName containsString:@".mp4"])
		_itemKind = @"H264 Video";
	else if ([self.itemDisplayName containsString:@".avi"])
		_itemKind = @"xViD Video";
	else if ([self.itemDisplayName containsString:@".mov"])
		_itemKind = @"MOV Video File";
	else if ([self.itemDisplayName containsString:@".cbz"])
		_itemKind = @"Comic Book";
	else if ([self.itemDisplayName containsString:@".cbr"])
		_itemKind = @"Comic Book";
	else if ([self.itemDisplayName containsString:@".rmvb"])
		_itemKind = @"Real Video";
	else if ([self.itemDisplayName containsString:@".srt"])
		_itemKind = @"Subtitle";
	else if ([self.itemDisplayName containsString:@".jpg"])
		_itemKind = @"JPG Image";
	else if ([self.itemDisplayName containsString:@".png"])
		_itemKind = @"PNG Image";
	else
		_itemKind = @"Folder";
	return _itemKind;
}

-(CGFloat)itemSize {
	if (_itemSize) return _itemSize;
	_itemSize = ([[[NSFileManager defaultManager] attributesOfItemAtPath:self.itemPath error:nil] fileSize])/pow(10, 9);
	return _itemSize;
}

- (NSImage *)itemIcon {
	if (_itemIcon) return _itemIcon;
	_itemIcon = [[NSWorkspace sharedWorkspace] iconForFile:self.itemPath];
	return _itemIcon;
}

@end
