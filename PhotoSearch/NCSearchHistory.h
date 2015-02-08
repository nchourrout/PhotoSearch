//
//  NCSearchHistory.h
//  PhotoSearch
//
//  Created by Nico on 07/02/2015.
//  Copyright (c) 2015 Nico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCSearchHistory : NSObject

@property (nonatomic, readonly) NSArray *history;

- (void)addToHistory:(NSString *)keywords;

@end
