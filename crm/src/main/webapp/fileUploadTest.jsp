<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath= request.getScheme() + "://"+request.getServerName()+":"+ request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <title>Title</title>
</head>
<body>
<form action="workbench/activity/importActivity.do" method="post" enctype="multipart/form-data">
    <input type="file" name="activityFile"><br>
    <input type="submit" value="提交">
</form>
</body>
</html>
