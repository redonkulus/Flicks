//
//  MovieModel.m
//  Flicks
//
//  Created by Seth Bertalotto on 1/23/17.
//  Copyright © 2017 Seth Bertalotto. All rights reserved.
//

#import "MovieModel.h"

@implementation MovieModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.title = dictionary[@"original_title"];
        self.overview = dictionary[@"overview"];
        
        // format release date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-mm-dd"];
        NSDate *date  = [dateFormatter dateFromString:dictionary[@"release_date"]];
        [dateFormatter setDateFormat:@"MMMM d, yyyy"];
        self.releaseDate = [dateFormatter stringFromDate:date];
        self.voteAverage = [[dictionary objectForKey:@"vote_average"] floatValue];
        
        // create poster images
        NSString *posterUrl = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w342%@", dictionary[@"poster_path"]];
        NSString *posterUrlOrig = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/original%@", dictionary[@"poster_path"]];
        
        // assign to properties
        self.posterUrl = [NSURL URLWithString:posterUrl];
        self.posterUrlOrig = [NSURL URLWithString:posterUrlOrig];
    }
    return self;
}

@end
