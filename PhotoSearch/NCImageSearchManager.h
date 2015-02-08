//
//  NCImageSearchManager.h
//  PhotoSearch
//
//  Created by Nico on 07/02/2015.
//  Copyright (c) 2015 Nico. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ImageSearchManagerErrorDomain;

typedef NS_ENUM(NSInteger, ImageSearchManagerError) {
    ImageSearchManagerInvalidContentError = 1,
    ImageSearchManagerConnectionError,
    ImageSearchManagerUnknownError
};

@interface NCImageSearchManager : NSObject

+ (id)sharedManager;

- (void)imageURLsForKeywords:(NSString *)keywords
                     completion:(void (^)(NSArray *results, NSError *error))completion;

- (void)imageURLsForKeywords:(NSString *)keywords
                      withStart:(NSUInteger)start
                     completion:(void (^)(NSArray *results, NSError *error))completion;

@end
