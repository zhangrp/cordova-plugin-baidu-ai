//
//  AipAsrService.h
//  ESOP
//
//  Created by 张锐平 on 2018/11/23.
//  Copyright © 2018年 asiainfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface AipAsrService : NSObject


/**
 * 使用Api Key, Secret Key授权
 */
- (void) authWithAK: (NSString *)ak andSK: (NSString *)sk;


/**
 * 语音识别
 * @param voice 语音文件
 * @param options 参数，详见开发者文档
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void)   asr:(NSString *)voice
   withOptions:(NSDictionary *)options
successHandler:(void (^)(id result))successHandler
   failHandler:(void (^)(NSError *err))failHandler;


/**
 * 清空验证缓存
 * 出现验证过期等特殊情况调用
 */
- (void) clearCache;

+ (NSError *)aipErrorWithCode:(NSInteger)code andMessage:(NSString *)message;

+ (instancetype)shardService;

@end
