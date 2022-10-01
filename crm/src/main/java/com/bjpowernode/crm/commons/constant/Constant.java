package com.bjpowernode.crm.commons.constant;

public class Constant {
    //操作提示码
    public static final String Operation_Success = "1";//操作成功
    public static final String Operation_Fail = "0";//操作失败

    //是否编辑区别码
    public static final String Edit_Yes = "1";//已编辑
    public static final String Edit_No = "0";//未编辑

    //ActivityDetail是否编辑码
    public static final String Activity_Remark_Yes_Edit = "1";//已编辑
    public static final String Activity_Remark_Not_Edit = "0";//未编辑

    //用户登录的信息(session)
    public static final String Login_User_Msg="loginUserMsg";

    //保存账号密码的cookie名字
    public static final String Remember_Login_ActCookie = "loginAct";//记住账号的cookie名
    public static final String Remember_Login_PwdCookie = "loginPwd";//记住密码的cookie名

    //保存账号密码时间
    public static final Integer Remember_ActAndPwdTime = 10*24*60*60;//10天

    //workbench的activity默认显示pageSize
    public static final String Default_PageSize = "10";//10条

    //文件下载保存的路径
    public static final String Download_FilePath = "D:\\javaEE\\crm-project\\crm\\src\\main" +
                                                  "\\java\\com\\bjpowernode\\crm\\downloadResources";//下载到downloadFile包下
}
