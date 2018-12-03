//
//  AipAsrService.m
//  ESOP
//
//  Created by 张锐平 on 2018/11/23.
//  Copyright © 2018年 asiainfo. All rights reserved.
//

#import "AipAsrService.h"
#import <AipBase/AipTokenManager.h>
#import <AipBase/AipOpenUDID.h>

static NSString *const URL_VOICE = @"https://vop.baidu.com/server_api";
static NSError * ERR_EMPTY_VOICE;
static NSString* ErrorDomain = @"com.baidu.aipocr";

@implementation AipAsrService{
    AipTokenManager *_aipTokenManager;
    NSURLSession *_apiSession;
}


- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [configuration setHTTPAdditionalHeaders:@{
                                                  @"Accept": @"application/json"
                                                  }];
        // 如果网络状况不好，可以在这里修改超时时间
        configuration.timeoutIntervalForRequest = 10;
        configuration.timeoutIntervalForResource = 60;
        _apiSession = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (void)authWithAK:(NSString *)ak andSK:(NSString *)sk {
    _aipTokenManager = [[AipTokenManager alloc] initWithAK:ak andSK:sk];
}


- (void)    asr:(NSString *)voice
    withOptions:(NSDictionary *)options
 successHandler:(void (^)(id result))successHandler
    failHandler:(void (^)(NSError *err))failHandler{
    if(!voice){
        if (failHandler) failHandler(ERR_EMPTY_VOICE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];
    NSData *voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:voice]];
    [dict setValue:@(1) forKey:@"channel"];
    [dict setValue:@(16000) forKey:@"rate"];
    [dict setValue:@([[NSString stringWithFormat:@"%u",voiceData.length] intValue]) forKey:@"len"];
    dict[@"speech"] = [voiceData base64EncodedStringWithOptions:0];
    dict[@"format"] = @"pcm";
    [self _apiRequestWithURL:URL_VOICE
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}


/**
 * 通用的请求API服务的方法
 */
- (void)_apiRequestWithURL:(NSString *)URL
                   options:(NSMutableDictionary *)options
            successHandler:(void (^)(id result))successHandler
               failHandler:(void (^)(NSError *err))failHandler {
    
    [_aipTokenManager getTokenWithSuccessHandler:^(NSString *token) {
        NSLog(@"requesting: %@", URL);
        // 成功获得token
        NSURL *url = [NSURL URLWithString:URL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        options[@"token"] = token;
        options[@"cuid"] = [OpenUDID value];
        NSString *formData = [AipAsrService NSDictionaryTOJsonString:options];
        [request setHTTPBody:[formData dataUsingEncoding:NSUTF8StringEncoding]];
        
        [[_apiSession dataTaskWithRequest:request
                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                            if (error) {
                                if (failHandler) failHandler([AipAsrService aipApiServerConnectErrorWithMessage:[error localizedDescription]]);
                                return;
                            }
                            NSError *serializedErr = nil;
                            id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializedErr];
                            if (serializedErr) {
                                if (failHandler) failHandler([AipAsrService aipApiServerIllegalResponseError]);
                                return;
                            }
                            if (obj[@"error_code"]){
                                if ([obj[@"error_code"] intValue] == 110) {
                                    // 理论上不会走到这里，特殊情况，清空缓存。下次重试即可。
                                    [self clearCache];
                                }
                                if (failHandler) failHandler([AipAsrService aipErrorWithCode:[obj[@"error_code"] integerValue] andMessage:obj[@"error_msg"]]);
                                return;
                            }
                            if (successHandler) successHandler(obj);
                        }] resume];
    }
                                     failHandler:^(NSError *error) {
                                         // 获得token失败
                                         if (failHandler) failHandler(error);
                                     }];
    
}



- (void)clearCache {
    [_aipTokenManager clearCache];
}

+(NSString*)NSDictionaryTOJsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (NSError *)aipApiServerConnectErrorWithMessage:(NSString *)message {
    NSString *err = [NSString stringWithFormat:@"%@(%@)", @"Fail to connect to api server", message];
    return [AipAsrService aipErrorWithCode:283504 andMessage:err];
}

+ (NSError *)aipApiServerIllegalResponseError {
    return [AipAsrService aipErrorWithCode:283505 andMessage:@"Internal error. Api server responsing illegal data"];
}


+ (NSError *)aipErrorWithCode:(NSInteger)code andMessage:(NSString *)message {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
    return [NSError errorWithDomain:ErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)shardService {
    static AipAsrService *sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    ERR_EMPTY_VOICE = [AipAsrService aipErrorWithCode:283507 andMessage:@"语音文件为空"];
    return sharedService;
}

@end

