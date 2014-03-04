//
//  HJHXpressEngine.m
//  XpressEngine
//
//  Created by Jonghwan Hyeon on 3/3/14.
//  Copyright (c) 2014 Jonghwan Hyeon. All rights reserved.
//

#import "HJHXpressEngine.h"
#import "HJHXpressEngineRequestFactory.h"

#import "NSDictionary+Entity.h"

@interface HJHXpressEngine ()
@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) HJHXpressEngineRequestFactory *requestFactory;

@property (strong, nonatomic) NSURLSession *session;

@property (readwrite, nonatomic) BOOL isLoggedIn;
@end

@implementation HJHXpressEngine

#pragma mark - initializer
- (instancetype)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        self.baseURL = baseURL;
        self.isLoggedIn = NO;
    }
    
    return self;
}

+ (instancetype)xpressEngineWithBaseURL:(NSURL *)baseURL
{
    return [[self.class alloc] initWithBaseURL:baseURL];
}

- (HJHXpressEngineRequestFactory *)requestFactory
{
    if (!_requestFactory) {
        _requestFactory = [HJHXpressEngineRequestFactory factoryWithBaseURL:self.baseURL];
    }
    
    return _requestFactory;
}

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sharedSession];
    }
    
    return _session;
}

#pragma mark - logging in / out
- (void)loginWithIdentifier:(NSString *)identifier password:(NSString *)password
                    success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSError *error))failure
{
    self.isLoggedIn = NO;
    
    NSURLRequest *request = [self.requestFactory requestForLoggingInWithIdentifier:identifier password:password];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          self.isLoggedIn = YES;
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (success) {
                                  success(@{@"isLoggedIn": @(YES)});
                              }
                          });
                      } failure:failure];
}

- (void)logout
{
    NSURLRequest *request = [self.requestFactory requestForLoggingOut];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          self.isLoggedIn = NO;
                      } failure:nil];
}

#pragma mark - fetching
- (void)fetchDocumentListFromBoardModuleIdentifier:(NSString *)identifier onPage:(NSUInteger)page
                                           success:(void (^)(NSDictionary *response))success
                                           failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self.requestFactory requestForFetchingDocumentsFromBoardModuleIdentifier:identifier onPage:page];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          NSMutableArray *documents = [NSMutableArray array];
                          for (NSDictionary *JSONDocument in JSONResponse[@"document_list"]) {
                              [documents addObject:@{@"identifier": [JSONDocument[@"document_srl"] description],
                                                        @"title": JSONDocument[@"title"],
                                                        @"commentCount": JSONDocument[@"comment_count"],
                                                        @"hits": JSONDocument[@"readed_count"],
                                                        @"username": JSONDocument[@"user_name"],
                                                        @"nickname": JSONDocument[@"nick_name"],
                                                        @"writtenDate": [self dateFromXpressEngineDateString:JSONDocument[@"regdate"]],
                                                        @"likeCount": JSONDocument[@"voted_count"],
                                                        @"dislikeCount": JSONDocument[@"blamed_count"]}];
                          }
                          
                          NSDictionary *JSONPagination = JSONResponse[@"page_navigation"];
                          NSDictionary *pagination = @{@"firstPage": JSONPagination[@"first_page"],
                                                       @"currentPage": JSONPagination[@"cur_page"],
                                                       @"lastPage": JSONPagination[@"last_page"],
                                                       @"totalDocumentCount": JSONPagination[@"total_count"]};
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"documents": documents,
                                        @"pagination": pagination});
                          });
                      } failure:failure];
}

- (void)fetchDocumentFromDocumentIdentifier:(NSString *)identifier
                                    success:(void (^)(NSDictionary *response))success
                                    failure:(void (^)(NSError *error))failure
{
    
    NSURLRequest *request = [self.requestFactory requestForFetchingDocumentFromDocumentIdentifier:identifier];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          NSDictionary *JSONDocument = JSONResponse[@"oDocument"];
                          NSDictionary *document = @{@"identifier": [JSONDocument[@"document_srl"] description],
                                                     @"title": JSONDocument[@"title"],
                                                     @"contents": JSONDocument[@"content"],
                                                     @"commentCount": JSONDocument[@"comment_count"],
                                                     @"hits": JSONDocument[@"readed_count"],
                                                     @"username": JSONDocument[@"user_name"],
                                                     @"nickname": JSONDocument[@"nick_name"],
                                                     @"writtenDate": [self dateFromXpressEngineDateString:JSONDocument[@"regdate"]],
                                                     @"likeCount": JSONDocument[@"voted_count"],
                                                     @"dislikeCount": JSONDocument[@"blamed_count"]};
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"document": document});
                          });
                      } failure:failure];
}

- (void)fetchCommentsFromDocumentIdentifier:(NSString *)identifier
                                    success:(void (^)(NSDictionary *response))success
                                    failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self.requestFactory requestForFetchingCommentsFromDocumentIdentifier:identifier];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          NSMutableArray *comments = [NSMutableArray array];
                          for (NSDictionary *JSONComment in JSONResponse[@"comments"]) {
                              [comments addObject:@{@"identifier": [JSONComment[@"comment_srl"] description],
                                                       @"contents": JSONComment[@"content"],
                                                       @"username": JSONComment[@"user_name"],
                                                       @"nickname": JSONComment[@"nick_name"],
                                                       @"writtenDate": [self dateFromXpressEngineDateString:JSONComment[@"regdate"]],
                                                       @"likeCount": JSONComment[@"voted_count"],
                                                       @"dislikeCount": JSONComment[@"blamed_count"]}];
                          }
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"comments": comments});
                          });
                      } failure:failure];
}

- (void)fetchFileInformationsFromDocumentIdentifier:(NSString *)identifier
                                            success:(void (^)(NSDictionary *))success
                                            failure:(void (^)(NSError *))failure
{
    NSURLRequest *request = [self.requestFactory requestForFetchingFileInformationsFromDocumentIdentifier:identifier];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          NSMutableArray *files = [NSMutableArray array];
                          for (NSDictionary *JSONFile in JSONResponse[@"file_list"]) {
                              [files addObject:@{@"fileSize": JSONFile[@"file_size"],
                                                 @"uploadedDate": [self dateFromXpressEngineDateString:JSONFile[@"regdate"]],
                                                 @"filename": JSONFile[@"source_filename"],
                                                 @"location": JSONFile[@"uploaded_filename"]}];
                          }
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"files": files});
                          });
                      } failure:failure];
}

- (void)fetchFileFromLocation:(NSString *)location
                      success:(void (^)(NSDictionary *))success
                      failure:(void (^)(NSError *))failure
{
    NSURLRequest *request = [self.requestFactory requestForFetchingFileFromLocation:location];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (failure) {
                    failure(error);
                }
            } else {
                if (success) {
                    success(@{@"file": data});
                }
            }
        });
    }];
    [task resume];
}

#pragma mark - writing
- (void)writeDocumentOnBoardModuleIdentifier:(NSString *)identifier
                                   withTitle:(NSString *)title contents:(NSString *)contents
                                     success:(void (^)(NSDictionary *response))success
                                     failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self.requestFactory requestForWritingDocumentOnBoardModuleIdentifier:identifier withTitle:title contents:contents];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"identifier": [JSONResponse[@"document_srl"] description]});
                          });
                      } failure:failure];
}

- (void)writeCommentOnDocumentIdentifier:(NSString *)identifier
                               withTitle:(NSString *)title contents:(NSString *)contents
                                 success:(void (^)(NSDictionary *response))success
                                 failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self.requestFactory requestForWritingCommentOnDocumentIdentifier:identifier withContents:contents];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"identifier": [JSONResponse[@"comment_srl"] description]});
                          });
                      } failure:failure];
}

#pragma mark - modifying
- (void)modifyDocumentHavingDocumentIdentifier:(NSString *)identifier
                                     withTitle:(NSString *)title contents:(NSString *)contents
                                       success:(void (^)(NSDictionary *response))success
                                       failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self.requestFactory requestForModifyingDocumentHavingDocumentIdentifier:identifier withTitle:title contents:contents];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"identifier": [JSONResponse[@"document_srl"] description]});
                          });
                      } failure:failure];
}

- (void)modifyCommentOnDocumentIdentifier:(NSString *)documentIdentifier
                  havingCommentIdentifier:(NSString *)commentIdentifier
                             withContents:(NSString *)contents
                                  success:(void (^)(NSDictionary *response))success
                                  failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self.requestFactory requestForModifyingCommentOnDocumentIdentifier:documentIdentifier
                                                                        havingCommentIdentifier:commentIdentifier
                                                                                   withContents:contents];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"identifier": [JSONResponse[@"comment_srl"] description]});
                          });
                      } failure:failure];
}

#pragma mark - liking
- (void)likeDocumentHavingDocumentIdentifier:(NSString *)identifier
                                     success:(void (^)(NSDictionary *response))success
                                     failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self.requestFactory requestForLikingDocumentHavingDocumentIdentifier:identifier];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"success": @(YES)});
                          });
                      } failure:failure];
}

- (void)likeCommentHavingCommentIdentifier:(NSString *)identifier
                                   success:(void (^)(NSDictionary *response))success
                                   failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self.requestFactory requestForLikingCommentHavingCommentIdentifier:identifier];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"success": @(YES)});
                          });
                      } failure:failure];
}

#pragma mark - disliking
- (void)dislikeDocumentHavingDocumentIdentifier:(NSString *)identifier
                                        success:(void (^)(NSDictionary *response))success
                                        failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self.requestFactory requestForDislikingDocumentHavingDocumentIdentifier:identifier];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"success": @(YES)});
                          });
                      } failure:failure];
}

- (void)dislikeCommentHavingCommentIdentifier:(NSString *)identifier
                                      success:(void (^)(NSDictionary *response))success
                                      failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self.requestFactory requestForDislikingCommentHavingCommentIdentifier:identifier];
    [self sendRequestWithRequest:request
                      completion:^(NSDictionary *JSONResponse) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              success(@{@"success": @(YES)});
                          });
                      } failure:failure];
}

#pragma mark - utility
- (void)sendRequestWithRequest:(NSURLRequest *)request
                    completion:(void(^)(NSDictionary *JSONResponse))completion
                       failure:(void (^)(NSError *error))failure
{
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error);
                }
            });
            
            return;
        }
    
        NSDictionary *JSONResponse = [[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] dictionaryByUnescapingEntities];
        if ([self JSONResponseHasError:JSONResponse]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure([self errorFromJSONResponse:JSONResponse]);
                }
            });
            
            return;
        }
        
        if (completion) {
            completion(JSONResponse);
        }
    }];
    [task resume];
}

- (NSDate *)dateFromXpressEngineDateString:(NSString *)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyymmddHHmmss";
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
    
    return [formatter dateFromString:dateString];
}

- (BOOL)JSONResponseHasError:(NSDictionary *)JSONResponse
{
    return ([JSONResponse[@"error"] integerValue] != 0);
}


- (NSError *)errorFromJSONResponse:(NSDictionary *)JSONResponse
{
    return [NSError errorWithDomain:@"me.jongwhan.HJHXpressEngine"
                               code:100
                           userInfo:@{@"message": JSONResponse[@"message"]}];
}
@end
