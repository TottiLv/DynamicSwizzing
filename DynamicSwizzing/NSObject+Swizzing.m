//
//  NSObject+Swizzing.m
//  DynamicSwizzing
//
//  Created by lvjianxiong on 2021/2/5.
//

#import "NSObject+Swizzing.h"
#import <objc/runtime.h>

static NSString *methodPrefix = @"NSObjectObserver_";
static NSString *const kLTObserverAssociateKey = @"kLTObserver_AssociateKey";

@interface LTObserverInfo : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *oriMethod;
@property (nonatomic, copy) NSString *targetMethod;

//构造方法
- (instancetype)initWithObserver:(NSObject *)observer forOriMethod:(NSString *)oriMethod targetMethod:(NSString *)targetMethod;


@end

@implementation LTObserverInfo

- (instancetype)initWithObserver:(NSObject *)observer forOriMethod:(NSString *)oriMethod targetMethod:(NSString *)targetMethod{
    if (self = [super init]) {
        self.observer = observer;
        self.oriMethod = oriMethod;
        self.targetMethod = targetMethod;
    }
    return self;
}

@end

@implementation NSObject (Swizzing)

- (void)ltAddObserver:(NSObject *)observer forOriMethod:(NSString *)oriMethod byNewMethod:(NSString *)targetMethod{
    //1:先判断oriMethod方法是否在类中存在，不存在直接返回
    //2:动态生成子类
    //3:在子类中实现方法替换（需要注意，targetMethod是否存在）
    if (![self judgeMethodIsExist:oriMethod]) {
        return;
    }
    
    LTObserverInfo *info = [[LTObserverInfo alloc] initWithObserver:observer forOriMethod:oriMethod targetMethod:targetMethod];
    NSMutableArray *mArray = objc_getAssociatedObject(self, (__bridge  const void * _Nonnull)(kLTObserverAssociateKey));
    if (!mArray) {
        mArray = [[NSMutableArray alloc] initWithCapacity:1];
        objc_setAssociatedObject(self, (__bridge  const void * _Nonnull)(kLTObserverAssociateKey), mArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [mArray addObject:info];
    
    Class newClass = [self dynamicCreateClass];
    
    //isa指向
    object_setClass(self, newClass);
    
    
    SEL oriSel = NSSelectorFromString(oriMethod);
    SEL newSel = NSSelectorFromString(targetMethod);
    
    //进行方法交换
    [NSObject lt_hookOriInstanceMethod:newClass oriSel:oriSel newInstanceMethod:newSel];
}

- (void)ltRemoveObserver:(NSObject *)observer forOriMethod:(NSString *)oriMethod{
    NSMutableArray *mArray = objc_getAssociatedObject(self, (__bridge  const void * _Nonnull)(kLTObserverAssociateKey));
    if (mArray.count <= 0) {
        return;
    }
    for (LTObserverInfo *info in mArray) {
        if ([info.oriMethod isEqualToString:oriMethod]) {
            [mArray removeObject:info];
            objc_setAssociatedObject(self, (__bridge  const void * _Nonnull)(kLTObserverAssociateKey), mArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    if ( mArray.count <= 0) {
        //isa指回去
        Class superClass = [self class];
        object_setClass(self, superClass);
    }
}


- (BOOL)judgeMethodIsExist:(NSString *)method{
    Class curClass = object_getClass(self);
    SEL oriSel = NSSelectorFromString(method);
    Method oriMethod = class_getInstanceMethod(curClass, oriSel);
    if (!oriMethod) {
        return false;
    }
    return true;
}

- (Class)dynamicCreateClass{
    NSString *oriClassName = NSStringFromClass([self class]);
    NSString *newClassName = [NSString stringWithFormat:@"%@%@",methodPrefix, oriClassName];
    Class newClass = NSClassFromString(newClassName);
    //申请类
    newClass = objc_allocateClassPair([self class], newClassName.UTF8String, 0);
    //注册
    objc_registerClassPair(newClass);
    //添加方法
    SEL classSel = @selector(class);
    Method classMethod = class_getInstanceMethod([self class], classSel);
    const char *classType = method_getTypeEncoding(classMethod);
    class_addMethod(newClass, classSel, (IMP)lt_class, classType);
    
    //添加dealloc 方法
    SEL deallocSel = NSSelectorFromString(@"dealloc");
    Method deallocMethod = class_getInstanceMethod([self class], deallocSel);
    const char *deallocType = method_getTypeEncoding(deallocMethod);
    class_addMethod(newClass, deallocSel, (IMP)lt_dealloc, deallocType);
    
    //添加方法
    return newClass;
}

Class lt_class(id self, SEL _cmd){
    return class_getSuperclass(object_getClass(self));
}

void lt_dealloc(id self, SEL _cmd){
    Class superClass = [self class];
    object_setClass(self, superClass);
}


+ (BOOL)lt_hookOriInstanceMethod:(Class)cls oriSel:(SEL)oriSel newInstanceMethod:(SEL)newSel{

    Method oriMethod = class_getInstanceMethod(cls, oriSel);
    Method newMethod = class_getInstanceMethod(cls, newSel);
    //如果不存在原始方法，那么添加一个空的方法，什么也不做，防止死循环
    if (!oriMethod) {
        class_addMethod(cls, oriSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
        method_setImplementation(newMethod, imp_implementationWithBlock(^(id self, SEL _cmd){}));
    }
    
    //交换方法
    //步骤：
    //1、先添加方法，如果添加不成功，那么说明原始类中存在方法，直接交换即可
    //2、如果添加成功，说明原始类中不存在方法，那么直接replace
    BOOL addMethod = class_addMethod(cls, oriSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    
    if (!addMethod) {
        method_exchangeImplementations(oriMethod, newMethod);
    }else{
        class_replaceMethod(cls, newSel, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    }
    /*
     //打印方法
    unsigned int methodCount = 0;
    Method * methods = class_copyMethodList([cls class], &methodCount);
    for(int i=0;i<methodCount  ;i++)
    {
        Method method = methods[i];
        SEL methodsel = method_getName(method);
        const char * name = sel_getName(methodsel);
        NSLog(@"----------------方法为：%s",name);
    }
    */
    return true;
}

@end
