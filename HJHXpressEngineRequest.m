//
//  HJHXpressEngineRequest.m
//  Uriuniv
//
//  Created by Jonghwan Hyeon on 2/10/14.
//  Copyright (c) 2014 Uriuniv. All rights reserved.
//

#import "HJHXpressEngineRequest.h"
#import "NSDictionary+QueryString.h"

#define XPRESS_ENGINE_URL @"http://dev.uriuniv.com/xe/"

@implementation HJHXpressEngineRequest

+ (NSURLRequest *)requestWithMethod:(NSString *)method
                             parameter:(NSDictionary *)parameter
{
    NSString *URLString = XPRESS_ENGINE_URL;
    if ([method isEqualToString:@"GET"]) {
        URLString = [URLString stringByAppendingFormat:@"?%@", parameter.queryString];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    request.HTTPMethod = method;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if ([method isEqualToString:@"POST"]) {
        request.HTTPBody = [parameter.queryString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    }
    
    return request;
}

+ (NSURLRequest *)requestForLoggingInWithIdentifier:(NSString *)identifier
                                           password:(NSString *)password
{
    return [[self class] requestWithMethod:@"POST"
                                 parameter:@{@"module": @"member",
                                             @"act": @"procMemberLogin",
                                             @"user_id": identifier,
                                             @"password": password}];
}

+ (NSURLRequest *)requestForLoggingOut
{
    return [[self class] requestWithMethod:@"POST"
                                 parameter:@{@"module": @"member",
                                             @"act": @"procMemberLogout"}];
}

+ (NSURLRequest *)requestForFetchingDocumentListFromModuleIdentifier:(NSString *)identifier
                                                              onPage:(NSInteger)page
{
    return [[self class] requestWithMethod:@"GET"
                                 parameter:@{@"module": @"board",
                                             @"act": @"dispBoardContentList",
                                             @"mid": identifier,
                                             @"page": [NSNumber numberWithInteger:page]}];
}

+ (NSURLRequest *)requestForFetchingDocumentFromDocumentIdentifier:(NSString *)identifier
{
    return [[self class] requestWithMethod:@"GET"
                                 parameter:@{@"module": @"board",
                                             @"act": @"dispBoardContentView",
                                             @"document_srl": identifier}];
}

+ (NSURLRequest *)requestForFetchingCommentsFromDocumentIdentifier:(NSString *)identifier
{
    return [[self class] requestWithMethod:@"GET"
                                 parameter:@{@"module": @"board",
                                             @"act": @"dispBoardContentCommentList",
                                             @"document_srl": identifier}];
}

+ (NSURLRequest *)requestForWritingDocumentOnModuleIdentifier:(NSString *)identifier
                                                    withTitle:(NSString *)title
                                                     contents:(NSString *)contents
{
    return [[self class] requestWithMethod:@"POST"
                                 parameter:@{@"module": @"board",
                                             @"act": @"procBoardInsertDocument",
                                             @"mid": identifier,
                                             @"title": title,
                                             @"content": contents}];
}

+ (NSURLRequest *)requestForModifyingDocumentHavingIdentifier:(NSString *)identifier
                                                    withTitle:(NSString *)title
                                                     contents:(NSString *)contents
{
    return [[self class] requestWithMethod:@"POST"
                                 parameter:@{@"module": @"board",
                                             @"act": @"procBoardInsertDocument",
                                             @"document_srl:": identifier,
                                             @"title": title,
                                             @"content": contents}];
}

+ (NSURLRequest *)requestForWritingCommentOnDocumentIdentifier:(NSString *)identifier
                                                  withContents:(NSString *)contents
{
    return [[self class] requestWithMethod:@"POST"
                                 parameter:@{@"module": @"board",
                                             @"act": @"procBoardInsertComment",
                                             @"document_srl:": identifier,
                                             @"content": contents}];
}

+ (NSURLRequest *)requestForModifyingCommentOnDocumentIdentifier:(NSString *)documentIdentifier
                                                havingIdentifier:(NSString *)commentIdentifier
                                                    withContents:(NSString *)contents
{
    return [[self class] requestWithMethod:@"POST"
                                 parameter:@{@"module": @"board",
                                             @"act": @"procBoardInsertComment",
                                             @"document_srl:": documentIdentifier,
                                             @"comment_srl:": commentIdentifier,
                                             @"content": contents}];
}

+ (NSURLRequest *)requestForLikingDocumentHavingIdentifier:(NSString *)identifier
{
    return [[self class] requestWithMethod:@"POST"
                                 parameter:@{@"module": @"document",
                                             @"act": @"procDocumentVoteUp",
                                             @"target_srl:": identifier}];
}

+ (NSURLRequest *)requestForDislikingDocumentHavingIdentifier:(NSString *)identifier
{
    return [[self class] requestWithMethod:@"POST"
                                 parameter:@{@"module": @"document",
                                             @"act": @"procDocumentVoteDown",
                                             @"target_srl:": identifier}];
}

+ (NSURLRequest *)requestForLikingCommentHavingIdentifier:(NSString *)identifier
{
    return [[self class] requestWithMethod:@"POST"
                                 parameter:@{@"module": @"comment",
                                             @"act": @"procCommentVoteUp",
                                             @"target_srl:": identifier}];
}

+ (NSURLRequest *)requestForDislikingCommentHavingIdentifier:(NSString *)identifier
{
    return [[self class] requestWithMethod:@"POST"
                                 parameter:@{@"module": @"comment",
                                             @"act": @"procCommentVoteDown",
                                             @"target_srl:": identifier}];
}

@end
