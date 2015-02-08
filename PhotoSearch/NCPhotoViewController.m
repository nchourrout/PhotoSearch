//
//  NCPhotoViewController.m
//  PhotoSearch
//
//  Created by Nico on 07/02/2015.
//  Copyright (c) 2015 Nico. All rights reserved.
//

#import "NCPhotoViewController.h"
#import "NCSearchViewController.h"
#import "NCImageCell.h"
#import "NCImageSearchManager.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface NCPhotoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *imageURLs;
@property (nonatomic) NSString *keywords;
@end

static NSString * const URLKey          = @"url";
static NSString * const ThumbnailURLKey = @"tbUrl";
static NSString * const CellIdentifier  = @"Cell";

@implementation NCPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"NCImageCell" bundle:nil]
          forCellWithReuseIdentifier:CellIdentifier];
    
    [self customizeNavigationBar];
    
    self.imageURLs = [@[] mutableCopy];
    
    [self searchImagesWithKeywords:@"rafa"];
}

- (void)customizeNavigationBar
{
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                            target:self
                                                                            action:@selector(displaySearch)];
    search.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = search;
    
    self.title = NSLocalizedString(@"Photo Search", @"Header title");
}

- (void)displaySearch
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    NCSearchViewController *searchViewController = [[NCSearchViewController alloc] init];
    [navigationController pushViewController:searchViewController animated:NO];
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void)searchImagesWithKeywords:(NSString *)keywords
{
    NCImageSearchManager *manager = [NCImageSearchManager sharedManager];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [manager imageURLsForKeywords:keywords
                       completion:^(NSArray *results, NSError *error) {
                           if (results && !error) {
                               self.imageURLs = [results mutableCopy];
                               self.keywords = keywords;
                               self.title = [NSString stringWithFormat:NSLocalizedString(@"Search for %@", @"Header title"), keywords];
                               [self.collectionView reloadData];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                               });
                           } else if (error) {
                               [self displayError:error];
                           }
                       }];
}


- (void)fetchMoreResults
{
    NCImageSearchManager *manager = [NCImageSearchManager sharedManager];
    [manager imageURLsForKeywords:self.keywords
                        withStart:self.imageURLs.count
                       completion:^(NSArray *results, NSError *error) {
                           if (results && !error) {
                               [self.imageURLs addObjectsFromArray:results];
                               [self.collectionView reloadData];
                           }
                       }];
}

- (void)displayError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:keyWindow];
    [keyWindow addSubview:hud];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = NSLocalizedString(@"Error", @"Error title");
    NSString *message;
    switch (error.code) {
        case ImageSearchManagerConnectionError:
            message = NSLocalizedString(@"Connection error, please make sure you're connected", "Connection error message");
            break;
        default:
            message = NSLocalizedString(@"Unknown Error", "Unknown error message");
            break;
    }
    hud.detailsLabelText = message;
    [hud show:YES];
    [hud hide:YES afterDelay:5.0];
}

#pragma mark <UICollectionViewDataSource>

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageURLs.count;
}

- (NCImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NCImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSURL *url = [NSURL URLWithString:self.imageURLs[indexPath.item][ThumbnailURLKey]];
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];

    [cell.imageView setImageWithURL:url placeholderImage:placeholderImage];
    
    if (indexPath.item == [self.imageURLs count] - 1) {
        [self fetchMoreResults];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [NSURL URLWithString:self.imageURLs[indexPath.item][URLKey]];
    [[UIApplication sharedApplication] openURL:url];
}

@end
