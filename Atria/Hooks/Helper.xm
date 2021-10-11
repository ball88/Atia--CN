//
// Created by ren7995 on 2021-04-25 15:48:29
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Shared.h"
#import "../src/Manager/ARITweak.h"
#import "../src/Manager/ARIEditManager.h"
#import "../src/UI/ARISplashViewController.h"
#import "../src/UI/ARIWelcomeDynamicLabel.h"

%hook SBIconController 

- (void)viewWillAppear:(BOOL)animated {
    ARITweak *manager = [ARITweak sharedInstance];
    [manager notifyDidLoad];
    %orig;
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];

    ARITweak *manager = [ARITweak sharedInstance];
    if(![manager boolValueForKey:@"_atriaDidSplashGuide"]) {
        NSArray *entries = @[
            @{
                @"在图标菜单（长按软件图标）访问Atria功能，或三击主屏幕空白区域呼出Atria窗口（主屏幕、dock栏、欢迎文字）" : [UIImage systemImageNamed:@"square"],
            },
            @{
                @"点击窗口顶部的大标签可以返回上一页设置选项" : [UIImage systemImageNamed:manager.firmware14 ? @"dial.min" : @"slider.horizontal.below.rectangle"],
            },
            @{
                @"点击此图标，同时选择设置以切换当前页面的每页布局" : [UIImage systemImageNamed:@"doc"],
            },
            @{
                @"要编辑数值，请滑动滑块或轻触下面的标签并键入数值以进行精确控制" : [UIImage systemImageNamed:@"slider.horizontal.3"],
            },
            @{
                @"某些选项仅在“设置”应用程序中可用" : [UIImage systemImageNamed:manager.firmware14 ? @"gearshape.fill" : @"gear"],
            },
        ];

        ARISplashViewController *splash = [[ARISplashViewController alloc] initWithEntries:entries subtitle:@"新手入门"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[objc_getClass("SBIconController") sharedInstance] presentViewController:splash animated:YES completion:^{
                [manager setValue:@(YES) forKey:@"_atriaDidSplashGuide"];
            }];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];
}

%end

%hook SBMainSwitcherWindow

- (void)setHidden:(BOOL)arg {
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];
}

%end

%hook SBTodayViewController

- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    // These next two hooked methods fix label bugging on iPad with today view
    if(![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) return;
    [UIView animateWithDuration:0.3 animations:^{
        [ARIWelcomeDynamicLabel shared].alpha = 0;
    } completion:nil];
}

- (void)viewDidDisappear:(BOOL)arg1 {
    %orig;
    if(![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) return;
    [UIView animateWithDuration:0.3 animations:^{
        [ARIWelcomeDynamicLabel shared].alpha = 1;
    } completion:nil];
}

%end

%ctor {
	if([ARITweak sharedInstance].enabled) {
		NSLog(@"Atria loading hooks from %s", __FILE__);
		%init();
	}
}
