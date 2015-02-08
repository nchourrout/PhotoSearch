//
//  NCPhotoDownloader.m
//  PhotoSearch
//
//  Created by Nico on 07/02/2015.
//  Copyright (c) 2015 Nico. All rights reserved.
//

#import "NCImageSearchManager.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <AFNetworking/AFHTTPRequestOperation.h>


@interface NCImageSearchManager ()
@property (nonatomic) NSOperationQueue *downloadQueue;
@property (nonatomic) AFHTTPRequestOperationManager *requestManager;
@end

NSString *const ImageSearchManagerErrorDomain = @"ImageSearchManagerErrorDomain";

static NSString * const BaseURL               = @"https://ajax.googleapis.com/ajax/services/search/";

static NSString * const ResponseDataKey       = @"responseData";
static NSString * const ResponseStatusKey     = @"responseStatus";
static NSString * const ResultsKey            = @"results";
static NSString * const URLKey                = @"url";
static NSString * const ThumbnailURLKey       = @"tbUrl";

@implementation NCImageSearchManager

+ (id)sharedManager
{
    static NCImageSearchManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        [_sharedManager configureManager];
    });
    return _sharedManager;
}

- (void)configureManager
{
    self.requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    self.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
}

- (void)imageURLsForKeywords:(NSString *)keywords
                   withStart:(NSUInteger)start
                  completion:(void (^)(NSArray *results, NSError *error))completion
{
    if (!keywords) {
        return;
    }
    
    NSDictionary *parameters = @{ @"v"     : @"1.0",
                                  @"q"     : keywords,
                                  @"start" : @(start) };
    
    [self.requestManager GET:@"images"
                  parameters:parameters
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         if ([self isValidResponse:responseObject]) {
                             NSArray *results = responseObject[ResponseDataKey][ResultsKey];
                             if (completion) {
                                 completion(results, nil);
                             }
                         } else if (completion) {
                             completion(nil, [NSError errorWithDomain:ImageSearchManagerErrorDomain
                                                                 code:ImageSearchManagerInvalidContentError
                                                             userInfo:nil]);
                         }
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         if (completion) {
                             completion(nil, [NSError errorWithDomain:ImageSearchManagerErrorDomain
                                                                 code:ImageSearchManagerConnectionError
                                                             userInfo:nil]);
                         }
                     }];
}

- (BOOL)isValidResponse:(NSDictionary *)dictionary
{
    NSDictionary *response = dictionary[ResponseDataKey];
    if (!response || [dictionary[ResponseStatusKey] integerValue] != 200) {
        return NO;
    }
    NSArray *results = response[ResultsKey];
    if (!results) {
        return NO;
    }
    for (NSDictionary *image in results) {
        if (!image[URLKey] && !image[ThumbnailURLKey]) {
            return NO;
        }
    }
    return YES;
}

- (void)imageURLsForKeywords:(NSString *)keywords
                  completion:(void (^)(NSArray *results, NSError *error))completion
{
    [self cancelAllRequests];
    [self imageURLsForKeywords:keywords
                     withStart:0
                    completion:^(NSArray *results, NSError *error) {
                        completion(results, error);
                    }];
}

- (void)cancelAllRequests
{
    [self.requestManager.operationQueue cancelAllOperations];
}

@end
