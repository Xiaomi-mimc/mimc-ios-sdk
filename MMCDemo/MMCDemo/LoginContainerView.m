//
//  AppDelegate.m
//  MMCDemo
//
//  Created by zhangdan on 2018/1/4.
//  Copyright © 2018年 zhangdan. All rights reserved.
//

#import "LoginContainerView.h"
#import "Message.h"
#import "MessageFrame.h"
#import "MessageCell.h"
#import "voiceCallViewController.h"
#import "Constant.h"

#define MAINVIEW_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define MAINVIEW_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface LoginContainerView ()<showRecvMsgDelegate, returnUserStatusDelegate> {
    UITextField *_userName;
    UITextField *_receiver;
    UITextField *_msgSend;
    NSString *_packetId;
    UISwitch *_switchButton;
}

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *messages;
@property(nonatomic, strong) XMUserManager *userManager;

- (void)showRecvMsg:(MIMCMessage *)packet user:(MCUser *)user;
- (void)returnUserStatus:(MCUser *)user status:(int)status;
@end

@implementation LoginContainerView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userManager = [XMUserManager sharedInstance];
    self.userManager.showRecvMsgDelegate = self;
    self.userManager.returnUserStatusDelegate = self;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.view.frame = CGRectMake(0, 0, MAINVIEW_WIDTH, MAINVIEW_HEIGHT);
    
    [self showButonAndLabel];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, MAINVIEW_WIDTH, 550) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setAllowsSelection:NO];
    self.tableView.allowsSelectionDuringEditing = YES;
    [self.view addSubview:self.tableView];
}

/** 延迟加载plist文件数据 */
- (NSMutableArray *)messages {
    if (nil == _messages) {
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"messages.plist" ofType:nil]];
        
        NSMutableArray *mdictArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            Message *message = [Message messageWithDictionary:dict];
            
            // 判断是否发送时间与上一条信息的发送时间相同，若是则不用显示了
            MessageFrame *lastMessageFrame = [mdictArray lastObject];
            if (lastMessageFrame && [message.time isEqualToString:lastMessageFrame.message.time]) {
                message.hideTime = YES;
            }
            
            MessageFrame *messageFrame = [[MessageFrame alloc] init];
            messageFrame.message = message;
            [mdictArray addObject:messageFrame];
        }
        
        _messages = mdictArray;
    }
    
    return _messages;
}

#pragma mark - dataSource方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.messages.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [MessageCell cellWithTableView:self.tableView];
    cell.messageFrame = self.messages[indexPath.row];
    
    return cell;
}


#pragma mark - tableView代理方法
/** 动态设置每个cell的高度 */
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageFrame *messageFrame = self.messages[indexPath.row];
    return messageFrame.cellHeight;
}

#pragma mark - scrollView 代理方法
/** 点击拖曳聊天区的时候，缩回键盘 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 1.缩回键盘
    [self.view endEditing:YES];
}

#pragma mark - TextField 代理方法
/** 回车响应事件 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *toUserName = [_receiver.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 我方发出信息
    [self sendMessageWithContent:toUserName text:textField.text andType:MessageSent];
    [self.tableView reloadData];
    
    // 滚动到最新的消息
    if (self.messages.count > 0) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    return YES;
}

- (float)randomFloatBetween:(float)num1 andLargerFloat:(float)num2 {
    int startVal = num1*10000;
    int endVal = num2*10000;
    
    int randomValue = startVal +(arc4random()%(endVal - startVal));
    float a = randomValue;
    
    return(a /10000.0);
}

- (NSString *)randomString:(int)length{
    if(length <1){
        return nil;
    }
    NSMutableString * str =[NSMutableString stringWithFormat:@"0123456789abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSMutableString *randomStr =[NSMutableString string];
    
    for (int i =0; i<length; i++) {
        int randomInt = [self randomFloatBetween:0 andLargerFloat:1000]/1;
        int location=  randomInt %72;
        NSString*bStr = [str substringWithRange:NSMakeRange((NSUInteger)location,1)];
        [randomStr appendString:bStr];
    }
    return randomStr;
}

//获取当前时间戳
- (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

- (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

int msgId= 0;
NSString *randomStr;

// 发送聊天消息
- (void)sendMessageWithContent:(NSString *)toUserName text:(NSString *)text andType:(MessageType)type {
    XMUserManager *userManager = [XMUserManager sharedInstance];
    if (![userManager.getUser isOnline]) {
        NSLog(@"sendMessageWithContent, %@ is offline", userManager.getUser.getAppAccount);
        return;
    }
    
    NSMutableString *resultStr =[NSMutableString string];
    if (msgId==0) {
        randomStr =[self randomString:5];
        resultStr= [NSMutableString stringWithFormat:@"%@-%d",randomStr,msgId];
        msgId++;
    }else{
        resultStr=[NSMutableString stringWithFormat:@"%@-%d",randomStr,msgId];
        msgId++;
        
    }
    
    NSString *bizType = TEXT;
    NSData *data = [_msgSend.text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *payload = [data base64EncodedStringWithOptions:0];
    
    NSDictionary *jsonDict = @{@"version":@0,
                               @"msgId":resultStr,
                               @"timestamp":[self currentTimeStr],
                               @"payload":payload};
    
    NSString *jsonData=[self convertToJsonData:jsonDict];
    
    _packetId = [[userManager getUser] sendMessage:toUserName payload:[jsonData dataUsingEncoding:NSUTF8StringEncoding] bizType:bizType];
    if (_packetId == nil || _packetId.length == 0) {
        NSLog(@"sendMessageWithContent, sendMessage_fail, _packetId is nil");
        return;
    }
    
    // 获取当前时间
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MMM-dd hh:mm:ss";
    NSString *dateStr = [formatter stringFromDate:date];
    
    // 我方发出信息
    NSDictionary *dict = @{@"userName":_userName.text,
                           @"text":text,
                           @"time":dateStr,
                           @"type":[NSString stringWithFormat:@"%d", type]};
    
    
    
    Message *message = [[Message alloc] init];
    [message setValuesForKeysWithDictionary:dict];
    
    MessageFrame *messageFrame = [[MessageFrame alloc] init];
    messageFrame.message = message;
    
    [self.messages addObject:messageFrame];
    
    NSString *myjson=[self convertToJsonData:dict];
    NSLog(@"%@",myjson);
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)showButonAndLabel {
    UILabel *userNameLaber = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 70, 30)];
    userNameLaber.text = @"用户名：";
    userNameLaber.textAlignment = NSTextAlignmentRight;
    
    _userName = [[UITextField alloc] initWithFrame:CGRectMake(90, 50, 150, 30)];
    [_userName setBorderStyle:UITextBorderStyleRoundedRect];
    _userName.placeholder = @"请输入用户名";
    _userName.keyboardType = UIKeyboardTypeDefault;
    _userName.clearButtonMode = UITextFieldViewModeAlways;
    [_userName setDelegate:self];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(250, 50, 50, 30);
    loginButton.backgroundColor = [UIColor orangeColor];
    [loginButton setTitle:@"登陆" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchDown];
    
    UILabel *receiverLaber = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 70, 30)];
    receiverLaber.text = @"接收人：";
    receiverLaber.textAlignment = NSTextAlignmentRight;
    
    _receiver = [[UITextField alloc] initWithFrame:CGRectMake(90, 100, 150, 30)];
    [_receiver setBorderStyle:UITextBorderStyleRoundedRect];
    _receiver.placeholder = @"请输入接收人";
    _receiver.keyboardType = UIKeyboardTypeDefault;
    _receiver.clearButtonMode = UITextFieldViewModeAlways;
    [_receiver setDelegate:self];
    
    UIButton *voiceCallButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    voiceCallButton.frame = CGRectMake(250, 100, 100, 30);
    voiceCallButton.backgroundColor = [UIColor orangeColor];
    [voiceCallButton setTitle:@"语音通话" forState:UIControlStateNormal];
    [voiceCallButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [voiceCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [voiceCallButton addTarget:self action:@selector(voiceCall) forControlEvents:UIControlEventTouchDown];
    
    UILabel *msgLaber = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 70, 30)];
    msgLaber.text = @"消息体：";
    msgLaber.textAlignment = NSTextAlignmentRight;
    
    _msgSend = [[UITextField alloc] initWithFrame:CGRectMake(90, 150, 150, 30)];
    [_msgSend setBorderStyle:UITextBorderStyleRoundedRect];
    _msgSend.placeholder = @"请输入内容";
    _msgSend.keyboardType = UIKeyboardTypeDefault;
    _msgSend.clearButtonMode = UITextFieldViewModeAlways;
    [_msgSend setDelegate:self];
    
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logoutButton.frame = CGRectMake(320, 50, 50, 30);
    logoutButton.backgroundColor = [UIColor orangeColor];
    [logoutButton setTitle:@"注销" forState:UIControlStateNormal];
    [logoutButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchDown];
    
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 500, 1)];
    horizontalLine.backgroundColor = [UIColor whiteColor];
    
    _switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 20, 20, 10)];
    [_switchButton setOn:NO];
    
    [self.view addSubview:_switchButton];
    [self.view addSubview:msgLaber];
    [self.view addSubview:userNameLaber];
    [self.view addSubview:receiverLaber];
    [self.view addSubview:voiceCallButton];
    [self.view addSubview:_msgSend];
    [self.view addSubview:_userName];
    [self.view addSubview:_receiver];
    [self.view addSubview:logoutButton];
    [self.view addSubview:loginButton];
    [self.view addSubview:horizontalLine];
}

- (BOOL)login {
    XMUserManager *userManager = [XMUserManager sharedInstance];
    NSString *userName = [_userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [userManager setAppAccount:userName];
    [userManager setLoginVC:self];
    return [userManager userLogin];
}

- (void)returnUserStatus:(MCUser *)user status:(int)status {
    if (user != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            (status == Online) ? [_switchButton setOn:YES]:[_switchButton setOn:NO];
        });
    }
    return;
}

- (void)voiceCall {
    voiceCallViewController *voiceCallView = [[voiceCallViewController alloc] init];
    voiceCallView.receiver = [self getReceiver];
    voiceCallView.audioConnState = @"正在等待对方接受邀请...";
    voiceCallView.numButton = 1;
    
    int64_t callId = [self.userManager.getUser dialCall:[self getReceiver] appContent:[@"AUDIO" dataUsingEncoding:NSUTF8StringEncoding]];
    if (callId <= 0) {
        NSLog(@"voiceCall, dialCall fail, callId is -1");
        return;
    }
    NSLog(@"voiceCall, dialCall success, callId=%lld", callId);
    
    voiceCallView.callId = callId;
    [self presentViewController:voiceCallView animated:NO completion:nil];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
- (void)showRecvMsg:(MIMCMessage *)packet user:(MCUser *)user {
    if (packet == nil || user == nil) {
        NSLog(@"showRecvMsg, parameter is nil");
        return;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:packet.getTimestamp / 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MMM-dd hh:mm:ss";
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *recvText = [[NSString alloc] initWithData:packet.getPayload encoding:NSUTF8StringEncoding];
    NSLog(@"payload=%@", recvText);
    
    NSDictionary *jsonDict = [self dictionaryWithJsonString:recvText];
    NSData *payloadByte = [[NSData alloc] initWithBase64EncodedString:jsonDict[@"payload"] options:0];
    NSString *payload = [[NSString alloc] initWithData:payloadByte encoding:NSUTF8StringEncoding];
    
    NSDictionary *dict = @{@"userName":packet.getFromAccount,
                           @"text":payload,
                           @"time":dateStr,
                           @"type":[NSString stringWithFormat:@"%d", MessageRecved]};
    
    Message *msg = [[Message alloc] init];
    //给模型赋值
    [msg setValuesForKeysWithDictionary:dict];
    //这个frame对象是为了计算气泡size的。
    MessageFrame *messageFrame = [[MessageFrame alloc] init];
    messageFrame.message = msg;
    
    
    [self.messages addObject:messageFrame];
    
    //GCD回到主线程去更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
    
    NSLog(@"showRecvMsg, ReceiveMessage, P2P, {%@}-->{%@}, packetId=%@, payload=%@, bizType=%@", packet.getFromAccount, user.getAppAccount, packet.getPacketId, packet.getPayload, packet.getBizType);
}

- (BOOL)logout {
    XMUserManager *userManager = [XMUserManager sharedInstance];
    return [userManager userLogout];
}

- (NSString *)getUserName {
    return [_userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)getMsg {
    return _msgSend.text;
}

- (NSString *)getReceiver {
    return [_receiver.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
