//
//  Target.m
//  DynamicSwizzing
//
//  Created by lvjianxiong on 2021/2/5.
//

#import "Target.h"

@implementation Target

- (void)oriMethod{
    NSLog(@"原方法%s",__func__);
}

- (void)targetMethod{
    NSLog(@"新方法%s", __func__);
}

@end
