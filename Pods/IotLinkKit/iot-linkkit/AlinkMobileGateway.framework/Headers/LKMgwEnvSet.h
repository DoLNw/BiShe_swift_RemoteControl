//
//  LKMgwEnvSet.h
//  AlinkAppExpress
//
//  Created by ZhuYongli on 2017/11/7.
//  Copyright © 2017年 ZhuYongli. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, LKMgwEnv) {
    LKMgwEnvDaily = 1, ///< 日常
    LKMgwEnvPrerelease = 2, ///< 预发
    LKMgwEnvRelease = 3, ///< 线上
};


/**
 运行环境设置，开发者不需要设置
 */
@interface LKMgwEnvSet : NSObject

/**
 设置环境

 @param env 参见 `LKMgwEnv`
 */
+(void) setRunEnv:(LKMgwEnv)env;


/**
 获取运行环境

 @return 当前运行环境，参见 `LKMgwEnv`
 */
+(LKMgwEnv)getRunEnv;
@end
