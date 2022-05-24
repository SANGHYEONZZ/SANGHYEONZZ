<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:if test="${not empty ss_level and not empty ss_id}">
	<!-- 로그인 되어 있을 때 ${ss_id}-->	
	<script>
		/* 전역 변수 */
		var isloaded = false;												// 타이머 중복 실행 방지
		var accessTime = "<c:out value='${sessionScope.lastAccessTime}'/>"; // 세션 액세스 시간
		var remainSecond = "<c:out value='${sessionScope.ss_time}'/>"; 		// 최초 설정할 시간(sec)
		var overTime = "/site/nec/login/Logout.do";							// 로그아웃 url
		var mascot = '<div class="mascot"></div>';
		var overlayZindex = $("#overlay").css("z-index");
		
		// 타이머 실행
		$(function(){
			// 문서 로드시 중복 실행 방지를 위한 조건문
			if(isloaded) {
				return;
			}
			
			var footer = '';
			
			footer = '<div id="wrap">';
			
			$('#footer').before(footer);
			
			footer = '';
			
			footer = '<div class="sesstion_finish">'
		   			+'<div class="session_cont">'
					+'</div></div>';
			
			$("#overlay").prev().append(footer);
					
			setTimer();
			setInterval('setTimer();',1000);     // 문서 로드시 타이머 시작
			
			// 새로고침 감지
			window.onbeforeunload = sessionExtension();
			
			isloaded = true;
		});
		 
		// 타이머 시간 표출 함수
		function setTimer(){  
			
		   remainMinute_ = parseInt(remainSecond/60);
		   remainSecond_ = parseInt(remainSecond%60);
		   
		   if(remainSecond == 300) {
			   confirmChk();
		   } else if(remainSecond == 10) {
			   confirmChk();
		   }
		   
		   if(remainSecond > 0){
		      $(".timer").empty();
		      $(".timer").append(timeSet(remainMinute_,2) + ":" + timeSet(remainSecond_,2));    // hh:mm 표기
		      remainSecond--;
		   } else if(remainSecond == 0) {
			// 알림창 띄운 후 로그아웃
       		var html = '';
			
			$(".session_cont").empty();
       		$("#overlay").addClass("active");
       		$("#overlay").css("z-index", "139");
       		$("#overlay").show();
       		$("#overlay").off('click').on('click', function(e){
				e.stopPropagation();
				$("#overlay").show();
			});
       		$(".sesstion_finish").addClass("active");
       		html += '<span class="type2">'
       		 		+'세션이 만료되어 <em>로그아웃</em> 됩니다.'
       	    		+'</span>';
       	    html += '<div><button type="button" class="yes" onclick="extensionOk('+"'로그아웃'"+');">확인</button></div>';
       	    html += mascot;
       		$(".session_cont").append(html);
       		autoClose('로그아웃');
		   }
		}
		
		// hh mm형식으로 표기하기 위한 함수
		function timeSet(str,len){  
			str = str+"";
		   while(str.length<len){
		      str = "0"+str;
		   }
		   return str;
		}
		
		// 세션 확인 함수
		function confirmChk(){
			
			$.ajax({
                type : "POST",           
                url : "/layout/sessionChk.do",      
                data : "lastAccessTime="+accessTime ,            
                success : function(e){
                	
                	var res = JSON.parse(e);
                	var html = '';
                	
                	// 마지막 세션 액세스 시간이 더 최근일 경우 
                	if(res.state == "update"){
                		accessTime = res.lastAccessTime;	// 리턴 받은 액세스 시간을 전역변수에 적용
                		remainSecond = res.remainTime;		// 리턴 받은 세션 유효시간을 전역변수에 적용
                	// 세션 정보가 존재하지 않을 때	
                	} else if(res.state == "NotSes") {
                		// 알림창 띄운 후 로그아웃
                		$(".session_cont").empty();
                		$("#overlay").addClass("active");
                		$("#overlay").css("z-index", "139");
                		$("#overlay").show();
                		$("#overlay").off('click').on('click', function(e){
            				e.stopPropagation();
            				$("#overlay").show();
            			});
                		$(".sesstion_finish").addClass("active");
                		html += '<span class="type1">'
                		 		+'로그인 정보가 존재하지 않습니다.<br>'
                	     		+'<em>다시 로그인</em>해주세요'
                	    		+'</span>';
                	    html += '<div><button type="button" class="yes" onclick="extensionOk('+"'NotSes'"+');">확인</button></div>';
                	    html += mascot; 
                		$(".session_cont").append(html);
                		autoClose(String(res.state));
                	// 마지막 세션 액세스 시간과 동일할 경우
                	} else {
                		$(".session_cont").empty();
                		$("#overlay").addClass("active");
                		$("#overlay").css("z-index", "139");
                		$("#overlay").show();
                		$("#overlay").css("z-index", "139");
                		$("#overlay").off('click').on('click', function(e){
            				e.stopPropagation();
            				$("#overlay").show();
            			});
                		html += '<div class="icon1"></div>';
                		html += '<span class="type1">'
               		    		+ ' 로그인 연장을 하시겠습니까?<br>'
               	     			+ '<em class="timer"></em> 후 <b>자동 로그아웃</b> 됩니다.'
               	    			+ '</span>';
               	    	html += '<div><button type="button" class="no" onclick="logoutFunc();">아니오</button> ';
               	    	html += '<button type="button" class="yes" onclick="extensionFunc('+res.remainTime+');">예</button></div>';
               	    	html += mascot;
               	    	
                		$(".session_cont").append(html);
                		
                		$(".sesstion_finish").addClass("active");
                	}
                	
                	if(remainSecond > 300) {
                		nowClose();
                	}
                	$("#overlay").css("z-index", overlayZindex);
                },
                error : function(XMLHttpRequest, textStatus, errorThrown){ 
                    alert("세션정보 확인 중 오류발생 ["+errorThrown+"]");
                }
            });
		}
	
		// 세션 연장 함수
		function sessionExtension() {
			var html = '';
			if(remainSecond != 0) {
				$.ajax({
	                type : "POST",           
	                url : "/layout/sessionExtension.do",      
	                success : function(e){
	                	// 반환값이 없으면 알림창 띄운 후 로그아웃
	                	if(e == "") {
	                		$(".session_cont").empty();
	                		$("#overlay").addClass("active");
	                		$("#overlay").css("z-index", "139");
	                		$("#overlay").show();
	                		$("#overlay").off('click').on('click', function(e){
	            				e.stopPropagation();
	            				$("#overlay").show();
	            			});
	                		$(".sesstion_finish").addClass("active");
	                		html += '<span class="type1">'
	                		 		+'이미 만료된 세션입니다.<br>'
	                	     		+'<em>다시 로그인</em>해주세요'
	                	    		+'</span>';
	                	    html += '<div><button type="button" class="yes" onclick="extensionOk();">확인</button></div>';
	                	    html += mascot;
	                		$(".session_cont").append(html);
	                		
	                		autoClose();
	                	} else {
	                		accessTime = e;
	                	}
	                },
	                error : function(XMLHttpRequest, textStatus, errorThrown){ 
	                    alert("로그인 연장 오류 ["+errorThrown+"]");
	                }
	            });
			}
		}
		
		function logoutFunc(){
			$(".sesstion_finish").removeClass("active");
			$("#overlay").removeClass("active");
			$("#overlay").hide();
			$("#overlay").css("z-index", overlayZindex);
			$(".session_cont").empty();
			window.location.href = overTime;
		}
		
		function extensionFunc(res) {
			
			var cont = '';
			
			cont += '<div class="icon2"></div>';
			cont += '<span class="type2">'
			     	+ '<em>로그인 연장</em>이 완료 되었습니다.'
			     	+ '</span>';
			cont += '<div><button type="button" class="yes" onclick="extensionOk();">확인</button></div>';
			cont += mascot;
			$(".session_cont").empty();
			$(".session_cont").append(cont);
			
			sessionExtension();
			remainSecond = res;
			
			autoClose();
		}
		
		function extensionOk(e) {
			$(".sesstion_finish").removeClass("active");
			$("#overlay").removeClass("active");
			$("#overlay").hide();
			$("#overlay").css("z-index", overlayZindex);
			$(".session_cont").empty();
			if(e == "로그아웃") { window.location.href = overTime; }
			else if(e == "NotSes") { window.location.reload(); }
		}
		
		function autoClose(e) {
			setTimeout(function sessionPopClose() {
				$(".sesstion_finish").removeClass("active");
				$("#overlay").removeClass("active");
				$("#overlay").hide();
				$("#overlay").css("z-index", overlayZindex);
				$(".session_cont").empty();
				if(e == "로그아웃") { window.location.href = overTime; }
				else if(e == "NotSes") { window.location.reload(); }
			}, 5000);
		}
		
		function nowClose() {
			$(".sesstion_finish").removeClass("active");
			$("#overlay").removeClass("active");
			$("#overlay").hide();
			$("#overlay").css("z-index", overlayZindex);
			$(".session_cont").empty();
		}
	</script>
	
	<li><a href="/site/nec/myPage/loginService.do">마이페이지</a></li>
	<li class="second">
		<a class="timer" href="#n"></a>
	</li>
	<li class="second">
		<a href="/site/nec/login/Logout.do" class="bgn">로그아웃</a>
	</li>	
</c:if>
<c:if test="${empty ss_id}">
	<!-- 로그인 안 되어 있을 때 -->	
	<li><a href="/site/nec/user/User_Step_01.do">회원가입</a></li>
	<li class="second"><a href="/site/nec/login/Login.do" class="bgn">로그인</a></li>	
</c:if> 
