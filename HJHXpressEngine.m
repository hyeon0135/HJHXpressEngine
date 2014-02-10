//
//  HJHXpressEngine.m
//  Uriuniv
//
//  Created by Jonghwan Hyeon on 2/10/14.
//  Copyright (c) 2014 Uriuniv. All rights reserved.
//

#import "HJHXpressEngine.h"
#import "HJHXpressEngineRequest.h"

@interface HJHXpressEngine ()
@property (strong, nonatomic) NSURLSession *session;
@end

@implementation HJHXpressEngine

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    self.isLoggedIn = NO;
    
    return self;
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sharedSession];
    }
    
    return _session;
}

- (void)loginWithIdentifier:(NSString *)identifier
                   password:(NSString *)password
           completionHander:(void (^)(BOOL isLoggedIn, NSError *error))completionHandler
{
    self.isLoggedIn = NO;
    
    NSURLRequest *request = [HJHXpressEngineRequest requestForLoggingInWithIdentifier:identifier
                                                                            password:password];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(NO, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(NO, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        self.isLoggedIn = YES;
        completionHandler(YES, NULL);
    }];
    [task resume];
}

- (void)logout
{
    self.isLoggedIn = NO;
    
    NSURLRequest *request = [HJHXpressEngineRequest requestForLoggingOut];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        // do nothing
    }];
    [task resume];
}

- (void)fetchDocumentListFromModuleIdentifier:(NSString *)identifier
                                       onPage:(NSInteger)page
                            completionHandler:(void (^)(NSArray *documents, NSDictionary *pagination, NSError *error))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForFetchingDocumentListFromModuleIdentifier:identifier
                                                                                                onPage:page];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
          completionHandler(nil, nil, error);
          return ;
        }

        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
          completionHandler(nil, nil, [[self class] errorFromResponse:JSONResponse]);
          return ;
        }

        NSMutableArray *documents = [NSMutableArray array];
        for (NSDictionary *JSONDocument in JSONResponse[@"document_list"]) {
            [documents addObject:@{
                                   @"identifier": [JSONDocument[@"document_srl"] description],
                                   @"title": JSONDocument[@"title"],
                                   @"commentCount": JSONDocument[@"comment_count"],
                                   @"hits": JSONDocument[@"readed_count"],
                                   @"username": JSONDocument[@"user_name"],
                                   @"nickname": JSONDocument[@"nick_name"],
                                   @"writtenDate": [[self class] dateFromXpressEngineDateString:JSONDocument[@"regdate"]],
                                   @"likeCount": JSONDocument[@"voted_count"],
                                   @"dislikeCount": JSONDocument[@"blamed_count"],
                                   }];
        }
        
        NSDictionary *JSONPagination = JSONResponse[@"page_navigation"];
        NSDictionary *pagination = @{@"firstPage": JSONPagination[@"first_page"],
                                     @"currentPage": JSONPagination[@"cur_page"],
                                     @"lastPage": JSONPagination[@"last_page"],
                                     @"totalDocumentCount": JSONPagination[@"total_count"]};
        
        completionHandler(documents, pagination, NULL);
    }];
    [task resume];
}

- (void)fetchDocumentFromDocumentIdentifier:(NSString *)identifier
                          completionHandler:(void (^)(NSDictionary *document, NSError *error))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForFetchingDocumentFromDocumentIdentifier:identifier];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(nil, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(nil, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        NSDictionary *JSONDocument = JSONResponse[@"oDocument"];
        NSDictionary *document = @{
                                   @"identifier": [JSONDocument[@"document_srl"] description],
                                   @"title": JSONDocument[@"title"],
                                   @"contents": JSONDocument[@"content"],
                                   @"commentCount": JSONDocument[@"comment_count"],
                                   @"hits": JSONDocument[@"readed_count"],
                                   @"username": JSONDocument[@"user_name"],
                                   @"nickname": JSONDocument[@"nick_name"],
                                   @"writtenDate": [[self class] dateFromXpressEngineDateString:JSONDocument[@"regdate"]],
                                   @"likeCount": JSONDocument[@"voted_count"],
                                   @"dislikeCount": JSONDocument[@"blamed_count"],
                                   };
        completionHandler(document, NULL);
    }];
    [task resume];
}

- (void)fetchCommentsFromDocumentIdentifier:(NSString *)identifier
                          completionHandler:(void (^)(NSArray *comments, NSError *error))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForFetchingCommentsFromDocumentIdentifier:identifier];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(nil, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(nil, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        NSMutableArray *comments = [NSMutableArray array];
        for (NSDictionary *JSONComment in JSONResponse[@"comment_list"]) {
            [comments addObject:@{
                                   @"identifier": [JSONComment[@"comment_srl"] description],
                                   @"contents": JSONComment[@"content"],
                                   @"username": JSONComment[@"user_name"],
                                   @"nickname": JSONComment[@"nick_name"],
                                   @"writtenDate": [[self class] dateFromXpressEngineDateString:JSONComment[@"regdate"]],
                                   @"likeCount": JSONComment[@"voted_count"],
                                   @"dislikeCount": JSONComment[@"blamed_count"],
                                   }];
        }
        
        completionHandler(comments, NULL);
    }];
    [task resume];
}

- (void)fetchPostFromDocumentIdentifier:(NSString *)identifier
                      completionHandler:(void (^)(NSDictionary *post, NSError *error))completionHandler
{
    [self fetchDocumentFromDocumentIdentifier:identifier
                            completionHandler:^(NSDictionary *document, NSError *error)
     {
         if (error) {
             completionHandler(nil, error);
             return ;
         }
         
        [self fetchCommentsFromDocumentIdentifier:identifier
                                completionHandler:^(NSArray *comments, NSError *error)
        {
            if (error) {
                completionHandler(nil, error);
                return ;
            }
            
            completionHandler(@{@"document": document,
                                @"comments": comments}, NULL);
        }];
    }];
}

- (void)writeDocumentOnModuleIdentifier:(NSString *)identifier
                              withTitle:(NSString *)title
                               contents:(NSString *)contents
                      completionHandler:(void (^)(NSString *, NSError *))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForWritingDocumentOnModuleIdentifier:identifier
                                                                                      withTitle:title
                                                                                       contents:contents];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(nil, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(nil, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        completionHandler([JSONResponse[@"document_srl"] description], NULL);
    }];
    [task resume];
}

- (void)modifyDocumentHavingIdentifier:(NSString *)identifier
                             withTitle:(NSString *)title
                              contents:(NSString *)contents
                     completionHandler:(void (^)(NSString *identifier, NSError *error))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForModifyingDocumentHavingIdentifier:identifier
                                                                                      withTitle:title
                                                                                       contents:contents];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(NO, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(NO, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        completionHandler([JSONResponse[@"document_srl"] description], NULL);
    }];
    [task resume];
}

- (void)writeCommentOnDocumentIdentifier:(NSString *)documentIdentifier
                            withContents:(NSString *)contents
                       completionHandler:(void (^)(NSString *documentIdentifier, NSString *commentIdentifier, NSError *error))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForWritingCommentOnDocumentIdentifier:documentIdentifier
                                                                                    withContents:contents];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(nil, nil, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(nil, nil, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        completionHandler([JSONResponse[@"document_srl"] description], [JSONResponse[@"comment_srl"] description], NULL);
    }];
    [task resume];
}

- (void)modifyCommentOnDocumentIdentifier:(NSString *)documentIdentifier
                         havingIdentifier:(NSString *)commentIdentifier
                             withContents:(NSString *)contents
                        completionHandler:(void (^)(NSString *documentIdentifier, NSString *commentIdentifier, NSError *error))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForModifyingCommentOnDocumentIdentifier:documentIdentifier
                                                                                  havingIdentifier:commentIdentifier
                                                                                      withContents:contents];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(nil, nil, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(nil, nil, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        completionHandler([JSONResponse[@"document_srl"] description], [JSONResponse[@"comment_srl"] description], NULL);
    }];
    [task resume];
}

- (void)likeDocumentHavingIdentifier:(NSString *)identifier
                   completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForLikingDocumentHavingIdentifier:identifier];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(NO, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(NO, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        completionHandler(YES, NULL);
    }];
    [task resume];
}

- (void)dislikeDocumentHavingIdentifier:(NSString *)identifier
                      completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForDislikingDocumentHavingIdentifier:identifier];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(NO, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(NO, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        completionHandler(YES, NULL);
    }];
    [task resume];
}

- (void)likeCommentHavingIdentifier:(NSString *)identifier
                  completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForLikingCommentHavingIdentifier:identifier];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(NO, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(NO, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        completionHandler(YES, NULL);
    }];
    [task resume];
}

- (void)dislikeCommentHavingIdentifier:(NSString *)identifier
                     completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    NSURLRequest *request = [HJHXpressEngineRequest requestForDislikingCommentHavingIdentifier:identifier];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            completionHandler(NO, error);
            return ;
        }
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([[self class] responseHasError:JSONResponse]) {
            completionHandler(NO, [[self class] errorFromResponse:JSONResponse]);
            return ;
        }
        
        completionHandler(YES, NULL);
    }];
    [task resume];
}

+ (NSDate *)dateFromXpressEngineDateString:(NSString *)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyymmddHHmmss";
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
    
    return [formatter dateFromString:dateString];
}


+ (BOOL)responseHasError:(NSDictionary *)response
{
    return ([response[@"error"] integerValue] != 0);
}


+ (NSError *)errorFromResponse:(NSDictionary *)response
{
    return [NSError errorWithDomain:@"me.jongwhan.HJHXpressEngine"
                               code:100
                           userInfo:@{@"message": response[@"message"]}];
}

@end
