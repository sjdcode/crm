package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constant.Constant;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtil;
import com.bjpowernode.crm.commons.utils.UUIDUtil;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.DicValueService;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.Clue;
import com.bjpowernode.crm.workbench.domain.ClueActivityRelation;
import com.bjpowernode.crm.workbench.domain.ClueRemark;
import com.bjpowernode.crm.workbench.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

@Controller
public class ClueController {
    @Autowired
    private UserService userService;
    @Autowired
    private ClueService clueService;
    @Autowired
    private DicValueService dicValueService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private ClueActivityRelationService clueActivityRelationService;
    @Autowired
    private ClueRemarkService clueRemarkService;
    @Autowired
    private ConvertService convertService;

    @RequestMapping("/workbench/clue/index.do")
    public String index(Model model){
        //返回页面前查询所有用户
        model.addAttribute("userList",userService.queryAllUsers());
        //返回所有下拉列表的字段
        model.addAttribute("appellationList",dicValueService.queryDicValueByTypeValue("appellation"));
        model.addAttribute("stateList",dicValueService.queryDicValueByTypeValue("clueState"));
        model.addAttribute("sourceList",dicValueService.queryDicValueByTypeValue("source"));
        return "/workbench/clue/index";
    }

    @RequestMapping("/workbench/clue/queryClueByConditionForPage.do")
    @ResponseBody
    public Object queryClueByConditionForPage(String fullname, String company, String mphone , String source,
                                              String owner, String phone, String state,
                                              @RequestParam(value = "pageNo",defaultValue = "1") int pageNo,
                                              @RequestParam(value = "pageSize",defaultValue = Constant.Default_PageSize) int pageSize){
        //封装参数
        HashMap<String, Object> hashMap = new HashMap<>();
        hashMap.put("fullname",fullname);
        hashMap.put("company",company);
        hashMap.put("mphone",mphone);
        hashMap.put("source",source);
        hashMap.put("owner",owner);
        hashMap.put("phone",phone);
        hashMap.put("state",state);
        hashMap.put("beginNo",(pageNo-1)*pageSize);
        hashMap.put("pageSize",pageSize);

        //查询数据集合和总记录数
        List<Clue> clueList = clueService.queryClueByConditionForPage(hashMap);
        int totalRows = clueService.queryCountOfClueByCondition(hashMap);
        //数据返回
        HashMap<String, Object> returnHashMap = new HashMap<>();
        returnHashMap.put("clueList",clueList);
        returnHashMap.put("totalRows",totalRows);
        return returnHashMap;
    }

    @RequestMapping("/workbench/clue/saveCreateClue.do")
    @ResponseBody
    public Object saveCreateClue(Clue clue, HttpSession session){
        ReturnObject returnObject = new ReturnObject();
        //设置后端属性
        User loginUserMes=(User)session.getAttribute(Constant.Login_User_Msg);
        clue.setId(UUIDUtil.getUUID());
        clue.setCreateTime(DateUtil.FormatDateTime(new Date()));
        clue.setCreateBy(loginUserMes.getId());
        try {
            int saveNum = clueService.saveClue(clue);
            if(saveNum>0){
                //保存成功
                returnObject.setCode(Constant.Operation_Success);
            }else{
                //保存失败
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("保存失败,请稍后联系管理员...");
            }
        } catch (Exception e) {
            //保存失败
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("保存失败,请稍后联系管理员...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/clue/queryClueById.do")
    @ResponseBody
    public Object queryClueContentsById(String id){
        return clueService.queryClueById(id);
    }

    @RequestMapping("/workbench/clue/editClue.do")
    @ResponseBody
    public Object editClue(Clue clue,HttpSession session){
        //生成后台参数
        User user=(User)session.getAttribute(Constant.Login_User_Msg);
        clue.setEditTime(DateUtil.FormatDateTime(new Date()));
        clue.setEditBy(user.getId());
        //返回响应信息
        ReturnObject returnObject = new ReturnObject();
        try {
            int editNum = clueService.saveEditClue(clue);
            if(editNum>0){
                //编辑成功
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setMessage("编辑成功");
            }else{
                //编辑失败
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("编辑失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            //编辑失败
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("编辑失败");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/clue/deleteClueByIds")
    @ResponseBody
    public Object deleteClueByIds(@RequestParam(value = "id") String[] ids){
        ReturnObject returnObject = new ReturnObject();
        try {
            int deleteNum = clueService.deleteClueByIds(ids);
            if(deleteNum>0){
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setMessage("解除成功");
            }else{
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("解除失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后联系管理员");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/clue/saveBund.do")
    @ResponseBody
    public Object saveBund(@RequestParam("activityId") String[] activityIds,String clueId){
        //封装数据
        List<ClueActivityRelation> clueActivityRelations = new ArrayList<>();
        //外面定义变量,只创建一次,效率高
        ClueActivityRelation clueActivityRelation=null;
        for(String activityId:activityIds){
            //arrayList存储的是复制内容
            clueActivityRelation=new ClueActivityRelation();
            clueActivityRelation.setClueId(clueId);
            clueActivityRelation.setActivityId(activityId);
            clueActivityRelation.setId(UUIDUtil.getUUID());
            clueActivityRelations.add(clueActivityRelation);
        }

        //返回响应信息
        ReturnObject returnObject = new ReturnObject();
        try {
            int saveNum = clueActivityRelationService.saveCreateClueActivityByList(clueActivityRelations);
            if(saveNum>0){
                List<Activity> activities = activityService.queryActivityForDetailByIds(activityIds);
                //保存成功
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setRetData(activities);
            }
        } catch (Exception e) {
            e.printStackTrace();
            //保存失败
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后联系管理员...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/clue/detail.do")
    public String clueDetail(@RequestParam("id") String clueId, Model model){
        //根据id查询Clue的具体信息和ClueRemark具体信息
        model.addAttribute("clueDetail",clueService.queryClueForDetailById(clueId));
        model.addAttribute("clueRemarkList",clueRemarkService.queryClueRemarkByClueId(clueId));
        model.addAttribute("activityList",activityService.queryActivityForDetailByClueId(clueId));
        return "/workbench/clue/detail";
    }

    @RequestMapping("/workbench/clue/saveClueRemark.do")
    @ResponseBody
    public Object saveClueRemark(ClueRemark clueRemark, HttpSession session){
        //生成后台信息    id和noteContent前端生成
        User user=(User) session.getAttribute(Constant.Login_User_Msg);
        clueRemark.setId(UUIDUtil.getUUID());
        clueRemark.setCreateBy(user.getId());
        clueRemark.setCreateTime(DateUtil.FormatDateTime(new Date()));
        clueRemark.setEditFlag(Constant.Edit_No);

        //生成响应信息
        ReturnObject returnObject = new ReturnObject();
        try {
            int savaClueRemarkNum = clueRemarkService.saveClueRemark(clueRemark);
            if(savaClueRemarkNum>0){
                //保存成功
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setRetData(clueRemark);
            }else{
                //保存失败
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("系统忙.请稍后联系管理员");
            }
        } catch (Exception e) {
            e.printStackTrace();
            //保存失败
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙.请稍后联系管理员");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/clue/deleteClueRemark.do")
    @ResponseBody
    public Object deleteClueRemark(String id){
        //返回响应数据
        ReturnObject returnObject = new ReturnObject();
        try {
            int deleteClueRemarkNum = clueRemarkService.deleteClueRemark(id);
            if(deleteClueRemarkNum>0){
                //保存成功
                returnObject.setCode(Constant.Operation_Success);
            }else{
                //保存失败
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("系统忙,请稍后联系管理员...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            //保存失败
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后联系管理员...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/clue/saveEditClueRemark.do")
    @ResponseBody
    public Object saveEditClueRemark(ClueRemark clueRemark,HttpSession session){
        //生成后端内容
        User user=(User) session.getAttribute(Constant.Login_User_Msg);
        clueRemark.setEditBy(user.getId());
        clueRemark.setEditTime(DateUtil.FormatDateTime(new Date()));
        clueRemark.setEditFlag(Constant.Edit_Yes);
        //返回响应信息
        ReturnObject returnObject = new ReturnObject();
        try {
            int updateClueRemarkNum = clueRemarkService.saveEditClueRemark(clueRemark);
            if(updateClueRemarkNum>0){
                //更新成功
                returnObject.setCode(Constant.Operation_Success);
            }else{
                //保存失败
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("系统忙,请稍后联系管理员...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            //保存失败
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后联系管理员...");
        }
        return returnObject;
    }

    @RequestMapping("workbench/clue/deleteClueActivityRelationByClueIdAndActivityId.do")
    @ResponseBody
    public Object deleteClueActivityRelationByClueIdAndActivityId(String clueId,String activityId){
        System.out.println(clueId+"   "+activityId);
        ReturnObject returnObject = new ReturnObject();
        try {
            int deleteNum = clueActivityRelationService.deleteClueActivityRelationByClueIdAndActivityId(clueId, activityId);
            if(deleteNum>0){
                //删除成功
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setMessage("删除成功");
            }else{
                //删除失败
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("删除失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            //删除失败
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("删除失败");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/clue/queryActivityByDimNameAndClueId.do")
    @ResponseBody
    public Object queryActivityByDimName(String dimName,String clueId){
        return activityService.queryActivityForDetailByClueIdAndDimActivityName(clueId,dimName);
    }

    @RequestMapping("/workbench/clue/convert.do")
    public String convert(String clueId,Model model){
        //保存Clue明细信息,DicValue,关键字为state
        model.addAttribute("clue",clueService.queryClueForDetailById(clueId));
        model.addAttribute("dicValue",dicValueService.queryDicValueByTypeValue("stage"));
        return "/workbench/clue/convert";
    }

    @RequestMapping("/workbench/clue/queryConvertActivityList.do")
    @ResponseBody
    public Object queryConvertActivityList(String dimName,String clueId){
        return activityService.queryActivityForDetailByDimNameAndClueId(dimName,clueId);
    }

    @RequestMapping("/workbench/clue/clueConvert.do")
    @ResponseBody
    public Object clueConvert(String clueId,String isCreateTran,String money,String name,String expectedDate,String stage,
                              String activityId,HttpSession session){
        HashMap<String, Object> map = new HashMap<>();
        map.put("clueId",clueId);
        map.put("isCreateTran",isCreateTran);
        map.put("money",money);
        map.put("name",name);
        map.put("expectedDate",expectedDate);
        map.put("stage",stage);
        map.put("activityId",activityId);
        map.put(Constant.Login_User_Msg,session.getAttribute(Constant.Login_User_Msg));

        System.out.println(map.get("activityId"));

        ReturnObject returnObject = new ReturnObject();
        try {
            convertService.clueConvert(map);
            returnObject.setCode(Constant.Operation_Success);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后再试...");
        }
        return returnObject;
    }

}
