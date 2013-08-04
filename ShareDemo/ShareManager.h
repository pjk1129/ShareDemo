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
#import <MessageUI/MessageUI.h>

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
	ShareContentStateBegan = 0,              /**< 开始 */
	ShareContentStateSuccess = 1,            /**< 成功 */
	ShareContentStateFail = 2,               /**< 失败 */
    ShareContentStateUnInstalled = 3,        /**< 未安装 */
	ShareContentStateCancel = 4,             /**< 取消 */
    ShareContentStateNotSupport = 5          /**< 设备不支持 */
}ShareContentState;

typedef enum  {
    MailShareStateCancelled      = 0,
    MailShareStateSaved          = 1,
    MailShareStateSent           = 2,
    MailShareStateFailed         = 3,
    MailShareStateNotSupport     = 4,       //该系统不支持程序内邮件功能
    MailShareStateUnEmail        = 5,       //未配置邮箱账号
}MailShareState;

#define kWeiChatAppId       @"wxd930ea5d5a258f4f"
#define kQQConnectAppKey    @"222222"


@class ShareManager;

typedef void (^ShareQQBlock)(ShareManager *manager, ShareContentState resultCode);
typedef void (^ShareWeiChatBlock)(ShareManager *manager, ShareContentState resultCode);
typedef void (^ShareSMSBlock)(ShareManager *manager, ShareContentState resultCode);
typedef void (^ShareMailBlock)(ShareManager *manager, MailShareState state);


@interface ShareManager : NSObject<WXApiDelegate,TencentSessionDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>{
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

//Share via QQ
- (void) sendImageContentToQQ:(UIImage *)image
                        title:(NSString*)title
                  description:(NSString*)description
              completionBlock:(ShareQQBlock)aCompletionQQBlock
                  failedBlock:(ShareQQBlock)aFailedQQBlock;
- (void) sendTextContentToQQ:(NSString *)text
             completionBlock:(ShareQQBlock)aCompletionQQBlock
                 failedBlock:(ShareQQBlock)aFailedQQBlock;

//Share via WeiChat
- (void) sendImageContentToWX:(UIImage *)image
                        scene:(WXSceneTypeE)sceneSession
              completionBlock:(ShareWeiChatBlock)aCompletionWXBlock
                  failedBlock:(ShareWeiChatBlock)aFailedWXBlock;
- (void) sendTextContentToWX:(NSString *)text
                       scene:(WXSceneTypeE)sceneSession
             completionBlock:(ShareWeiChatBlock)aCompletionWXBlock
                 failedBlock:(ShareWeiChatBlock)aFailedWXBlock;

//Share via email
- (void)shareViaEmailWithTitle:(NSString *)title
                       content:(NSString *)content
                         image:(UIImage *)image
                  toRecipients:(NSArray *)toRecipients
                  ccRecipients:(NSArray *)ccRecipients
                 bccRecipients:(NSArray *)bccRecipients
               completionBlock:(ShareMailBlock)aCompletionMailBlock
                   failedBlock:(ShareMailBlock)aFailedMailBlock;

//Share via SMS
- (void)shareViaSMSWithContent:(NSString *)content
                    recipients:(NSArray *)recipients
               completionBlock:(ShareSMSBlock)aCompletionSMSBlock
                   failedBlock:(ShareSMSBlock)aFailedSMSBlock;


@end
