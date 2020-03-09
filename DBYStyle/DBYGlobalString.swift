//
//  DBYGlobalString.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/12/19.
//  Copyright © 2018 钟凡. All rights reserved.
//

import Foundation

extension String {
    static let Retry = "请稍后重试"
    static let NoInviteCode = "请输入邀请码"
    static let NoNickname = "请输入昵称"
    static let Loadding = "正在登录..."
    static let NotSuport1v1Error = "该版本不支持1v1教室"
    static let AuthInfoError = "获取authinfo失败"
    static let InviteCodeError = "邀请码无效"
    static let UrlError = "url无效"
    
    static let LM_ClassOver = "课程已结束"
    static let LM_Handsup = "你已提交语音申请"
    static let LM_NoAnnouncement = "暂无公告"
    static let LM_CanSpeak = "可以发言了"
    static let LM_SpeakInterupt = "发言被中断"
    static let LM_TeacherOnline = "讲师上线啦"
    static let LM_TeacherOffline = "讲师离开了教室"
    static let NicknameError = "昵称不能包含空格"
    static let CourseTypeError = "课程类型错误"
    static let NetWorkError = "网络连接异常"
    static let ServerError = "服务器异常"
    static let LocalError = "其他错误"
    static let AuthInfoParseError = "解析authinfo失败\n请换个网络或者稍后重试"
    static let RoleError = "移动端只支持学生进教室"
    static let TypeError = "只支持新版大班进教室"
}
