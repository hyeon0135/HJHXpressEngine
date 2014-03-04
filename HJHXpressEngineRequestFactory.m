//
//  HJHXpressEngineRequestFactory.m
//  XpressEngine
//
//  Created by Jonghwan Hyeon on 3/3/14.
//  Copyright (c) 2014 Jonghwan Hyeon. All rights reserved.
//

#import "HJHXpressEngineRequestFactory.h"
#import "NSDictionary+QueryString.h"

@interface HJHXpressEngineRequestFactory ()
@property (strong, nonatomic) NSURL *baseURL;
@end

@implementation HJHXpressEngineRequestFactory

#pragma mark - initalizer
- (instancetype)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        self.baseURL = baseURL;
    }
    
    return self;
}

+ (instancetype)factoryWithBaseURL:(NSURL *)baseURL
{
    return [[self.class alloc] initWithBaseURL:baseURL];
}

#pragma mark - logging in / out
- (NSURLRequest *)requestForLoggingInWithIdentifier:(NSString *)identifier password:(NSString *)password
{
    return [self requestWithMethod:@"POST" parameter:@{@"module": @"member",
                                                       @"act": @"procMemberLogin",
                                                       @"user_id": identifier,
                                                       @"password": password}];
}

- (NSURLRequest *)requestForLoggingOut
{
    return [self requestWithMethod:@"POST" parameter:@{@"module": @"member",
                                                       @"act": @"procMemberLogout"}];
}

#pragma mark - fetching
- (NSURLRequest *)requestForFetchingDocumentsFromBoardModuleIdentifier:(NSString *)identifier
                                                                   onPage:(NSUInteger)page
{
    return [self requestWithMethod:@"GET" parameter:@{@"module": @"board",
                                                      @"act": @"dispBoardContentList",
                                                      @"mid": identifier,
                                                      @"page": [NSNumber numberWithInteger:page]}];
}

- (NSURLRequest *)requestForFetchingDocumentFromDocumentIdentifier:(NSString *)identifier
{
    return [self requestWithMethod:@"GET" parameter:@{@"module": @"board",
                                                      @"act": @"dispBoardContentView",
                                                      @"document_srl": identifier}];
}

- (NSURLRequest *)requestForFetchingCommentsFromDocumentIdentifier:(NSString *)identifier
{
    return [self requestWithMethod:@"GET" parameter:@{@"module": @"board",
                                                      @"act": @"dispBoardContentCommentList",
                                                      @"document_srl": identifier}];
}

- (NSURLRequest *)requestForFetchingFileInformationsFromDocumentIdentifier:(NSString *)identifier
{
    return [self requestWithMethod:@"GET" parameter:@{@"module": @"board",
                                                      @"act": @"dispBoardContentFileList",
                                                      @"document_srl": identifier}];
}

- (NSURLRequest *)requestForFetchingFileFromLocation:(NSString *)location
{
    NSURL *fileURL = [NSURL URLWithString:location relativeToURL:self.baseURL];
    
    return [NSURLRequest requestWithURL:fileURL];
}

#pragma mark - writing
- (NSURLRequest *)requestForWritingDocumentOnBoardModuleIdentifier:(NSString *)identifier
                                                         withTitle:(NSString *)title
                                                          contents:(NSString *)contents
{
    return [self requestWithMethod:@"POST" parameter:@{@"module": @"board",
                                                       @"act": @"procBoardInsertDocument",
                                                       @"mid": identifier,
                                                       @"title": title,
                                                       @"content": contents}];
}

- (NSURLRequest *)requestForWritingCommentOnDocumentIdentifier:(NSString *)identifier
                                                  withContents:(NSString *)contents
{
    return [self requestWithMethod:@"POST" parameter:@{@"module": @"board",
                                                       @"act": @"procBoardInsertComment",
                                                       @"document_srl:": identifier,
                                                       @"content": contents}];
}

#pragma mark - modifying
- (NSURLRequest *)requestForModifyingDocumentHavingDocumentIdentifier:(NSString *)identifier
                                                            withTitle:(NSString *)title
                                                             contents:(NSString *)contents
{
    return [self requestWithMethod:@"POST" parameter:@{@"module": @"board",
                                                       @"act": @"procBoardInsertDocument",
                                                       @"document_srl:": identifier,
                                                       @"title": title,
                                                       @"content": contents}];
}

#pragma mark - liking
- (NSURLRequest *)requestForModifyingCommentOnDocumentIdentifier:(NSString *)documentIdentifier
                                         havingCommentIdentifier:(NSString *)commentIdentifier
                                                    withContents:(NSString *)contents
{
    return [self requestWithMethod:@"POST" parameter:@{@"module": @"board",
                                                       @"act": @"procBoardInsertComment",
                                                       @"document_srl:": documentIdentifier,
                                                       @"comment_srl:": commentIdentifier,
                                                       @"content": contents}];
}

- (NSURLRequest *)requestForLikingDocumentHavingDocumentIdentifier:(NSString *)identifier
{
    return [self requestWithMethod:@"POST" parameter:@{@"module": @"document",
                                                       @"act": @"procDocumentVoteUp",
                                                       @"target_srl:": identifier}];
}
- (NSURLRequest *)requestForLikingCommentHavingCommentIdentifier:(NSString *)identifier
{
    return [self requestWithMethod:@"POST" parameter:@{@"module": @"comment",
                                                       @"act": @"procCommentVoteUp",
                                                       @"target_srl:": identifier}];
}


#pragma mark - disliking
- (NSURLRequest *)requestForDislikingDocumentHavingDocumentIdentifier:(NSString *)identifier
{
    return [self requestWithMethod:@"POST" parameter:@{@"module": @"document",
                                                       @"act": @"procDocumentVoteDown",
                                                       @"target_srl:": identifier}];
}
- (NSURLRequest *)requestForDislikingCommentHavingCommentIdentifier:(NSString *)identifier
{
    return [self requestWithMethod:@"POST" parameter:@{@"module": @"comment",
                                                       @"act": @"procCommentVoteDown",
                                                       @"target_srl:": identifier}];
}

- (NSURLRequest *)requestWithMethod:(NSString *)method parameter:(NSDictionary *)parameter
{
    method = method.uppercaseString;
    
    NSURL *URL = self.baseURL;
    if ([method isEqualToString:@"GET"]) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:self.baseURL resolvingAgainstBaseURL:YES];
        components.query = parameter.queryString;
        
        URL = components.URL;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = method;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if ([method isEqualToString:@"POST"]) {
        request.HTTPBody = [parameter.queryString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    }

    return request;
}

@end
