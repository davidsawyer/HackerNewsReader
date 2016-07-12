//
//  HNPageParser.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 5/7/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNPageParser.h"

#import <HackerNewsKit/HNPage.h>

#import "HNCommentParser.h"
#import "HNFeedParser.h"
#import "TFHpple.h"

@interface HNPageParser ()

@property (nonatomic, strong) HNFeedParser *feedParser;
@property (nonatomic, strong) HNCommentParser *commentParser;

@end

@implementation HNPageParser

- (instancetype)init {
    if (self = [super init]) {
        _feedParser = [[HNFeedParser alloc] init];
        _commentParser = [[HNCommentParser alloc] init];
    }
    return self;
}

- (id <NSCoding>)parseDataFromResponse:(NSData *)data queries:(HNQueries *)queries {
    if (!data.length) {
        return nil;
    }

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSArray *comments = (NSArray *)[self.commentParser commentsFromParser:parser queries:queries];

    static NSString * const textQuery = @"//table[@id='hnmain']/tr[4]/td/table[1]/tr[4]/td[2]";
    TFHppleElement *textNode = [[parser searchWithXPathQuery:textQuery] firstObject];
    NSArray *textComponets = nil;
    if ([[textNode content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
        textComponets = [self.commentParser commentComponentsFromNode:textNode];
    }

    TFHppleElement *titleNode = [[parser searchWithXPathQuery:queries.feedTitles] firstObject];
    TFHppleElement *detailNode = [[parser searchWithXPathQuery:queries.feedDetails] firstObject];
    HNPost *post = [self.feedParser postFromTitleNode:titleNode detailNode:detailNode rank:0 queries:queries];

    return [[HNPage alloc] initWithPost:post comments:comments textComponents:textComponets];
}

@end
