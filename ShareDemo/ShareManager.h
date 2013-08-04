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
    WXSceneTypeTimeline  = 1
}WXSceneTypeE;


typedef enum {
    ShareTypeWeiChat    = 0,
    ShareTypeQQ         = 1,
    ShareTypeSMS        = 2,
    ShareTypeEmail      = 3
}ShareTypeE;

/**
 *	@brief	发布内容状态
 */
typedef enum{
	ShareContentStateBegan = 0,        /**< 开始 */
	ShareContentStateSuccess = 1,     /**< 成功 */
	ShareContentStateFail = 2,        /**< 失败 */
    ShareContentStateUnInstalled = 3, /**< 未安装 */
	ShareContentStateCancel = 4       /**< 取消 */
}ShareContentState;

#define kWeiChatAppId       @"wxd930ea5d5a258f4f"
#define kQQConnectAppKey    @"222222"


@class ShareManager;

typedef void (^ShareQQBlock)(ShareManager *manager, ShareContentState resultCode);
typedef void (^ShareWeiChatBlock)(ShareManager *manager, ShareContentState resultCode);
typedef void (^ShareSMSBlock)(ShareManager *manager);
typedef void (^ShareMailBlock)(ShareManager *manager);


@interface ShareManager : NSObject<WXApiDelegate,TencentSessionDelegate>{
	ShareQQBlock       _completionQQBlock;
	ShareQQBlock       _failureQQBlock;
    
    ShareWeiChatBlock  _completionWXBlock;
	ShareWeiChatBlock  _failureWXBlock;
    
    ShareSMSBlock      _completionSMSBlock;
    ShareSMSBlock      _failureSMSBlock;
    
    ShareMailBlock     _completionMailBlock;
    ShareMailBlock     _failureMailBlock;

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
              completionBlock:(ShareQQBlock)aCompletionQQBlock
                  failedBlock:(ShareQQBlock)aFailedQQBlock;
- (void) sendTextContentToQQ:(NSString *)text
             completionBlock:(ShareQQBlock)aCompletionQQBlock
                 failedBlock:(ShareQQBlock)aFailedQQBlock;

//WeiChat API
- (void) sendImageContentToWX:(UIImage *)image
                        scene:(WXSceneTypeE)sceneSession
              completionBlock:(ShareWeiChatBlock)aCompletionWXBlock
                  failedBlock:(ShareWeiChatBlock)aFailedWXBlock;
- (void) sendTextContentToWX:(NSString *)text
                       scene:(WXSceneTypeE)sceneSession
             completionBlock:(ShareWeiChatBlock)aCompletionWXBlock
                 failedBlock:(ShareWeiChatBlock)aFailedWXBlock;

@end
