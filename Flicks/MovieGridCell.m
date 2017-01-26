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
    [self.imageView setImageWithURL:self.model.posterUrl];
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
