package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constant.Constant;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtil;
import com.bjpowernode.crm.commons.utils.UUIDUtil;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityDetailService;
import com.bjpowernode.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Controller
public class ActivityDetailController {
    @Autowired
    private ActivityDetailService activityDetailService;
    @Autowired
    private ActivityService activityService;

    @RequestMapping("/workbench/activity/detail.do")
    public String activityDetail(@RequestParam("id") String activityId, Model model){
        Activity activity = activityService.queryActivityForDetailById(activityId);
        List<ActivityRemark> activityRemarkList = activityDetailService.queryActivityForDetailByActivityId(activityId);
        model.addAttribute("activity",activity);
        model.addAttribute("activityRemarkList",activityRemarkList);
        return "workbench/activity/detail";
    }

    @RequestMapping("/workbench/activity/saveCreateActivityRemark.do")
    @ResponseBody
    public Object saveActivityRemark(ActivityRemark activityRemark, HttpSession session){
        //前端保存了noteCintent和ActivityId
        User loginUserMsg=(User)session.getAttribute(Constant.Login_User_Msg);
        activityRemark.setId(UUIDUtil.getUUID());
        activityRemark.setCreateTime(DateUtil.FormatDateTime(new Date()));
        activityRemark.setCreateBy(loginUserMsg.getId());
        activityRemark.setEditFlag(Constant.Activity_Remark_Not_Edit);
        ReturnObject returnObject = new ReturnObject();
        try {
            int saveNum = activityDetailService.saveCreateActivityRemark(activityRemark);
            if(saveNum>0){
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setRetData(activityRemark);
            }else{
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("系统忙,请稍后联系管理员...");
            }
        } catch (Exception e) {
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后联系管理员...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/deleteActivityRemarkById.do")
    @ResponseBody
    public Object deleteActivityRemark(String id){
        ReturnObject returnObject=new ReturnObject();
        try {
            int deleteNum = activityDetailService.deleteActivityRemarkById(id);
            if(deleteNum>0){
                //删除成功
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setMessage("删除成功");
            }else{
                //删除失败
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("删除失败,请稍后联系管理员");
            }
        } catch (Exception e) {
            e.printStackTrace();
            //删除失败
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("删除失败,请稍后联系管理员");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/updateActivityRemark.do")
    @ResponseBody
    public Object updateActivityRemark(ActivityRemark activityRemark,HttpSession session){
        //生成响应信息
        User loginUserMes=(User)session.getAttribute(Constant.Login_User_Msg);
        activityRemark.setEditTime(DateUtil.FormatDateTime(new Date()));
        activityRemark.setEditBy(loginUserMes.getId());
        activityRemark.setEditFlag(Constant.Activity_Remark_Yes_Edit);
        ReturnObject returnObject = new ReturnObject();
        try {
            int updateNum = activityDetailService.updateActivityRemark(activityRemark);
            if(updateNum>0){
                //修改成功
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setRetData(activityRemark);
            }else{
                //修改失败
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("修改失败,请稍后联系管理员...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            //修改失败
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("修改失败,请稍后联系管理员...");
        }
        return returnObject;
    }
}
