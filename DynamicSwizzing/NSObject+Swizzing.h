//
//  NSObject+Swizzing.h
//  DynamicSwizzing
//
//  Created by lvjianxiong on 2021/2/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Swizzing)


/// 添加观察方法
/// @param observer 目标类
/// @param oriMethod 原始方法
/// @param targetMethod 目标替换方法
- (void)ltAddObserver:(NSObject *)observer forOriMethod:(NSString *)oriMethod byNewMethod:(NSString *)targetMethod;


/// 移除观察方法
/// @param observer 目标类
/// @param oriMethod 原始方法
- (void)ltRemoveObserver:(NSObject *)observer forOriMethod:(NSString *)oriMethod;

@end

NS_ASSUME_NONNULL_END
