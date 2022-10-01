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
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<%--引入typehead框架--%>
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
<script type="text/javascript">
	$(function (){
		//判断是否是从客户来
		var customerName='${customer.name}'
		if(customerName!==""){
			$("#create-transactionName").val(customerName+"-");
			$("#create-accountName").val(customerName);
		}

		//预计成交时间:日历插件
		$(".datetimepicker").datetimepicker({
			language:'zh-CN',//语言
			format:'yyyy-mm-dd',//日期的格式
			minView:'month',//可以选择的最小视图
			initialDate:new Date(),//打开后默认选择日期
			autoclose:'true',//选择完之后是否默认关闭
			todayBtn:'true',//显示今天的按钮
			clearBtn:'true'//设置清空按钮
		})

		//阶段选择后自动填写可能性
		//change函数:内容发生变化时触发
		$("#create-transactionStage").change(function (){
			//收集参数
			var stage=$("#create-transactionStage option:selected").text()

			//发送请求
			$.ajax({
				url:"workbench/transaction/queryPossibility.do",
				data:{
					stage:stage
				},
				type:'post',
				datatype:'json',
				success:function (data){
					$("#create-possibility").val(data);
				}
			})
		})

		//模糊查询生成下拉菜单
		$("#create-accountName").typeahead({
			//每次键盘弹起自动触发该函数
			source:function (jquery,process){
				$.ajax({
					url:"workbench/transaction/queryCustomerNameByDimName.do",
					data:{
						//jquery是输入框的内容
						dimName:jquery
					},
					type:'post',
					datatyoe:'json',
					success:function (data){
						//process可以转化数据为[a,b,c,...]的格式,符合框架要求
						process(data);
					}
				})
			}
		})

		//点击查询Activity按钮,打开modal
		$("#queryActivityBtn").click(function (){
			$("#queryActivityListBtn").keyup();
			$("#findMarketActivity").modal("show");
		})

		//键盘弹起,模糊查询ActivityList
		$("#queryActivityListBtn").keyup(function (){
			//收集参数
			var dimName=$("#queryActivityListBtn").val();

			//发送请求
			$.ajax({
				url:"workbench/transaction/queryActivityForDetailByDimName.do",
				data:{
					dimName:dimName
				},
				type:'post',
				datatype: 'json',
				success:function (data){
					var activityListStr="";
					$.each(data,function (index,obj){
						activityListStr+="<tr>";
						activityListStr+="<td><input type=\"radio\" name=\"activity\" value=\""+obj.id+"\" activityName=\""+obj.name+"\"/></td>";
						activityListStr+="<td>"+obj.name+"</td>";
						activityListStr+="<td>"+obj.startDate+"</td>";
						activityListStr+="<td>"+obj.endDate+"</td>";
						activityListStr+="<td>"+obj.owner+"</td>";
						activityListStr+="</tr>";
					})
					$("#tBody").html(activityListStr);
				}
			})
		});

		//选择activity
		$("#tBody").on('click','input[type="radio"]',function (){
			//收集参数
			var activityId=$(this).val();
			var activityName=$(this).attr("activityName");

			//内容显示,activityId隐藏域显示
			$("#activityIdHidden").val(activityId);
			$("#create-activitySrc").val(activityName);
		})

		//点击查询Contacts按钮,打开模态框
		$("#queryContactsBtn").click(function (){
			$("#queryContactsListBtn").keyup();
			$("#findContacts").modal("show");
		})

		//键盘弹起,查询ContactsList
		$("#queryContactsListBtn").keyup(function (){
			//收集参数
			var dimName=$("#queryContactsListBtn").val();

			//发送请求
			$.ajax({
				url:'workbench/transaction/queryContactsForDetailByDimName.do',
				data:{
					dimName:dimName
				},
				type:'post',
				datatype:'json',
				success:function (data){
					var contactsListStr="";
					$.each(data,function (index,obj){
						contactsListStr+="<tr>";
						contactsListStr+="<td><input type=\"radio\" name=\"activity\" value=\""+obj.id+"\" contactsName=\""+obj.fullname+"\"/></td>";
						contactsListStr+="<td>"+obj.fullname+"</td>";
						contactsListStr+="<td>"+obj.email+"</td>";
						contactsListStr+="<td>"+obj.mphone+"</td>";
						contactsListStr+="</tr>";
					})
					$("#tBodyContacts").html(contactsListStr);
				}
			})
		})

		//参数显示
		$("#tBodyContacts").on('click','input[type="radio"]',function (){
			//收集参数
			var contactsName=$(this).attr("contactsName");
			var contactsId=$(this).val();

			//参数显示到输入框和隐藏域
			$("#contactsIdHidden").val(contactsId);
			$("#create-contactsName").val(contactsName);
		})

		//点击保存按钮
		$("#saveCreateTranBtn").click(function (){
			//收集参数
			var owner=$("#create-transactionOwner").val();
			var money=$("#create-amountOfMoney").val();
			var name=$("#create-transactionName").val();
			var expectedDate=$("#create-expectedClosingDate").val();
			var customerId=$("#create-accountName").val();
			var stage=$("#create-transactionStage").val();
			var type=$("#create-transactionType").val();
			var source=$("#create-clueSource").val();
			var activityId=$("#activityIdHidden").val();
			var contactsId=$("#contactsIdHidden").val();
			var description=$("#create-describe").val();
			var contactSummary=$("#create-contactSummary").val();
			var nextContactTime=$("#create-nextContactTime").val();

			//发送请求
			$.ajax({
				url:'workbench/transaction/saveCreateTran.do',
				data:{
					owner:owner,
					money:money,
					name:name,
					expectedDate:expectedDate,
					customerId:customerId,
					stage:stage,
					type:type,
					source:source,
					activityId:activityId,
					contactsId:contactsId,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime
				},
				type:'post',
				datatype:'json',
				success:function (data){
					if(data.code==='0'){
						alert(data.message);
					}else if(data.code==='1'){
						if('${customer.id}'!==""){
							//客户页面跳转来的
							window.location.href='workbench/customer/toDetail.do?id='+'${customer.id}';
							return;
						}
						window.location.href='workbench/transaction/toIndex.do';
					}
				}
			})
		})

	})
</script>
</head>
<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="queryActivityListBtn" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="tBody">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="queryContactsListBtn" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="tBodyContacts">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>创建交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" id="saveCreateTranBtn" class="btn btn-primary">保存</button>
			<button type="button" class="btn btn-default">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" style="position: relative; top: -30px;">
		<div class="form-group">
			<label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionOwner">
				  <%--<option>zhangsan</option>
				  <option>lisi</option>
				  <option>wangwu</option>--%>
					<c:forEach items="${userList}" var="user">
						<option value="${user.id}">${user.name}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-amountOfMoney">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-transactionName">
			</div>
			<label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control datetimepicker" id="create-expectedClosingDate" readonly="readonly">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-accountName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-accountName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="create-transactionStage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-transactionStage">
			  	<option></option>
			  	<%--<option>资质审查</option>
			  	<option>需求分析</option>
			  	<option>价值建议</option>
			  	<option>确定决策者</option>
			  	<option>提案/报价</option>
			  	<option>谈判/复审</option>
			  	<option>成交</option>
			  	<option>丢失的线索</option>
			  	<option>因竞争丢失关闭</option>--%>
				  <c:forEach items="${stageList}" var="stage">
					  <option value="${stage.id}">${stage.value}</option>
				  </c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionType">
				  <option></option>
				  <%--<option>已有业务</option>
				  <option>新业务</option>--%>
					<c:forEach items="${typeList}" var="type">
						<option value="${type.id}">${type.value}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" readonly="readonly" class="form-control" id="create-possibility">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-clueSource">
				  <option></option>
				  <%--<option>广告</option>
				  <option>推销电话</option>
				  <option>员工介绍</option>
				  <option>外部介绍</option>
				  <option>在线商场</option>
				  <option>合作伙伴</option>
				  <option>公开媒介</option>
				  <option>销售邮件</option>
				  <option>合作伙伴研讨会</option>
				  <option>内部研讨会</option>
				  <option>交易会</option>
				  <option>web下载</option>
				  <option>web调研</option>
				  <option>聊天</option>--%>
					<c:forEach items="${sourceList}" var="source">
						<option value="${source.id}">${source.value}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="queryActivityBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-activitySrc" readonly="readonly">
				<input type="hidden" id="activityIdHidden">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" id="queryContactsBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-contactsName" readonly="readonly">
				<input type="hidden" id="contactsIdHidden">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-describe" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-describe"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control datetimepicker" id="create-nextContactTime" readonly="readonly">
			</div>
		</div>
		
	</form>
</body>
</html>