//
//  ViewController.m
//  Flicks
//
//  Created by Seth Bertalotto on 1/23/17.
//  Copyright © 2017 Seth Bertalotto. All rights reserved.
//

#import "MovieListViewController.h"
#import "MovieCell.h"
#import "MovieModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>
#import "MovieDetailView.h"

@interface MovieListViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *movieTableView;
@property (strong, nonatomic) NSArray<MovieModel *> *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIView *errorView;

@end

@implementation MovieListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.movieTableView.dataSource = self;
    
    // setup pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.movieTableView insertSubview:self.refreshControl atIndex:0];
    
    // fetch data
    [self fetchMovies];
}

- (void)fetchMovies
{
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString =
    [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", self.restorationIdentifier, apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    // overwrite default timeout values
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 5.0;
    sessionConfig.timeoutIntervalForResource = 5.0;
    
    // setup sessions instance
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                              delegate:nil
                              delegateQueue:[NSOperationQueue mainQueue]];
    
    // reset error and show progress
    self.errorView.hidden = true;
    [MBProgressHUD showHUDAddedTo:self.movieTableView animated:YES];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                completionHandler:^(NSData * _Nullable data,
                                                    NSURLResponse * _Nullable response,
                                                    NSError * _Nullable error) {
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
                                        
                                        self.errorView.hidden = true;
                                        
                                        // update table with data
                                        [self.movieTableView reloadData];
                                        
                                    } else {
                                        NSLog(@"An error occurred: %@", error.description);
                                        self.errorView.hidden = false;
                                    }
                                    
                                    [self.refreshControl endRefreshing];
                                    [MBProgressHUD hideHUDForView:self.movieTableView animated:YES];
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
    // grab reference to model
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = model.title;
    cell.overviewLabel.text = model.overview;
    [cell.posterImage setImageWithURL:model.posterUrl];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.movies.count;
}

// grab selected table view and pass model to destination controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMovieDetailView"]) {
        NSIndexPath *indexPath = [self.movieTableView indexPathForSelectedRow];
        MovieDetailView *movieDetailView = segue.destinationViewController;
        
        // grab model based on cell selected
        MovieModel *model = [self.movies objectAtIndex:indexPath.row];
        movieDetailView.movieModel = model;
    }
}

@end
