//
//  MovieDetailView.m
//  Flicks
//
//  Created by Seth Bertalotto on 1/23/17.
//  Copyright © 2017 Seth Bertalotto. All rights reserved.
//

#import "MovieDetailView.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MovieDetailView ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UILabel *movieReleaseDate;
@property (weak, nonatomic) IBOutlet UILabel *movieVoteAverage;
@property (weak, nonatomic) IBOutlet UILabel *movieOverview;

@end

@implementation MovieDetailView

- (void)viewDidLoad {
    [super viewDidLoad];

    // set ui elements based on model
    if (self.movieModel) {
        // title
        self.movieTitle.text = self.movieModel.title;
        
        // release date
        self.movieReleaseDate.text = self.movieModel.releaseDate;
        
        // rating
        self.movieVoteAverage.text = [NSString stringWithFormat: @"%0.1f", self.movieModel.voteAverage];
        
        // overview
        self.movieOverview.text = self.movieModel.overview;
        [self.movieOverview sizeToFit];
        
        // poster image
        [self.posterImage setImageWithURL:self.movieModel.posterUrl];
    }
    
    [self setupScrollView];
}

- (void)setupScrollView
{
    CGRect frame = self.cardView.frame;
    frame.size.height = self.movieOverview.frame.size.height +
    self.movieOverview.frame.origin.y + 10;
    self.cardView.frame = frame;
    
    CGFloat contentOffsetY = CGRectGetHeight(self.cardView.bounds);
    self.scrollView.contentInset = UIEdgeInsetsMake(180, 0, 0, 0);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, contentOffsetY);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
