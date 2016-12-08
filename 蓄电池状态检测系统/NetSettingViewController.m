//
//  NetSettingViewController.m
//  蓄电池系统
//
//  Created by 张天 on 16/8/18.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "NetSettingViewController.h"
#import "Define.h"
@interface NetSettingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *ipTextField2;
@property (weak, nonatomic) IBOutlet UITextField *portTextField2;

@end

@implementation NetSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.title = @"网络设置";
    _ipTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:IPKey];
    _portTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:PortKey];
    
    _ipTextField2.text = [[NSUserDefaults standardUserDefaults] valueForKey:IPKey2];
    _portTextField2.text = [[NSUserDefaults standardUserDefaults] valueForKey:PortKey2];
    

     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(ensure:)];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] resignFirstResponder];
}
- (void)ensure:()sender {
    [[NSUserDefaults standardUserDefaults] setValue:_ipTextField.text forKey:IPKey];
    [[NSUserDefaults standardUserDefaults] setValue:_portTextField.text forKey:PortKey];
    
    [[NSUserDefaults standardUserDefaults] setValue:_ipTextField2.text forKey:IPKey2];
    [[NSUserDefaults standardUserDefaults] setValue:_portTextField2.text forKey:PortKey2];
    
    //取出对象
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    BatteryGroup *batteryGroup = appDelegate.batteryGroup;
    [batteryGroup.socket disconnect];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
