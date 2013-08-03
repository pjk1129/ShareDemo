//
//  ShareManager.h
//  ShareDemo
//
//  Created by JK.PENG on 13-8-2.
//  Copyright (c) 2013年 NJUT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import "TencentOpenAPI/QQApiInterface.h"

typedef enum {
    WXSceneTypeSession   = 0,
    WXSceneTypeTimeline  = 1,
}WXSceneTypeE;

#define kWeiChatAppId       @"wxd930ea5d5a258f4f"
#define kQQConnectAppKey    @"222222"


@class ShareManager;

typedef void (^ShareManagerBlock)(ShareManager *manager);


@interface ShareManager : NSObject<WXApiDelegate,TencentSessionDelegate>{
	ShareManagerBlock _completionReqBlock;
	ShareManagerBlock _failureReqBlock;
}

@property (nonatomic, retain) TencentOAuth *tencentOAuth;


+ (ShareManager *)sharedManager;

- (void)connectWeChatWithAppId:(NSString *)appId;
- (void)connectQQWithQConnectAppKey:(NSString *)qconnectAppKey;

-(BOOL) handleOpenURL:(NSURL *) url;

//QQ connect API
- (void) sendImageContentToQQ:(UIImage *)image
                        title:(NSString*)title
                  description:(NSString*)description
              completionBlock:(ShareManagerBlock)aCompletionReqBlock
                  failedBlock:(ShareManagerBlock)aFailedReqBlock;
- (void) sendTextContentToQQ:(NSString *)text
             completionBlock:(ShareManagerBlock)aCompletionReqBlock
                 failedBlock:(ShareManagerBlock)aFailedReqBlock;

//WeiChat API
- (void) sendImageContentToWX:(UIImage *)image
                        scene:(WXSceneTypeE)sceneSession
              completionBlock:(ShareManagerBlock)aCompletionReqBlock
                  failedBlock:(ShareManagerBlock)aFailedReqBlock;
- (void) sendTextContentToWX:(NSString *)text
                       scene:(WXSceneTypeE)sceneSession
             completionBlock:(ShareManagerBlock)aCompletionReqBlock
                 failedBlock:(ShareManagerBlock)aFailedReqBlock;

@end
