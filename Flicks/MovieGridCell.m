//
//  MovieGridCell.m
//  Flicks
//
//  Created by Seth Bertalotto on 1/25/17.
//  Copyright © 2017 Seth Bertalotto. All rights reserved.
//

#import "MovieGridCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MovieGridCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MovieGridCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

- (void)reloadData
{
    // Establish the weak self reference
    __weak typeof(self) weakSelf = self;
    
    // load poster image and fade to view
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.model.posterUrl];
    [self.imageView setImageWithURLRequest:request placeholderImage:nil
       success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
           weakSelf.imageView.contentMode = UIViewContentModeScaleAspectFit;
           
           weakSelf.imageView.alpha = 0.0;
           weakSelf.imageView.image = image;
           [UIView animateWithDuration:0.3 animations:^{
               weakSelf.imageView.alpha = 1.0;
           }];
        }
       failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            NSLog(@"Image fetch error %@", response);
        }
     ];
    [self setNeedsLayout];
}

- (void)setModel:(MovieModel *)model
{
    _model = model;
    [self reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

@end
