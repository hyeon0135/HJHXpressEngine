//
//  HJHXpressEngine.h
//  Uriuniv
//
//  Created by Jonghwan Hyeon on 2/10/14.
//  Copyright (c) 2014 Uriuniv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJHXpressEngine : NSObject
@property (assign, nonatomic) BOOL isLoggedIn;

+ (instancetype)sharedInstance;

- (void)loginWithIdentifier:(NSString *)identifier
                   password:(NSString *)password
           completionHander:(void (^)(BOOL isLoggedIn, NSError *error))completionHandler;
- (void)logout;

- (void)fetchDocumentListFromModuleIdentifier:(NSString *)identifier
                                       onPage:(NSInteger)page
                            completionHandler:(void (^)(NSArray *documents, NSError *error))completionHandler;

- (void)fetchDocumentFromDocumentIdentifier:(NSString *)identifier
                          completionHandler:(void (^)(NSDictionary *document, NSError *error))completionHandler;

- (void)fetchCommentsFromDocumentIdentifier:(NSString *)identifier
                          completionHandler:(void (^)(NSArray *comments, NSError *error))completionHandler;

- (void)fetchPostFromDocumentIdentifier:(NSString *)identifier
                      completionHandler:(void (^)(NSDictionary *post, NSError *error))completionHandler;

- (void)writeDocumentOnModuleIdentifier:(NSString *)identifier
                              withTitle:(NSString *)title
                               contents:(NSString *)contents
                      completionHandler:(void (^)(NSString *identifier, NSError *error))completionHandler;

- (void)modifyDocumentHavingIdentifier:(NSString *)identifier
                             withTitle:(NSString *)title
                              contents:(NSString *)contents
                     completionHandler:(void (^)(NSString *identifier, NSError *error))completionHandler;

- (void)writeCommentOnDocumentIdentifier:(NSString *)documentIdentifier
                            withContents:(NSString *)contents
               completionHandler:(void (^)(NSString *documentIdentifier, NSString *commentIdentifier, NSError *error))completionHandler;

- (void)modifyCommentOnDocumentIdentifier:(NSString *)documentIdentifier
                         havingIdentifier:(NSString *)commentIdentifier
                         withContents:(NSString *)contents
                    completionHandler:(void (^)(NSString *documentIdentifier, NSString *commentIdentifier, NSError *error))completionHandler;

- (void)likeDocumentHavingIdentifier:(NSString *)identifier
                   completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

- (void)dislikeDocumentHavingIdentifier:(NSString *)identifier
                      completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

- (void)likeCommentHavingIdentifier:(NSString *)identifier
                  completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

- (void)dislikeCommentHavingIdentifier:(NSString *)identifier
                     completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

@end
