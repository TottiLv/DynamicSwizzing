//
//  ViewController.m
//  DynamicSwizzing
//
//  Created by lvjianxiong on 2021/2/5.
//

#import "ViewController.h"
#import "Target.h"
#import "NSObject+Swizzing.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Target *targetA = [[Target alloc] init];
    
    
    Target *targetB = [[Target alloc] init];
    
    
    [targetB ltAddObserver:self forOriMethod:@"oriMethod" byNewMethod:@"targetMethod"];
    
    [targetA oriMethod];
    
    [targetB oriMethod];
    
    [targetB ltRemoveObserver:self forOriMethod:@"oriMethod"];
    
    [targetB oriMethod];
}


@end
