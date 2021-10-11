//
// Created by ren7995 on 2021-04-17 13:45:45
// Copyright (c) 2021 ren7995. All rights reserved.
//

// Thank you to Lacertosus for their open source tweaks, it really helped me a lot with preferences
// https://github.com/LacertosusRepo/Open-Source-Tweaks

#import "ARIRootListController.h"

// RGB: 81, 8, 126
#define kPrefTintColor [UIColor colorWithRed:0.32 green:0.03 blue:0.49 alpha:1.00]

@implementation ARIRootListController

- (NSArray *)specifiers {
    if(!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }

    return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[ self.class ]] setTintColor:kPrefTintColor];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[ self.class ]] setOnTintColor:kPrefTintColor];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[ self.class ]] setTintColor:kPrefTintColor];

    [super viewWillAppear:animated];
}

- (void)done {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *respring = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)];
    self.navigationItem.rightBarButtonItem = respring;
}

- (void)respring:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注销设备"
                                                                   message:@"你确定要注销设备吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action){
                                                          }];

    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction *action) {
                                                    NSTask *t = [[NSTask alloc] init];
                                                    [t setLaunchPath:@"usr/bin/killall"];
                                                    [t setArguments:[NSArray arrayWithObjects:@"SpringBoard", nil]];
                                                    [t launch];
                                                }];

    [alert addAction:defaultAction];
    [alert addAction:yes];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetPrefs:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重置所有设置"
                                                                   message:@"你确定要重置所有设置并注销设备吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                          }];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction *action) {
                                                    NSUserDefaults *prefs = [[NSUserDefaults standardUserDefaults] init];
                                                    [prefs removePersistentDomainForName:@"me.lau.AtriaPrefs"];

                                                    NSTask *f = [[NSTask alloc] init];
                                                    [f setLaunchPath:@"/usr/bin/killall"];
                                                    [f setArguments:[NSArray arrayWithObjects:@"SpringBoard", nil]];
                                                    [f launch];
                                                }];

    [alert addAction:defaultAction];
    [alert addAction:yes];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetSaveState:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重置保存状态"
                                                                   message:@"你确定要重置保存状态并注销设备吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                          }];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction *action) {
                                                    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"me.lau.AtriaPrefs"];
                                                    [prefs removeObjectForKey:@"saveState"];
                                                    [prefs synchronize];

                                                    NSTask *f = [[NSTask alloc] init];
                                                    [f setLaunchPath:@"/usr/bin/killall"];
                                                    [f setArguments:[NSArray arrayWithObjects:@"SpringBoard", nil]];
                                                    [f launch];
                                                }];

    [alert addAction:defaultAction];
    [alert addAction:yes];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)exportSettingsString {
    NSError *error;

    // Sync defaults
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"me.lau.AtriaPrefs"];
    [defaults synchronize];

    NSURL *url = [NSURL fileURLWithPath:@"/var/mobile/Library/Preferences/me.lau.AtriaPrefs.plist"];
    NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfURL:url error:&error] mutableCopy];
    if(!dict) dict = [NSMutableDictionary new];
    // Let's not give the other person my icon layout
    [dict removeObjectForKey:@"saveState"];
    [dict removeObjectForKey:@"_atriaDidSplashGuide"];

    // Easier to make it json imho
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    if(error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法导出"
                                                                       message:[NSString stringWithFormat:@"错误: %@", error.localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"好的"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action){
                                                              }];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        NSString *encoded = [jsonData base64EncodedStringWithOptions:0];
        [UIPasteboard generalPasteboard].string = encoded;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成功"
                                                                       message:@"导出成功并复制到剪贴板"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"好的"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action){
                                                              }];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)importSettingsString {
    NSString *pasteboardString = [UIPasteboard generalPasteboard].string;
    if(!pasteboardString) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"导入失败"
                                                                       message:@"在剪贴板中找不到相关的字符串。"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"好的"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action){
                                                              }];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:pasteboardString options:0];
    if(!decodeData) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"导入失败"
                                                                       message:@"解码失败。也许剪贴板中的字符串无效？"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"好的"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action){
                                                              }];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    NSError *error;
    NSDictionary *settingsDictionary = [NSJSONSerialization JSONObjectWithData:decodeData options:kNilOptions error:&error];

    if(!settingsDictionary) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"导入失败"
                                                                       message:[NSString stringWithFormat:@"剪贴板中的字符串可能无效？\n\n错误： \n%@", error.localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"好的"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action){
                                                              }];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"me.lau.AtriaPrefs"];
        [defaults removePersistentDomainForName:@"me.lau.AtriaPrefs"];
        defaults = [[NSUserDefaults alloc] initWithSuiteName:@"me.lau.AtriaPrefs"];
        [defaults synchronize];

        // Set _atriaDidWelcomeSplash, since they are in preferences already
        [defaults setObject:@(YES) forKey:@"_atriaDidSplashGuide"];

        for(NSString *key in [settingsDictionary allKeys]) {
            [defaults setObject:settingsDictionary[key] forKey:key];
        }
        [defaults synchronize];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成功"
                                                                       message:[NSString stringWithFormat:@"已成功导入配置。您现在可以注销设备以完全应用。\n\n配置：\n%@", settingsDictionary]
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"注销设备"
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction *action) {
                                                                  NSTask *f = [[NSTask alloc] init];
                                                                  [f setLaunchPath:@"/usr/bin/killall"];
                                                                  [f setArguments:[NSArray arrayWithObjects:@"SpringBoard", nil]];
                                                                  [f launch];
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)openTwitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/ren7995"]];
}

- (void)openCakePhoneTwitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/Quartz88244782"]];
}

- (void)openAlphaStreamTwitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/Kutarin_"]];
}

- (void)source {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/ren7995/Atria"]];
}


@end
