//
//  Item.h
//  LionTableViewTesting
//
//  Created by Tomaž Kragelj on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Item : NSObject

@property (nonatomic, copy) NSString *itemPath;
@property (nonatomic, readonly) NSString *itemDisplayName;
@property (nonatomic, readonly) NSString *itemKind;
@property (nonatomic, readonly) NSImage *itemIcon;
@property (nonatomic) CGFloat itemSize;

@end
