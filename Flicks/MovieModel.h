//
//  MovieModel.h
//  Flicks
//
//  Created by Seth Bertalotto on 1/23/17.
//  Copyright © 2017 Seth Bertalotto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *overview;
@property (nonatomic, strong) NSString *releaseDate;
@property (nonatomic, assign) float voteAverage;
@property (nonatomic, strong) NSURL *posterUrl;
@property (nonatomic, strong) NSURL *posterUrlOrig;

@end
