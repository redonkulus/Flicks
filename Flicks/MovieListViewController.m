//
//  ViewController.m
//  Flicks
//
//  Created by Seth Bertalotto on 1/23/17.
//  Copyright © 2017 Seth Bertalotto. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>

#import "MovieListViewController.h"
#import "MovieCell.h"
#import "MovieGridCell.h"
#import "MovieModel.h"
#import "MovieDetailView.h"

@interface MovieListViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *movieTableView;
@property (strong, nonatomic) UICollectionView *movieCollectionView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewSegmentedControl;

@property (strong, nonatomic) NSArray<MovieModel *> *movies;
@property (strong, nonatomic) UIRefreshControl *tableRefreshControl;
@property (strong, nonatomic) UIRefreshControl *gridRefreshControl;
@property (strong, nonatomic) UISearchBar *searchBarControl;

@end

@implementation MovieListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.movieTableView.dataSource = self;
    self.movieTableView.delegate = self;

    // manual instead of via IB
    [self setupCollectionView];
    
    // setup pull to refresh
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(fetchMovies:) forControlEvents:UIControlEventValueChanged];
    [self.movieTableView insertSubview:self.tableRefreshControl atIndex:0];
    
    self.gridRefreshControl = [[UIRefreshControl alloc] init];
    [self.gridRefreshControl addTarget:self action:@selector(fetchMovies:) forControlEvents:UIControlEventValueChanged];
    [self.movieCollectionView insertSubview:self.gridRefreshControl atIndex:0];
    
    // setup search
    self.searchBarControl = [[UISearchBar alloc] init];
    self.searchBarControl.delegate = self;
    self.navigationItem.titleView = self.searchBarControl;
    
    // fetch data
    [self fetchMovies:nil];
}

- (void) setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat itemHeight = 200;
    CGFloat itemWidth = screenWidth / 3;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    // create the view
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 64) collectionViewLayout:layout];
    
    // register the custom class
    [collectionView registerClass:[MovieGridCell class] forCellWithReuseIdentifier:@"MovieGridCell"];
    
    // assign to self
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    [self.view addSubview:collectionView];

    // set to property
    self.movieCollectionView = collectionView;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self fetchMovies:nil];
}

- (void)fetchMovies:(UIRefreshControl *)refreshControl
{
    UIView *currentView = [self getCurrentView];
    NSString *query = self.searchBarControl.text;
    
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString;
    
    // setup api URL
    if (query.length > 1) {
        urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/search/movie?query=%@&api_key=%@", query, apiKey];
    } else {
        urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", self.restorationIdentifier, apiKey];
    }
    
    // setup url instances
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    // overwrite default timeout values
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 10.0;
    sessionConfig.timeoutIntervalForResource = 10.0;
    
    // setup sessions instance
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    // reset error and show progress
    self.errorView.hidden = true;
    
    if (refreshControl == nil && query.length == 0) {
        [MBProgressHUD showHUDAddedTo:currentView animated:YES];
    }
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSError *jsonError = nil;
                NSDictionary *responseDictionary =
                [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions
                                                  error:&jsonError];
                // NSLog(@"Response: %@", responseDictionary);
                NSArray *results = responseDictionary[@"results"];
                
                // create an array to hold models
                NSMutableArray *models = [NSMutableArray array];

                // create model for each result
                for (NSDictionary *result in results) {
                    MovieModel *model = [[MovieModel alloc] initWithDictionary:result];
                    
                    [models addObject:model];
                }
                
                // save to property
                self.movies = models;
                
                // hide network error view
                self.errorView.hidden = true;
                
                // update the views
                [self showCurrentView];
                
            } else {
                NSLog(@"An error occurred: %@", error.description);
                // show network error view
                self.errorView.hidden = false;
            }
            
            // turn off refresh control
            if (refreshControl != nil) {
                [refreshControl endRefreshing];
            } else {
                [MBProgressHUD hideHUDForView:currentView animated:YES];
            }
        }];
    [task resume];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MovieCell* cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell"];
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = model.title;
    cell.overviewLabel.text = model.overview;
    
    // load poster image and fade to view
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:model.posterUrl];
    [cell.posterImage setImageWithURLRequest:request placeholderImage:nil
       success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
           cell.posterImage.contentMode = UIViewContentModeScaleAspectFit;
           
           cell.posterImage.alpha = 0.0;
           cell.posterImage.image = image;
           [UIView animateWithDuration:0.3 animations:^{
               cell.posterImage.alpha = 1.0;
           }];
       }
       failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
           NSLog(@"Image fetch error %@", response);
       }
     ];

    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieGridCell" forIndexPath:indexPath];
    MovieModel *model = [self.movies objectAtIndex:indexPath.item];
    
    cell.model = model;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.movies.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

// setup segue for collection view cell 
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showMovieDetailView" sender:cell];
}

// event handlers
- (IBAction)onViewChanged:(id)sender {
    [self showCurrentView];
}

// gets view based on selected ui control
- (UIScrollView *) getCurrentView
{
    long view = self.viewSegmentedControl.selectedSegmentIndex;
    if (view == 0) {
        return self.movieTableView;
    } else if (view == 1) {
        return self.movieCollectionView;
    }
    return nil;
}

// helper method to toggle between views
- (void) showCurrentView
{
    long view = self.viewSegmentedControl.selectedSegmentIndex;
    if (view == 0) {
        [self.movieTableView reloadData];
        self.movieTableView.hidden = false;
        self.movieCollectionView.hidden = true;
    } else if (view == 1) {
        [self.movieCollectionView reloadData];
        self.movieCollectionView.hidden = false;
        self.movieTableView.hidden = true;
    }
}

// grab selected table view and pass model to destination controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMovieDetailView"]) {
        NSIndexPath *indexPath;
        long view = self.viewSegmentedControl.selectedSegmentIndex;
        if (view == 0) {
            indexPath = [self.movieTableView indexPathForSelectedRow];
        } else if (view == 1) {
            indexPath = [self.movieCollectionView indexPathForCell:sender];
        }
        
        MovieDetailView *movieDetailView = segue.destinationViewController;
        
        // grab model based on cell selected
        MovieModel *model = [self.movies objectAtIndex:indexPath.row];
        movieDetailView.movieModel = model;
    }
}

@end
