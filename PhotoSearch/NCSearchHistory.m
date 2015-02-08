//
//  NCSearchHistory.m
//  PhotoSearch
//
//  Created by Nico on 07/02/2015.
//  Copyright (c) 2015 Nico. All rights reserved.
//

#import "NCSearchHistory.h"

@interface NCSearchHistory ()
@property (nonatomic, readwrite) NSArray *history;
@end

static NSString *const UserDefaultSearchHistoryKey = @"searchHistory";
static const NSUInteger ResultsInSearchHistory = 8;

@implementation NCSearchHistory

- (NSArray *)history
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults arrayForKey:UserDefaultSearchHistoryKey] ? : @[];
}

- (void)setHistory:(NSArray *)history
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:history
                     forKey:UserDefaultSearchHistoryKey];
    [userDefaults synchronize];
}

- (void)addToHistory:(NSString *)keywords
{
    NSMutableArray *mutableHistory = [self.history mutableCopy];
    [mutableHistory removeObject:keywords];
    while (mutableHistory.count >= ResultsInSearchHistory) {
        [mutableHistory removeLastObject];
    }
    [mutableHistory insertObject:keywords atIndex:0];
    self.history = mutableHistory;
}

@end
