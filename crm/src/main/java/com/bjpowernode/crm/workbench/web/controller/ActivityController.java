package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constant.Constant;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.excelResolver.ExcelFileResolver;
import com.bjpowernode.crm.commons.utils.DateUtil;
import com.bjpowernode.crm.commons.utils.UUIDUtil;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.CellType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.io.*;
import java.lang.reflect.Field;
import java.util.*;

@Controller
public class ActivityController {

    @Autowired
    private UserService userService;
    @Autowired
    private ActivityService activityService;

    @RequestMapping("/workbench/activity/index.do")
    public String index(Model model){
        List<User> users = userService.queryAllUsers();
        model.addAttribute("userList",users);
        return "workbench/activity/index";
    }

    @RequestMapping("/workbench/activity/saveCreateActivity.do")
    @ResponseBody
    public Object saveCreateActivity(Activity activity, HttpSession session){
        User user=(User)session.getAttribute(Constant.Login_User_Msg);
        //????????????????????????????????????
        activity.setId(UUIDUtil.getUUID());
        activity.setCreateTime(DateUtil.FormatDateTime(new Date()));
        activity.setCreateBy(user.getId());
        //??????Activity
        ReturnObject returnObject = new ReturnObject();
        int insertNum = 0;
        try {
            insertNum = activityService.saveCreateActivity(activity);
        } catch (Exception e) {
            e.printStackTrace();
        }
        if(insertNum>0){
            returnObject.setCode(Constant.Operation_Success);
        }else{
            //????????????
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("?????????,?????????...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/queryActivityByConditionForPage.do")
    @ResponseBody
    public Object queryActivityByConditionForPage(String name, String owner, String startDate, String endDate,
                                                  @RequestParam(value = "pageNo",defaultValue ="1",required = false) int pageNo,
                                                  @RequestParam(value = "pageSize",defaultValue =Constant.Default_PageSize,required = false) int pageSize){
        HashMap<String, Object> hashMap = new HashMap<>();
        hashMap.put("name",name);
        hashMap.put("owner",owner);
        hashMap.put("startDate",startDate);
        hashMap.put("endDate",endDate);
        hashMap.put("beginNo",(pageNo-1)*pageSize);
        hashMap.put("pageSize",pageSize);
        List<Activity> activityList = activityService.queryActivityByConditionForPage(hashMap);
        int totalRows = activityService.queryCountOfActivityByCondition(hashMap);
        HashMap<String, Object> returnmap = new HashMap<>();
        returnmap.put("totalRows",totalRows);
        returnmap.put("activityList",activityList);
        return returnmap;
    }

    @RequestMapping("/workbench/activity/deleteActivityByIds.do")
    @ResponseBody
    public ReturnObject deleteActivityByIds(@RequestParam("id") String[] ids){
        ReturnObject returnObject = new ReturnObject();
        try {
            int deleteActivityNumber = activityService.deleteActivityByIds(ids);
            if(deleteActivityNumber>0){
                returnObject.setCode(Constant.Operation_Success);
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("?????????...??????????????????");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/queryActivityById.do")
    @ResponseBody
    public Object queryActivityById(String id){
        return activityService.queryActivityById(id);
    }

    @RequestMapping("/workbench/activity/saveEditActivity.do")
    @ResponseBody
    public Object saveEditActivity(Activity activity,HttpSession session){
        activity.setEditTime(DateUtil.FormatDateTime(new Date()));
        User user=(User)session.getAttribute(Constant.Login_User_Msg);
        activity.setEditBy(user.getId());
        ReturnObject returnObject = new ReturnObject();
        try {
            int updateNumber = activityService.saveEditActivity(activity);
            if(updateNumber>0){
                //????????????
                returnObject.setCode(Constant.Operation_Success);
            }else{
                //????????????
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("?????????,??????????????????...");
            }
        } catch (Exception e) {
            //????????????
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("?????????,??????????????????...");
            e.printStackTrace();
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/exportAllActivitys.do")
    public ResponseEntity<byte[]> exportAllActivitys(){
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        try {
            List<Activity> activities = activityService.queryAllActivitys();
            ByteArrayOutputStream baos = ExcelFileResolver.javaToExcel(Activity.class, byteArrayOutputStream,
                    "???????????????", activities,"id","?????????","??????","????????????","????????????","??????","??????",
                             "????????????","?????????","????????????","?????????");
            HttpHeaders httpHeaders = new HttpHeaders();
            httpHeaders.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            httpHeaders.add("Content-Disposition","attachment;filename=activityList.xls");
           return new ResponseEntity<>(baos.toByteArray(), httpHeaders, HttpStatus.OK);
        } finally {
            try {
                byteArrayOutputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @RequestMapping("/workbench/activity/exportActivityByChoose.do")
    public ResponseEntity<byte[]> exportActivityByChoose(@RequestParam("id") String[] ids){
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        List<Activity> activities = activityService.queryActivityByChoose(ids);
        ByteArrayOutputStream baos = ExcelFileResolver.javaToExcel(Activity.class, byteArrayOutputStream,
                "?????????????????????", activities,"id","?????????","??????","????????????","????????????","??????","??????",
                          "????????????","?????????","????????????","?????????");
        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        httpHeaders.add("Content-Disposition","attachment;filename=chooseActivityList.xls");
        return new ResponseEntity<byte[]>(baos.toByteArray(),httpHeaders,HttpStatus.OK);
    }

    @RequestMapping("/workbench/activity/importActivity.do")
    @ResponseBody
    public Object importActivity(@RequestParam("activityFile") MultipartFile multipartFile,HttpSession session) {
        ReturnObject returnObject=null;
        try {
            //????????????
            String originalFilename = multipartFile.getOriginalFilename();
            int lastSign = originalFilename.lastIndexOf(".");
            originalFilename=originalFilename.substring(lastSign);
            String uuid = UUIDUtil.getUUID();
            InputStream fileIs = multipartFile.getInputStream();
            //??????????????????
            HSSFWorkbook workbook = new HSSFWorkbook(fileIs);
            HSSFSheet sheet = workbook.getSheetAt(0);
            HSSFRow row = null;
            try {
                row = sheet.getRow(0);
            } catch (Exception e) {
                throw new RuntimeException("??????????????????");
            }
            LinkedList<String> stringLinkedList = new LinkedList<>();
            Class<Activity> activityClass = Activity.class;
            //???????????????List
            List<Activity> activities = new ArrayList<>();
            //??????????????????????????????
            //getLastCellNum()  ??????????????????????????????
            for (int i = 0; i < row.getLastCellNum(); i++) {
                //????????????????????????????????????(????????????Cell??????)     (????????????)
                //excel??????????????????,????????????Cell?????????null
                HSSFCell cell = row.getCell(i);
                if(cell==null){
                    throw new RuntimeException("Excel?????????????????????");
                }
                //??????????????????????????????String
                cell.setCellType(CellType.STRING);
                stringLinkedList.add(row.getCell(i).getStringCellValue());
            }
            //???????????????????????????
            //getLastRowNum()  ????????????????????????
            for (int i = 1; i < sheet.getLastRowNum()+1; i++) {
                row = sheet.getRow(i);
                Activity activity = new Activity();
                //???????????????????????????    id,createTime,createBy
                activity.setId(UUIDUtil.getUUID());
                activity.setCreateTime(DateUtil.FormatDateTime(new Date()));
                User loginUserMes = (User) session.getAttribute(Constant.Login_User_Msg);
                activity.setCreateBy(loginUserMes.getId());
                //owner??????????????????,????????????,?????????????????????????????????
                activity.setOwner(loginUserMes.getId());
                //??????????????????????????????
                for (int j = 0; j < stringLinkedList.size(); j++) {
                    HSSFCell cell = row.getCell(j);
                    //???????????????????????????
                    String type = null;
                    try {
                        //??????owner???
                        if("owner".equals(stringLinkedList.get(j))){
                            continue;
                        }
                        type = activityClass.getDeclaredField(stringLinkedList.get(j)).getGenericType().toString();
                    } catch (NoSuchFieldException | SecurityException e) {
                        throw new RuntimeException("????????????????????????????????????????????????");
                    }
                    if(type.endsWith("String")){
                        //String??????
                        //?????????????????????   ????????????null???????????????
                        String stringCellValue = null;
                        try {
                            //??????????????????????????????String
                            cell.setCellType(CellType.STRING);
                            stringCellValue = cell.getStringCellValue();
                        } catch (Exception e) {
                            stringCellValue = null;
                        }
                        //???????????????????????????????????????
                        Field declaredField = activityClass.getDeclaredField(stringLinkedList.get(j));
                        declaredField.setAccessible(true);
                        declaredField.set(activity,stringCellValue);
                    }
                }
                activities.add(activity);
            }
            int saveNum = activityService.saveCreateActivityByList(activities);
            returnObject = new ReturnObject();
            if(saveNum>0){
                //??????????????????    ?????????/??????????????????
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setRetData(saveNum);
            }else{
                //??????????????????    ?????????/????????????
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("??????????????????,???????????????????????????...");
            }
        } catch (IOException | NoSuchFieldException | IllegalAccessException e) {
            //?????????????????????
            //??????????????????    ?????????/????????????
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("???????????????,???????????????????????????...");
        }
        return returnObject;
    }

}
