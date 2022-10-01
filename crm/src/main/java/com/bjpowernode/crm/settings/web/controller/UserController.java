package com.bjpowernode.crm.settings.web.controller;

import com.bjpowernode.crm.commons.constant.Constant;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtil;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;

@Controller
public class UserController {

    @Autowired
    private UserService userService;

    @RequestMapping("/settings/qx/user/toLogin.do")
    public String toLogin(){
        return "settings/qx/user/login";
    }

    @RequestMapping("/settings/qx/user/login.do")
    @ResponseBody
    public Object login(String loginAct, String loginPwd, String isRember , HttpServletRequest request, HttpSession session, HttpServletResponse response){
        HashMap<String, Object> hashMap = new HashMap<>();
        hashMap.put("loginAct",loginAct);
        hashMap.put("loginPwd",loginPwd);
        User user = userService.queryUserByLoginActAndPwd(hashMap);
        ReturnObject returnObject = new ReturnObject();
        //设置失败编码
        returnObject.setCode(Constant.Operation_Fail);
        if(user==null){
            //账户或者密码错误
            returnObject.setMessage("账号或密码错误");
        }else{
            //当前格式化时间
            String nowTime = DateUtil.FormatDateTime(new Date());
            //用户ip地址
            String ipAdress=request.getRemoteAddr();
            if(nowTime.compareTo(user.getExpireTime())>0){
                //账号过期
                returnObject.setMessage("账号过期");
            }else if("0".equals(user.getLockState())){
                //账号锁定
                returnObject.setMessage("账号锁定");
            }else if(!user.getAllowIps().contains(ipAdress)){
                //ip地址异常
                returnObject.setMessage("ip地址异常");
            }else{
                //登录成功
                returnObject.setCode(Constant.Operation_Success);
                //保存用户
                session.setAttribute(Constant.Login_User_Msg,user);
                //是否记住密码
                if("true".equals(isRember)){
                    //记住密码
                    Cookie[] cookies = request.getCookies();
                    //不建议使用hashmap,效率太低
                    HashMap<String, Cookie> cookieHashMap = new HashMap<>();
                    for(Cookie cookie:cookies){
                        if(Constant.Remember_Login_ActCookie.equals(cookie.getName())){
                            cookieHashMap.put(Constant.Remember_Login_ActCookie,cookie);
                        }
                        if(Constant.Remember_Login_PwdCookie.equals(cookie.getName())){
                            cookieHashMap.put(Constant.Remember_Login_PwdCookie,cookie);
                        }
                    }
                    if(cookieHashMap.size()!=2){
                        //保存密码 未存储过
                        Cookie loginUserActCookie = new Cookie(Constant.Remember_Login_ActCookie,loginAct);
                        Cookie loginUserPwdCookie = new Cookie(Constant.Remember_Login_PwdCookie,loginPwd);
                        loginUserActCookie.setMaxAge(Constant.Remember_ActAndPwdTime);
                        loginUserPwdCookie.setMaxAge(Constant.Remember_ActAndPwdTime);
                        response.addCookie(loginUserActCookie);
                        response.addCookie(loginUserPwdCookie);
                    }
                }else{
                    //不记住密码
                    Cookie loginUserActCookie = new Cookie(Constant.Remember_Login_ActCookie,"1");
                    Cookie loginUserPwdCookie = new Cookie(Constant.Remember_Login_PwdCookie, "1");
                    loginUserActCookie.setMaxAge(0);
                    loginUserPwdCookie.setMaxAge(0);
                    response.addCookie(loginUserActCookie);
                    response.addCookie(loginUserPwdCookie);
                }
            }
        }
        return returnObject;
    }

    @RequestMapping("/settings/qx/user/logout.do")
    public String logout(HttpSession session,HttpServletResponse response){
        //删除session
        session.invalidate();
        //删除cookie
        Cookie loginAct = new Cookie(Constant.Remember_Login_ActCookie, "1");
        Cookie loginPwd = new Cookie(Constant.Remember_Login_PwdCookie, "1");
        loginAct.setMaxAge(0);
        loginPwd.setMaxAge(0);
        response.addCookie(loginAct);
        response.addCookie(loginPwd);
        return "redirect:/";
    }
}
