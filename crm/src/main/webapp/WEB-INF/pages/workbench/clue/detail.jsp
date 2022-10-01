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
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;

	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});

		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});

		/*$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});

		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});

		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});

		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});*/

		//动态生成的数据绑定事件需要用on
		$("#clueRemarkList").on("mouseover",".remarkDiv",function (){
			$(this).children("div").children("div").show();
		})

		$("#clueRemarkList").on("mouseout",".remarkDiv",function (){
			$(this).children("div").children("div").hide();
		})

		$("#clueRemarkList").on("mouseover",".myHref",function (){
			$(this).children("span").css("color","red");
		})

		$("#clueRemarkList").on("mouseout",".myHref",function (){
			$(this).children("span").css("color","#E6E6E6");
		})

		//保存clueRemark
		$("#saveClueRemarkBtn").click(function (){
			//收集参数
			var clueId='${clueDetail.id}';
			var noteContent=$("#remark").val();

			//效验参数
			noteContent=noteContent.trim();
			if(noteContent===""){
				alert("请输入评论内容");
				return;
			}

			//发送保存clueRemark请求
			$.ajax({
				url:'workbench/clue/saveClueRemark.do',
				data:{
					clueId:clueId,
					noteContent:noteContent
				},
				type:'post',
				datatype:'json',
				success:function (data){
					if(data.code=='0'){
						//保存失败
						alert(data.message);
					}else if(data.code=='1'){
						//保存成功	内容重新显示,清空输入框
						var addStr="";
						addStr+="<div class=\"remarkDiv\" id=\"div_"+data.retData.id+"\" style=\"height: 60px;\">";
						addStr+="<img title=\"${sessionScope.loginUserMsg.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
						addStr+="<div style=\"position: relative; top: -40px; left: 40px;\" >";
						addStr+="<h5>"+data.retData.noteContent+"</h5>";
						addStr+="<font color=\"gray\">线索</font> <font color=\"gray\">-</font> <b>${clueDetail.fullname}${clueDetail.appellation}-${clueDetail.company}</b> <small style=\"color: gray;\"> "+data.retData.createTime+" 由${sessionScope.loginUserMsg.name} 创建</small>";
						addStr+="<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
						addStr+="<a class=\"myHref\" name=\"edit\" clueRemarkId=\""+data.retData.id+"\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						addStr+="&nbsp;&nbsp;&nbsp;&nbsp;";
						addStr+="<a class=\"myHref\" name=\"delete\" clueRemarkId=\""+data.retData.id+"\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						addStr+="</div>";
						addStr+="</div>";
						addStr+="</div>";
						$("#remarkDiv").before(addStr);
						$("#remark").val("");
					}
				}
			})
		})

		//删除ClueRemark,有可能是动态生成的数据,绑定事件用on
		$("#clueRemarkList").on("click","a[name='delete']",function (){
			//收集参数
			//自定义参数只能用attr获取
			var id=$(this).attr("clueRemarkId");

			//发送删除ClueRemark请求
			$.ajax({
				url:"workbench/clue/deleteClueRemark.do",
				data:{
					id:id
				},
				type:'post',
				datatype: 'json',
				success:function (data){
					if(data.code=='0'){
						//删除失败
						alert(data.message);
					}else if(data.code='1'){
						//删除成功   清除该评论
						$("#div_"+id).remove();
					}
				}
			})
		})

		//更新ClueRemark
		//点击按钮打开model
		$("#clueRemarkList").on("click","a[name='edit']",function (){
			//$("#noteContent").val()
			$("#editClueRemark").modal("show");
			var id=$(this).attr("clueRemarkId");
			//noteContext输入框数据回显
			var noteContextOld=$("#div_"+id+" h5").text();
			$("#noteContent").val(noteContextOld);
			//click内嵌click事件,内层click绑定之前用unbind()清除事件
			$("#updateClueRemark").unbind();
			//点击更新按钮,更新noteContent
			$("#updateClueRemark").click(function (){
				//收集参数
				var noteContentNew=$("#noteContent").val();

				//效验参数
				if(noteContentNew===""){
					alert("请输入修改内容");
					return;
				}

				//发送请求
				$.ajax({
					url:'workbench/clue/saveEditClueRemark.do',
					data:{
						id:id,
						noteContent:noteContentNew
					},
					type:'post',
					datatype:'json',
					success:function (data){
						if(data.code==='0'){
							//编辑失败
							alert(data.message);
						}else if(data.code==='1'){
							//编辑成功
							$("#div_"+id+" h5").text(noteContentNew);
							$("#noteContent").val("");
							$("#editClueRemark").modal("hide");
						}
					}
				})
			})
		})

		//解除关联
		$("#activityList").on('click','a',function (){
			//收集参数
			clueId='${clueDetail.id}';
			activityId=$(this).attr("activityId");

			//判断是否删除
			if(window.confirm("您确定取消此关联吗?")==false){
				return;
			}

			//发送解除关联的请求
			$.ajax({
				url:"workbench/clue/deleteClueActivityRelationByClueIdAndActivityId.do",
				data:{
					clueId:clueId,
					activityId:activityId
				},
				type:'post',
				datatype:'json',
				success:function (data){
					if(data.code==='1'){
						//解除成功  清除数据,提示信息
						$("#tr_"+activityId).remove();
						alert(data.message);
					}else if(data.code==='0'){
						//解除失败
						alert(data.message);
					}
				}
			})
		})


		//弹出关联市场modal
		$("#bundActivityBtn").click(function (){
			//清空数据
			$("#queryActivityByDimNameBtn").val("");

			$("#queryActivityByDimNameBtn").keyup();
			$("#bundModal").modal("show");
		})

		$("#queryActivityByDimNameBtn").keyup(function (){
			//收集参数	传递dimName,clueId
			var dimName=this.value
			var clueId='${clueDetail.id}';

			$.ajax({
				url:"workbench/clue/queryActivityByDimNameAndClueId.do",
				data:{
					dimName:dimName,
					clueId:clueId
				},
				type:'post',
				datatype:'json',
				success:function (data){
					//数据显示
					var activityListStr="";
					$.each(data,function (index,obj){
						activityListStr+="<tr>";
						activityListStr+="<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>";
						activityListStr+="<td>"+obj.name+"</td>";
						activityListStr+="<td>"+obj.startDate+"</td>";
						activityListStr+="<td>"+obj.endDate+"</td>";
						activityListStr+="<td>"+obj.owner+"</td>";
						activityListStr+="</tr>";
					})
					$("#clueActivityList").html(activityListStr);
				}
			});
		})

		//全选按钮框
		$("#chooseAll").click(function (){
			$("#clueActivityList input[type='checkbox']").prop("checked",this.checked);
		})
		$("#clueActivityList").on('click',"input[type='checkbox']",function (){
			if($("#clueActivityList input[type='checkbox']").size()===
					$("#clueActivityList input[type='checkbox']:checked").size()){
				$("#chooseAll").prop("checked",true);
			}else{
				$("#chooseAll").prop("checked",false);
			}
		})

		//关联Activity
		$("#relationBtn").click(function (){
			//收集参数
			var chooseList=$("#clueActivityList input[type='checkbox']:checked")
			if(chooseList.size()===0){
				alert("请选择要关联的对象");
			}
			var dataStr=""
			for (let i = 0; i < chooseList.size(); i++) {
				dataStr+="activityId="+chooseList[i].value+"&";
			}
			dataStr+='clueId='+'${clueDetail.id}';

			$.ajax({
				url:'workbench/clue/saveBund.do',
				data:dataStr,
				type:'post',
				datatype:'json',
				success:function (data){
					if(data.code==='0'){
						alert(data.message);
						$("#bundModal").modal("show");
					}else if(data.code==='1'){
						var newClueActivityList="";
						$.each(data.retData,function (index,obj){
							newClueActivityList+="<tr id=\"tr_"+obj.id+"\">";
							newClueActivityList+="<td>"+obj.name+"</td>";
							newClueActivityList+="<td>"+obj.startDate+"</td>";
							newClueActivityList+="<td>"+obj.endDate+"</td>";
							newClueActivityList+="<td>"+obj.owner+"</td>";
							newClueActivityList+="<td><a href=\"javascript:void(0);\" activityId=\""+obj.id+"\"  style=\"text-decoration: none;\"><span class=\"glyphicon glyphicon-remove\"></span>解除关联</a></td>";
							newClueActivityList+="</tr>";
						})
						$("#relationList").append(newClueActivityList);
						alert("添加成功")
						//取消全选
						$("#chooseAll").prop("checked",false);
						$("#bundModal").modal("hide");
					}
				}
			})
		})

		//转换按钮
		$("#convert").click(function (){
			var clueId='${clueDetail.id}'
			window.location.href="workbench/clue/convert.do?clueId="+clueId;
		})

	});


</script>

</head>
<body>

	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editClueRemark" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
		<div class="modal-dialog" role="document" style="width: 40%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改备注</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<div class="form-group">
							<label for="noteContent" class="col-sm-2 control-label">内容</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="noteContent"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateClueRemark">更新</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 关联市场活动的模态窗口 -->
	<div class="modal fade" id="bundModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">关联市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input id="queryActivityByDimNameBtn" type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td><input type="checkbox" id="chooseAll"/></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="clueActivityList">
							<tr>
								<td><input type="checkbox"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="checkbox"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" id="relationBtn" class="btn btn-primary">关联</button>
				</div>
			</div>
		</div>
	</div>


	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>

	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${clueDetail.fullname}${clueDetail.appellation} <small>${clueDetail.company}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" id="convert" class="btn btn-default" onclick="window.location.href='convert.jsp';"><span class="glyphicon glyphicon-retweet"></span> 转换</button>

		</div>
	</div>

	<br/>
	<br/>
	<br/>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clueDetail.fullname}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clueDetail.owner}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clueDetail.company}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">职位</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clueDetail.job}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">邮箱</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clueDetail.email}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clueDetail.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clueDetail.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clueDetail.mphone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">线索状态</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clueDetail.state}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">线索来源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clueDetail.source}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clueDetail.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${clueDetail.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clueDetail.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${clueDetail.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${clueDetail.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${clueDetail.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clueDetail.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 100px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${clueDetail.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>

	<!-- 备注 -->
	<div style="position: relative; top: 40px; left: 40px;" id="clueRemarkList">
		<div class="page-header">
			<h4>备注</h4>
		</div>

		<%--<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">线索</font> <font color="gray">-</font> <b>李四先生-动力节点</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>

		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">线索</font> <font color="gray">-</font> <b>李四先生-动力节点</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>

		<c:forEach items="${clueRemarkList}" var="clueRemark">
			<div class="remarkDiv" id="div_${clueRemark.id}" style="height: 60px;">
				<img title="${clueRemark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
				<div style="position: relative; top: -40px; left: 40px;" >
					<h5>${clueRemark.noteContent}</h5>
					<font color="gray">线索</font> <font color="gray">-</font> <b>${clueDetail.fullname}${clueDetail.appellation}-${clueDetail.company}</b> <small style="color: gray;"> ${clueRemark.editFlag=="0"?clueRemark.createTime:clueRemark.editTime} 由${clueRemark.editFlag=="0"?clueRemark.createBy:clueRemark.editBy} ${clueRemark.editFlag=="0"?"创建":"修改"}</small>
					<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
						<a class="myHref" name="edit" href="javascript:void(0);" clueRemarkId="${clueRemark.id}"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<a class="myHref" name="delete" href="javascript:void(0);" clueRemarkId="${clueRemark.id}"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
					</div>
				</div>
			</div>
		</c:forEach>

		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" id="saveClueRemarkBtn" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>

	<!-- 市场活动 -->
	<div>
		<div style="position: relative; top: 60px; left: 40px;">
			<div class="page-header">
				<h4>市场活动</h4>
			</div>
			<div style="position: relative;top: 0px;" id="activityList">
				<table class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="relationList">
						<%--<tr>
							<td>发传单</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
							<td>zhangsan</td>
							<td><a href="javascript:void(0);"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
						</tr>
						<tr>
							<td>发传单</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
							<td>zhangsan</td>
							<td><a href="javascript:void(0);"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
						</tr>--%>

						<c:forEach items="${activityList}" var="activity">
							<tr id="tr_${activity.id}">
								<td>${activity.name}</td>
								<td>${activity.startDate}</td>
								<td>${activity.endDate}</td>
								<td>${activity.owner}</td>
								<td><a href="javascript:void(0);" activityId='${activity.id}'  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
							</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>

			<div>
				<a href="javascript:void(0);" id="bundActivityBtn" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
			</div>
		</div>
	</div>


	<div style="height: 200px;"></div>
</body>
</html>