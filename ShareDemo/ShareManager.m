//
//  ShareManager.m
//  ShareDemo
//
//  Created by JK.PENG on 13-8-2.
//  Copyright (c) 2013年 NJUT. All rights reserved.
//

#import "ShareManager.h"
#import "AppDelegate.h"

static ShareManager   *shareManager;

@interface ShareManager ()


- (void)setCompletionWXBlock:(ShareWeiChatBlock)aCompletionWXBlock;
- (void)setFailedWXBlock:(ShareWeiChatBlock)aFailedWXBlock;
- (void)setCompletionQQBlock:(ShareQQBlock)aCompletionQQBlock;
- (void)setFailedQQBlock:(ShareQQBlock)aFailedQQBlock;

- (void)setCompletionSMSBlock:(ShareSMSBlock)aCompletionSMSBlock;
- (void)setFailedSMSBlock:(ShareSMSBlock)aFailedSMSBlock;

- (void)setCompletionMailBlock:(ShareMailBlock)aCompletionMailBlock;
- (void)setFailedMailBlock:(ShareMailBlock)aFailedMailBlock;

@end

@implementation ShareManager
@synthesize tencentOAuth = _tencentOAuth;


- (void)dealloc{
    _completionWXBlock = nil;
    _failureWXBlock = nil;
    _completionQQBlock = nil;
    _failureQQBlock = nil;
    _completionSMSBlock = nil;
    _failureSMSBlock = nil;
    _completionMailBlock = nil;
    _failureMailBlock = nil;
    [_tencentOAuth release];
    [super dealloc];
}

+ (ShareManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[ShareManager alloc] init];
    });
    return shareManager;
}

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)connectWeChatWithAppId:(NSString *)appId
{
    [WXApi registerApp:appId];

}

- (void)connectQQWithQConnectAppKey:(NSString *)qconnectAppKey
{
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:qconnectAppKey andDelegate:self];
}


-(BOOL) handleOpenURL:(NSURL *) url
{
    NSLog(@"handleOpenURL: %@",url.absoluteString);
    NSRange r = [url.absoluteString rangeOfString:kWeiChatAppId];
    if (r.location != NSNotFound) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return [TencentOAuth HandleOpenURL:url];

}

/**
 获取弹出模态视图的控制器
 @param  检索路径的根
 @return 弹出模态视图的控制器
 */
- (UIViewController *)presentedVC:(UIViewController *)vc{
    if (nil == [vc presentedViewController]) {
        return vc;
    }
    
    return [self presentedVC:[vc presentedViewController]];
}

#pragma mark - QQ connect API
- (void) sendImageContentToQQ:(UIImage *)image
                        title:(NSString*)title
                  description:(NSString*)description
              completionBlock:(ShareQQBlock)aCompletionQQBlock
                  failedBlock:(ShareQQBlock)aFailedQQBlock
{
    [self setCompletionQQBlock:aCompletionQQBlock];
    [self setFailedQQBlock:aFailedQQBlock];
    
    NSData* data = UIImageJPEGRepresentation(image,0.6);    
    QQApiImageObject* img = [QQApiImageObject objectWithData:data previewImageData:data title:title description:description];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleQQSendResult:sent];
}

- (void) sendTextContentToQQ:(NSString *)text
             completionBlock:(ShareQQBlock)aCompletionQQBlock
                 failedBlock:(ShareQQBlock)aFailedQQBlock
{
    [self setCompletionQQBlock:aCompletionQQBlock];
    [self setFailedQQBlock:aFailedQQBlock];
    
    QQApiTextObject* txtObj = [QQApiTextObject objectWithText:text];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleQQSendResult:sent];
    
}

- (void)handleQQSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPISENDSUCESS:{
            if (_completionQQBlock) {
                _completionQQBlock(self,ShareContentStateSuccess);
            }
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            if (_failureQQBlock) {
                _failureQQBlock(self,ShareContentStateUnInstalled);
            }
            break;
        }
        case EQQAPIAPPNOTREGISTED:
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        case EQQAPIQQNOTSUPPORTAPI:
        case EQQAPISENDFAILD:
        {
            if (_failureQQBlock) {
                _failureQQBlock(self,ShareContentStateFail);
            }
            
            break;
        }
        default:
        {
            break;
        }
    }
    
    [_completionQQBlock release];
    _completionQQBlock = nil;
    [_failureQQBlock release];
    _failureQQBlock = nil;
    
}

#pragma mark - QQ TencentSessionDelegate
- (void)tencentDidLogin
{
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
}

- (void)tencentDidNotNetWork
{
    
}

#pragma mark - WeiChat API
/*
 * @param image 缩略图
 * @note 大小不能超过32K
 */
- (UIImage *)getWXThumbImage:(UIImage *)image
{
    CGFloat  size  = (image.size.width*image.size.height)/1024;
    CGFloat  scaleSize = (size<32)?1.0:(32/size);
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void) sendImageContentToWX:(UIImage *)image
                        scene:(WXSceneTypeE)sceneSession
              completionBlock:(ShareWeiChatBlock)aCompletionWXBlock
                  failedBlock:(ShareWeiChatBlock)aFailedWXBlock;
{
    [self setFailedWXBlock:aFailedWXBlock];
    
    if (![WXApi isWXAppInstalled]) {
        if(_failureWXBlock){
            _failureWXBlock(self,ShareContentStateUnInstalled);
        }
        [_failureWXBlock release];
        _failureWXBlock = nil;
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[self getWXThumbImage:image]];
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImageJPEGRepresentation(image,0.6);
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = NO;
    req.message = message;
    
    //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
    if (sceneSession == WXSceneTypeTimeline) {
        req.scene = WXSceneTimeline;
    }
    [self setCompletionWXBlock:aCompletionWXBlock];
    
    [WXApi sendReq:req];
}

- (void) sendTextContentToWX:(NSString *)text
                       scene:(WXSceneTypeE)sceneSession
             completionBlock:(ShareWeiChatBlock)aCompletionWXBlock
                 failedBlock:(ShareWeiChatBlock)aFailedWXBlock
{
    [self setFailedWXBlock:aFailedWXBlock];
    
    if (![WXApi isWXAppInstalled]) {
        if(_failureWXBlock){
            _failureWXBlock(self,ShareContentStateUnInstalled);
        }
        [_failureWXBlock release];
        _failureWXBlock = nil;
        return;
    }
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = YES;
    req.text = text;
    
    //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
    if (sceneSession == WXSceneTypeTimeline) {
        req.scene = WXSceneTimeline;
    }
    [self setCompletionWXBlock:aCompletionWXBlock];
    
    [WXApi sendReq:req];
}

#pragma mark - WXApiDelegate
-(void) onReq:(BaseReq*)req
{

}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {        
        if (resp.errCode == WXSuccess) {
            if(_completionWXBlock){
                _completionWXBlock(self,ShareContentStateSuccess);
            }
        }else{
            if(_failureWXBlock){
                _failureWXBlock(self,ShareContentStateFail);
            }
        }
        
        [_completionWXBlock release];
        _completionWXBlock = nil;
        [_failureWXBlock release];
        _failureWXBlock = nil;

    }
}

#pragma mark - Mail Share
- (void)shareViaEmailWithTitle:(NSString *)title
                       content:(NSString *)content
                         image:(UIImage *)image
               completionBlock:(ShareMailBlock)aCompletionMailBlock
                   failedBlock:(ShareMailBlock)aFailedMailBlock
{
    
}

#pragma mark - SMS Share
- (void)shareViaSMSWithContent:(NSString *)content
                    recipients:(NSArray *)recipients
               completionBlock:(ShareSMSBlock)aCompletionSMSBlock
                   failedBlock:(ShareSMSBlock)aFailedSMSBlock
{
    [self setCompletionSMSBlock:aCompletionSMSBlock];
    [self setFailedSMSBlock:aFailedSMSBlock];
    
    MFMessageComposeViewController* controller = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        controller.body =  content;
        //parse through receipients        
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        AppDelegate  *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [[self presentedVC:d.window.rootViewController] presentModalViewController:controller animated:YES];
    }

}

#pragma mark - MFMessageComposeViewControllerDelegate
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:YES];
    
    if (result == MessageComposeResultCancelled){
        
    }else if (result == MessageComposeResultSent){
        if(_completionSMSBlock){
            _completionSMSBlock(self);
        }
    }else{
        if(_failureSMSBlock){
            _failureSMSBlock(self);
        }
    }
    
    [_completionSMSBlock release];
    _completionSMSBlock = nil;
    [_failureSMSBlock release];
    _failureSMSBlock = nil;
}

#pragma mark - Set ReqBlock
- (void)setCompletionWXBlock:(ShareWeiChatBlock)aCompletionWXBlock{
    [_completionWXBlock release];
    _completionWXBlock = [aCompletionWXBlock copy];
}

- (void)setFailedWXBlock:(ShareWeiChatBlock)aFailedWXBlock{
    [_failureWXBlock release];
    _failureWXBlock = [aFailedWXBlock copy];
}

- (void)setCompletionQQBlock:(ShareQQBlock)aCompletionQQBlock{
    [_completionQQBlock release];
    _completionQQBlock = [aCompletionQQBlock copy];
}

- (void)setFailedQQBlock:(ShareQQBlock)aFailedQQBlock{
    [_failureQQBlock release];
    _failureQQBlock = [aFailedQQBlock copy];
}

- (void)setCompletionSMSBlock:(ShareSMSBlock)aCompletionSMSBlock{
    [_completionSMSBlock release];
    _completionSMSBlock = [aCompletionSMSBlock copy];
}

- (void)setFailedSMSBlock:(ShareSMSBlock)aFailedSMSBlock{
    [_failureSMSBlock release];
    _failureSMSBlock = [aFailedSMSBlock copy];
}


- (void)setCompletionMailBlock:(ShareMailBlock)aCompletionMailBlock{
    [_completionMailBlock release];
    _completionMailBlock = [aCompletionMailBlock copy];
}

- (void)setFailedMailBlock:(ShareMailBlock)aFailedMailBlock{
    [_failureMailBlock release];
    _failureMailBlock = [aFailedMailBlock copy];
}


@end
