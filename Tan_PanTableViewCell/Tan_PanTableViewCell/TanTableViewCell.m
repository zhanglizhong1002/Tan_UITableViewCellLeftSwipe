//
//  TanTableViewCell.m
//  Tan_SwipeTableViewCell
//
//  Created by PX_Mac on 16/3/25.
//  Copyright © 2016年 PX_Mac. All rights reserved.
//

#import "TanTableViewCell.h"
#import "MemberModel.h"

#define CELLHEIGHT 60.f //设置单元格高度

@interface TanTableViewCell()

@property (nonatomic, weak) UIView *containerView; //容器view
@property (nonatomic, weak) UIView *underlineView; //下划线
@property (nonatomic, weak) UILabel *showLbl; //展示信息

@property (nonatomic, weak) UIButton *telBtn; //底层打电话按钮
@property (nonatomic, weak) UIButton *deleteBtn; //底层删除按钮

@property (nonatomic, weak) UIPanGestureRecognizer *panGes; //拖拽手势

@end

@implementation TanTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *reuseIdentity = @"tanCell";
    
    TanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentity];
    
    if (cell == nil){
        cell = [[TanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentity];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initSubControls]; //初始化子控件
    }
    return self;
}

//初始化子控件
- (void)initSubControls{
    //1、添加底层层的电话和删除按钮
    UIButton *telBtn = [[UIButton alloc] init];
    [self.contentView addSubview:telBtn];
    self.telBtn = telBtn;
    [self.telBtn setTitle:@"联系会员" forState:UIControlStateNormal];
    [self.telBtn setBackgroundColor:[UIColor orangeColor]];
    //绑定打电话事件
    [self.telBtn addTarget:self action:@selector(toTelephone:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteBtn = [[UIButton alloc] init];
    [self.contentView addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
    [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteBtn setBackgroundColor:[UIColor redColor]];
    //绑定删除会员事件
    [self.deleteBtn addTarget:self action:@selector(deleteMember:) forControlEvents:UIControlEventTouchUpInside];
    
    //2、添加外层显示控件
    UIView *containerView = [[UIView alloc] init];
    [self.contentView addSubview:containerView];
    self.containerView = containerView;
    self.containerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *showLbl = [[UILabel alloc] init];
    [self.containerView addSubview:showLbl];  //将showLbl添加到容器containerView上
    self.showLbl = showLbl;
    [self.showLbl setTextColor:[UIColor purpleColor]];
    
    UIView *underlineView = [[UIView alloc] init];
    [self.containerView addSubview:underlineView]; //将下划线添加到容器containerView上
    self.underlineView = underlineView;
    self.underlineView.backgroundColor = [UIColor orangeColor];
    
    //3、给容器containerView绑定拖动手势
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.containerView addGestureRecognizer:panGes];
    self.panGes = panGes;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone; //设置单元格选中样式
    [self.contentView bringSubviewToFront:self.containerView]; //设置containerView显示在最上层
}

//子控件布局
- (void)layoutSubviews{
    CGFloat telWidth = SCREENWIDTH * 0.3; //设置电话按钮宽度
    CGFloat deleteWidth = SCREENWIDTH * 0.2; //设置删除按钮宽度
    
    self.telBtn.frame = CGRectMake(SCREENWIDTH * 0.5, 0, telWidth, CELLHEIGHT);
    self.deleteBtn.frame = CGRectMake(SCREENWIDTH * 0.8, 0, deleteWidth, CELLHEIGHT);
    
    self.containerView.frame = self.contentView.bounds;
    self.showLbl.frame = CGRectMake(0, 0, SCREENWIDTH, CELLHEIGHT - 1);
    self.underlineView.frame = CGRectMake(0, CELLHEIGHT - 1, SCREENWIDTH, 1);
}

//设置要显示的数据
- (void)setData: (MemberModel *)model{
    _model = model;
    
    self.showLbl.text = [NSString stringWithFormat:@"   %@  -->  %@", model.displayname, model.email];
}

#pragma  mark - 操作事件
//拨打电话： 需要在真机测试效果
- (void)toTelephone: (UIButton *)sender{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel://%@", self.model.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

//删除会员
- (void)deleteMember: (UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(deleteMember:)]){
        [self.delegate deleteMember:self];
    }
}

//拖动手势（拖拽手势和UITableView的下拉刷新手势有冲突，造成下拉刷新不能使用）
- (void)pan: (UIPanGestureRecognizer *)sender
{
    //动画结束时修正位置
    if (sender.state == UIGestureRecognizerStateEnded){
        
        //关闭其他cell的左拖拽
        if ([self.delegate respondsToSelector:@selector(closeOtherCellLeftPan:)])
            [self.delegate closeOtherCellLeftPan: self];
        
        if (sender.view.frame.origin.x < -SCREENWIDTH * 0.25){
            sender.view.transform = CGAffineTransformMakeTranslation(-SCREENWIDTH * 0.5, 0);
            [sender setTranslation:CGPointZero inView:sender.view];  //必须归0
        }
        else{
            [self closeLeftPan];
        }
    }
    
    CGPoint point = [sender translationInView:self.contentView];
    
    CGFloat tx = sender.view.transform.tx;
    
    if (tx < - SCREENWIDTH * 0.5 || tx > 0) return;
    
    //形变
    sender.view.transform = CGAffineTransformTranslate(sender.view.transform, point.x, 0);
    [sender setTranslation:CGPointZero inView:sender.view];  //必须归0
}

//关闭左拖拽
- (void)closeLeftPan{
    self.panGes.view.transform = CGAffineTransformMakeTranslation(0, 0);
    [self.panGes setTranslation:CGPointZero inView:self.panGes.view];  //必须归0
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
