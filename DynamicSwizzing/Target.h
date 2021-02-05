//
//  Target.h
//  DynamicSwizzing
//
//  Created by lvjianxiong on 2021/2/5.
//

#import <Foundation/Foundation.h>
/*
 需求：
 类Target，分别有两个实例化对象 targetA,targetB
 分别调用：
 [targetA oriMethod];
 [targetB oriMethod];
 实例targetA调用的是原始方法，实例targetB调用的是swizing后的方法swizzingMethod
 */
NS_ASSUME_NONNULL_BEGIN

@interface Target : NSObject

- (void)oriMethod;

- (void)targetMethod;

@end

NS_ASSUME_NONNULL_END
