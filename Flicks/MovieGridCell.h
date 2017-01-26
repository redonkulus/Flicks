//
//  MovieGridCell.h
//  Flicks
//
//  Created by Seth Bertalotto on 1/25/17.
//  Copyright © 2017 Seth Bertalotto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieModel.h"

@interface MovieGridCell : UICollectionViewCell

@property (strong, nonatomic) MovieModel *model;

- (void) reloadData;

@end
