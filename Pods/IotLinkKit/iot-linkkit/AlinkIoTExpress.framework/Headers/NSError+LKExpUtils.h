/*
 * Copyright (c) 2014-2016 Alibaba Group. All rights reserved.
 * License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
//
//  NSError+AlinkUtils.h
//  AlinkNecsChannel
//
//  Created by difeng.zyl on 2017/10/31.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const LKExpErrorDomain;

/**
 Alink错误码
 */
typedef NS_ENUM(NSInteger, LKExpErrorCode) {
    LKExpErrorSuccess = 0,                     ///< 业务成功
    
    LKExpErrorUnknownError = 4201,             ///< 客户端内部错误
    LKExpErrorInvokeNetError = 4101,           ///< 网络错误
    LKExpErrorInvokeServerError = 4102,        ///< 网关错误或业务网关错误
    LKExpErrorServerBusinessError = 4103,      ///< 业务错误
    LKExpErrorLoginTokenIllegalError = 4001,   ///< 登录token失效 或 session过期
};

/**
 * LKNecsExpress业务错误
 * 两级错误：
 * 1）第一级错误：domain总是LKExpErrorDomain，code对应LKExpErrorCode，localizedDescription对应用户感知错误msg
 * 2）第二级错误：通过NSUnderlyingErrorKey把原始错误透出，用于调试和具体业务错误码判断
 */
@interface NSError (LKExpUtils)

@end

NS_ASSUME_NONNULL_END
