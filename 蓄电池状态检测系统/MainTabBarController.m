//
//  MainTabBarController.m
//  蓄电池系统
//
//  Created by 张天 on 2016/11/26.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "MainTabBarController.h"
#import "SlideNavigationController.h"
#import "Define.h"
#import "KxMenu.h"


@interface MainTabBarController ()<SlideNavigationControllerDelegate>
{
    NSArray *sitesArray;
}
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSites) name:@"GetSites" object:nil];
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
 
    sitesArray = [MemDataManager shareManager].groupArray;
//    NSString *content = [(BatteryGroup *)sitesArray[0] name];
    NSString *content = nil;
    CGSize size =[content sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    imageView.image = [UIImage imageNamed:@"箭头.png"];
    imageView.tag = 2;
    float tWidth,lWidth=size.width;
    if (imageView.width+size.width >self.view.width-80) {
        tWidth = self.view.width-80;
        lWidth = tWidth - imageView.width;
    }
    else
    {
        tWidth = imageView.width+size.width;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lWidth, 40)];
    label.tag = 1;
    label.textColor = [UIColor whiteColor];
    label.text = content;
    imageView.center = CGPointMake(tWidth-imageView.width/2, label.center.y);
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tWidth, 40)];
    [titleView addSubview:label];
    [titleView addSubview:imageView];
    titleView.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [titleView addGestureRecognizer:tap];
    titleView.backgroundColor = [UIColor clearColor];
    
    [self setTile:[(BatteryGroup *)sitesArray[0] name]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dimiss) name:@"Dismiss" object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Dismiss" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetSites" object:nil];
}
- (void)updateSites
{
    sitesArray = [MemDataManager shareManager].groupArray;
     [self setTile:[(BatteryGroup *)sitesArray[[MemDataManager shareManager].currentIndex] name]];
}
- (void)dimiss
{
    //旋转箭头
    UIImageView *imageView = [self.navigationItem.titleView viewWithTag:2];
    imageView.transform = CGAffineTransformMakeRotation(0);
}
- (void)setTile:(NSString *)title
{
    CGSize size =[title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    UILabel *label = [self.navigationItem.titleView viewWithTag:1];
    UIImageView *imageView = [self.navigationItem.titleView viewWithTag:2];
    float tWidth,lWidth=size.width;
    if (imageView.width+size.width >self.view.width-80) {
        tWidth = self.view.width-80;
        lWidth = tWidth - imageView.width;
    }
    else
    {
        tWidth = imageView.width+size.width;
    }
    label.text = title;
    self.navigationItem.titleView.width = tWidth;
    label.width = lWidth;
    imageView.center = CGPointMake(tWidth-imageView.width/2, label.center.y);
//    NSLog(@"%@",NSStringFromCGRect(self.navigationItem.titleView.frame));
}
- (void)tap
{
//    static BOOL isShow = YES;
//    if (isShow == NO) {
//        return;
//    }
    
    //旋转箭头
    UIImageView *imageView = [self.navigationItem.titleView viewWithTag:2];
    imageView.transform = CGAffineTransformMakeRotation( M_PI);
    //下拉框
    NSMutableArray *menuArray = [NSMutableArray array];
    sitesArray = [MemDataManager shareManager].groupArray;
    for (BatteryGroup *group in sitesArray) {
        KxMenuItem *item = [KxMenuItem menuItem:group.name image:nil target:self action:@selector(pushMenuItem:)];
        [menuArray addObject:item];
    }

    [KxMenu showMenuInView:[UIApplication sharedApplication].keyWindow
                  fromRect:CGRectMake(self.view.width/2-60/2, -20, 60, 80)
                 menuItems:menuArray];

}
- (void)pushMenuItem:(KxMenuItem *)sender
{
    [KxMenu dismissMenu];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name == %@",sender.title];
    NSArray *result =  [sitesArray filteredArrayUsingPredicate:filter];
    if (result == nil)
        return;
    BatteryGroup *group = result[0];
    [self setTile:group.name];
    NSUInteger index = [sitesArray indexOfObject:result[0]];
    //选择同一个
    if (index == [MemDataManager shareManager].currentIndex) {
        return;
    }
    [MemDataManager shareManager].currentIndex = index;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeBattery" object:nil];
}


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}


@end
