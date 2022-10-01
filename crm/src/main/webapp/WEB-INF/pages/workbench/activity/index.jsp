<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath= request.getScheme() + "://"+request.getServerName()+":"+ request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link rel="stylesheet" href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css">

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<link rel="stylesheet" href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css">
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<link rel="stylesheet" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">
	$(function(){
		//创建按钮添加点击事件
		$("#createActivity").click(function (){
			//初始化工作
			//清空表单数据
			//拿到表单对象,转化为dom元素,调用reset()
			$("#createActivityForm")[0].reset();
			$("#createActivityModal").modal("show");
		})

		//保存按钮添加点击事件
		$("#saveCreateActivityBtn").click(function (){
			var owner = $("#create-marketActivityOwner").val();
			var name = $("#create-marketActivityName").val();
			var startDate = $("#create-startTime").val();
			var endDate = $("#create-endTime").val();
			var cost = $("#create-cost").val();
			var description = $("#create-describe").val();
			if(verifyActivityMes(owner,name,startDate,endDate,cost,description)){
				$.ajax({
					url:"workbench/activity/saveCreateActivity.do",
					data:{
						owner:owner,
						name:name,
						startDate:startDate,
						endDate:endDate,
						cost:cost,
						description:description
					},
					type:"post",
					datatype:"json",
					success:function (data){
						if(data.code==="1"){
							//创建成功
							queryActivityByConditionForPage(1,$("#pagination").bs_pagination("getOption","rowsPerPage"));
							$("#createActivityModal").modal("hide");
						}else if(data.code==="0"){
							//创建失败
							alert(data.message);
							$("#createActivityModal").modal("show");
						}
					}
				})
			}
		})

		//日历插件
		$(".mydate").datetimepicker({
			language:'zh-CN',//语言
			format:'yyyy-mm-dd',//日期的格式
			minView:'month',//可以选择的最小视图
			initialDate:new Date(),//打开后默认选择日期
			autoclose:'true',//选择完之后是否默认关闭
			todayBtn:'true',//显示今天的按钮
			clearBtn:'true'//设置清空按钮
		});

		//打开是列表显示
		queryActivityByConditionForPage(1,5);

		//查询按钮点击
		$("#queryBtn").click(function (){
			queryActivityByConditionForPage(1,$("#pagination").bs_pagination("getOption","rowsPerPage"));
		})

		//选择全部
		$("#checkedAll").click(function (){
			$("#tbody input[type='checkbox']").prop("checked",this.checked);
		})

		//单击选择,控制全选,ajax还没加载完,就取对象了,所以无效
		/*$("tbody input[type='checkbox']").click(function (){
			if($("#tbody input[type='chenckbox']").size()===$("#tbody input[type='chenck']:checked").size()){
				$("#checkedAll").prop("checked",true);
			}else{
				$("checkedAll").prop("checked",false);
			}
		})*/
		$("#tbody").on("click","input[type='checkbox']",function (){
			if($("#tbody input[type='checkbox']").size()===$("#tbody input[type='checkbox']:checked").size()){
				$("#checkedAll").prop("checked",true);
			}else{
				$("#checkedAll").prop("checked",false);
			}
		});

		//删除市场活动
		$("#deleteActivityBtn").click(function (){
			var checkedboxList=$("#tbody input[type='checkbox']:checked");
			if(checkedboxList.size()===0){
				alert("请选择要删除的对象");
			}else{
				//页面跳出确认按钮
				if(window.confirm("您确定要删除吗?")){
					var idsStr="";
					for (let i = 0; i < checkedboxList.size(); i++) {
						//jq筛选的对象.属性名可以直接获取该属性的值
						idsStr+="id="+checkedboxList[i].value+"&";
					}
					idsStr=idsStr.substr(0,idsStr.length-1);
					$.ajax({
						url:"workbench/activity/deleteActivityByIds.do",
						data:idsStr,
						type:'post',
						datatype:'json',
						success:function (data){
							if(data.code==='0'){
								alert(data.message);
								return;
							}
							queryActivityByConditionForPage(1,$("#pagination").bs_pagination("getOption","rowsPerPage"));
						}
					});
				}
			}
		})

		//修改市场活动数据回显
		$("#updateActivityBtn").click(function (){
			var checkboxList = $("#tbody input[type='checkbox']:checked");
			var checkboxListSize = checkboxList.size();
			if(checkboxListSize>=2){
				alert("无法同时修改多条数据!");
				return;
			}
			if(checkboxListSize===0){
				alert("请选择您要修改的数据!");
			}
			var updateId = $("tbody input[type='checkbox']:checked")[0].value;
			$.ajax({
				url:"workbench/activity/queryActivityById.do",
				data:{
					id:updateId
				},
				type:'post',
				dataType:'json',
				success:function (data){
					$("#updateHiddenInput").val(data.id);
					$("#edit-marketActivityOwner").val(data.owner);
					$("#edit-marketActivityName").val(data.name);
					$("#edit-startTime").val(data.startDate);
					$("#edit-endTime").val(data.endDate);
					$("#edit-cost").val(data.cost);
					$("#edit-describe").val(data.description);
				}
			})
			$("#editActivityModal").modal("show");
		})

		//修改市场活动数据提交
		$("#saveEditActivity").click(function (){
			var id=$("#updateHiddenInput").val();
			var owner=$("#edit-marketActivityOwner").val();
			var name=$.trim($("#edit-marketActivityName").val());
			var startDate=$("#edit-startTime").val();
			var endDate=$("#edit-endTime").val();
			var cost=$.trim($("#edit-cost").val());
			var description=$.trim($("#edit-describe").val());
			if(verifyActivityMes(owner,name,startDate,endDate,cost,description)){
				$.ajax({
					url:"workbench/activity/saveEditActivity.do",
					data:{
						id:id,
						owner:owner,
						name:name,
						startDate:startDate,
						endDate:endDate,
						cost:cost,
						description:description
					},
					type:'post',
					datatype:'json',
					success:function (data){
						if(data.code==="1"){
							//修改成功
							$("#editActivityModal").modal("hide");
							var checkboxId=$("#tbody input[type='checkbox']:checked")[0].value;
							queryActivityByConditionForPage($("#pagination").bs_pagination("getOption","currentPage"),
															$("#pagination").bs_pagination("getOption","rowsPerPage"));
							//之前选择修改的复选框的默认继续保持选择状态
							var checkboxList=$("#tbody input[type='checkbox']");
							for (let i = 0; i < checkboxList.size(); i++) {
								if(checkboxList[i].value==checkboxId){
									checkboxList[i].checked=true;
								}
							}
						}else {
							//修改失败
							alert(data.message);
							$("#editActivityModal").modal("show");
						}
					}
				})
			}
		})

		//批量导出
		$("#exportActivityAllBtn").click(function (){
			window.location.href="workbench/activity/exportAllActivitys.do";
		})

		//选择导出
		$("#exportActivityXzBtn").click(function (){
			//判断是否选择
			var chooseList=$("#tbody input[type='checkbox']:checked");
			if(chooseList.length===0){
				alert("请选择需要生成表格的数据")
				return;
			}
			var chooseId="";
			for (let i = 0; i < chooseList.size(); i++) {
				chooseId+="id="+chooseList[i].value+"&";
			}
			chooseId=chooseId.substr(0,chooseId.length-1);
			window.location.href="workbench/activity/exportActivityByChoose.do?"+chooseId;
		})

		//Excel文件上传
		$("#importActivityBtn").click(function (){
			//file输入框jq对象.val()可以获取上传文件的名字
			var filename=$("#activityFile").val();
			var lastSign=filename.lastIndexOf(".")
			var fileLastName=filename.substring(lastSign+1).toLocaleLowerCase();
			if (fileLastName!=="xls"){
				alert("只能上传xls文件");
				return;
			}
			//上传文件的dom对象.file[0].size()可以获取文件大小(字节为单位)
			var fileSize=$("#activityFile")[0].files[0].size;
			if(fileSize>1024*1024*5){
				alert("文件不能大于5MB");
				return;
			}
			var formData = new FormData();
			//上传文件使用FormData对象
			formData.append("activityFile",$("#activityFile")[0].files[0]);
			$.ajax({
				url:"workbench/activity/importActivity.do",
				data:formData,
				processData:false,//数据传送到后端不要解析成字符串
				contentType:false,//数据不要使用urlencoded编码
				type:"post",
				datatype:"json",
				success:function (data){
					if(data.code=="1"){
						//导入成功
						alert("成功导入"+data.retData+" 条数据");
						$("#importActivityModal").modal("hide");
						//导入成功后返回第一页
						queryActivityByConditionForPage(1,$("#pagination").bs_pagination("getOption","rowsPerPage"));
					}else if(data.code=="0"){
						//导入失败
						$("#importActivityModal").modal("show");
						alert(data.Message);
					}
				}
			})
		})
	});

	//验证activity数据是否合法函数
	function verifyActivityMes(owner,name,startDate,endDate,cost){
		if(owner===""){
			alert("所有者不能为空");
			return false;
		}
		if(name===""){
			alert("名称不能为空");
			return false;
		}
		if(startDate===""||endDate===""){
			alert("开始时间与结束时间不能同时为空");
			return false;
		}
		if(endDate<startDate){
			alert("时间结束时间小于开始时间");
			return false;
		}
		//正则表达式
		var reg=/^(([1-9]\d*)|0)$/
		if(!cost.match(reg)){
			alert("成本必须为非负数");
			return false;
		}
		return true;
	}


	//查询函数
	function queryActivityByConditionForPage(pageNo,pageSize){
		var query_name=$("#query-name").val();
		var query_owner=$("#query-owner").val();
		var query_startdate=$("#query-startdate").val();
		var query_enddate=$("#query-enddate").val();
		$.ajax({
			url:"workbench/activity/queryActivityByConditionForPage.do",
			data:{
				name:query_name,
				owner:query_owner,
				startDate:query_startdate,
				endDate:query_enddate,
				pageNo:pageNo,
				pageSize:pageSize,
			},
			type:"post",
			datatype:"json",
			success:function (data){
				var activitydata="";
				$.each(data.activityList,function (index,obj){
					activitydata+="<tr class=\"active\">"
					activitydata+="<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>"
					activitydata+="<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/activity/detail.do?id="+obj.id+"';\">"+obj.name+"</a></td>"
					activitydata+="<td>"+obj.owner+"</td>"
					activitydata+="<td>"+obj.startDate+"</td>"
					activitydata+="<td>"+obj.endDate+"</td>"
					activitydata+="</tr>"
				})
				$("#tbody").html(activitydata);
				$("#checkedAll").prop("checked",false);
				// $("#query_totalrows").text(data.totalRows);
				var totalPages = Math.ceil(data.totalRows/pageSize);
				$("#pagination").bs_pagination({
					totalPages:totalPages,//总页数---必须写
					totalRows:data.totalRows,//总记录条数
					rowsPerPage:pageSize,//每页显示的条数

					currentPage:pageNo,//当前显示的页面

					visiblePageLinks: 5,//显示的卡片数量

					showGoToPage: true,//显示跳转页面
					showRowsPerPage: true,//显示每页的条数
					showRowsInfo: true,//显示记录的信息

					onChangePage:function (event,pageObj){//用户切换页码时触发的函数 --返回切换页码时pageNo和pageSize
						//alert(pageObj.currentPage);pageNo
						//alert(pageObj.rowsPerPage);pageSize
						//event   事件
						//pageObj 翻页信息

						//pageObj.rowsPerPage是本次执行的pageSize
						queryActivityByConditionForPage(pageObj.currentPage,pageObj.rowsPerPage);
					}
				})
			}
		})
	}
</script>
</head>
<body>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="createActivityForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
									<c:forEach items="${userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" readonly="readonly" id="create-startTime">
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" readonly="readonly" id="create-endTime">
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveCreateActivityBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form" >
						<input type="hidden" id="updateHiddenInput">
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
									<c:forEach items="${userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-startTime" readonly="readonly" value="2020-10-10">
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-endTime" readonly="readonly" value="2020-10-20">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" value="5,000">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal" id="saveEditActivity">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 导入市场活动的模态窗口 -->
    <div class="modal fade" id="importActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="activityFile">
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>重要提示</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                            <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
                </div>
            </div>
        </div>
    </div>
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon" >名称</div>
				      <input class="form-control" id="query-name" type="text">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control "  id="query-owner" type="text">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon"  >开始日期</div>
					  <input class="form-control mydate" readonly="readonly" type="text" id="query-startdate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control mydate" readonly="readonly" type="text" id="query-enddate">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="queryBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createActivity"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="updateActivityBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				<div class="btn-group" style="position: relative; top: 18%;">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal" ><span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）</button>
                    <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
                    <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
                </div>
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkedAll"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="tbody">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
				<div id="pagination"></div>
			</div>

			<%--<div style="height: 50px; position: relative;top: 30px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b id="query_totalrows">50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>
				<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>
			</div>--%>
			
		</div>
		
	</div>
</body>
</html>