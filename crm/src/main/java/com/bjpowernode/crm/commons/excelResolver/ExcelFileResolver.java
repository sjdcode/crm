package com.bjpowernode.crm.commons.excelResolver;

import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.ss.usermodel.HorizontalAlignment;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.lang.reflect.Field;
import java.util.List;

public class ExcelFileResolver {

    //生成excel文件
    public static <E> ByteArrayOutputStream javaToExcel(Class<E> clazz,ByteArrayOutputStream byteArrayOutputStream,
                                                         String sheetName, List<E> list,String...name) {
        Field[] declaredFields = clazz.getDeclaredFields();
        if(name!=null&&name.length!=declaredFields.length){
            throw new RuntimeException("参数个数与类属性个数不一致");
        }
        HSSFWorkbook workbook=null;
        try {
            //1.创建文件
            workbook = new HSSFWorkbook();
            //1.1文件内容显示居中
            HSSFCellStyle cellStyle = workbook.createCellStyle();
            cellStyle.setAlignment(HorizontalAlignment.CENTER);
            //2.创建表
            HSSFSheet sheet = workbook.createSheet(sheetName);
            //3.创建行
            HSSFRow row = sheet.createRow(0);
            HSSFCell cell;
            //execl首行字段赋值
            for (int i = 0; i < declaredFields.length; i++) {
                //4.创建列
                cell= row.createCell(i);
                //判断首行是否使用自定义数据
                if(name != null){
                    cell.setCellValue(name[i]);
                }else{
                    //5.列设置值
                    cell.setCellValue(declaredFields[i].getName());
                }
            }
            //list赋值
            if(list!=null&&list.size()>0){
                //list行数据
                for (int i = 0; i < list.size(); i++) {
                    row= sheet.createRow(i + 1);
                    E e = list.get(i);
                    //list列数据赋值
                    for (int j = 0; j < declaredFields.length; j++) {
                        cell = row.createCell(j);
                        declaredFields[j].setAccessible(true);
                        cell.setCellValue((String) declaredFields[j].get(e));
                    }
                }
            }
            //6.生成Excel文件
            workbook.write(byteArrayOutputStream);
        } catch (IOException | IllegalAccessException e) {
            e.printStackTrace();
        } finally {
            if(workbook!=null){
                try {
                    workbook.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return byteArrayOutputStream;
    }

}
