//
//  SearchViewController.m
//  NCPhotoSearch
//
//  Created by Nico on 07/02/2015.
//  Copyright (c) 2015 Nico. All rights reserved.
//

#import "NCSearchViewController.h"
#import "NCSearchHistory.h"
#import "AppDelegate.h"

@interface NCSearchViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate>
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NCSearchHistory *searchHistory;
@end

static NSString * const CellIdentifier = @"Cell";

@implementation NCSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchHistory = [[NCSearchHistory alloc] init];
    
    // Navigation Bar
    self.title = NSLocalizedString(@"Search", @"Search Title");
    self.navigationController.navigationBar.translucent = NO;
    
    // Search Bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.showsCancelButton = YES;
    self.searchBar.tintColor = [UIColor blackColor];
    self.searchBar.backgroundColor = [UIColor whiteColor];
    [self.searchBar becomeFirstResponder];
    [self.view addSubview:self.searchBar];
    
    // Table View
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    // Auto Layout
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"tableView": self.tableView, @"search": self.searchBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[search]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[search][tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchHistory.history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.searchHistory.history[indexPath.row];
    return cell;
}

#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *keywords = self.searchHistory.history[indexPath.row];
    [self searchKeywords:keywords];
}

#pragma mark <UISearchBarDelegate>

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissWithCompletion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchKeywords:searchBar.text];
}

#pragma mark - Dismissing and Search

- (void)searchKeywords:(NSString *)keywords
{
    [self.searchHistory addToHistory:keywords];
    [self dismissWithCompletion:^{
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate.viewController searchImagesWithKeywords:keywords];
    }];
}

- (void)dismissWithCompletion:(void (^)(void))completion
{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        if (completion) {
            completion();
        }
    }];
}

@end
