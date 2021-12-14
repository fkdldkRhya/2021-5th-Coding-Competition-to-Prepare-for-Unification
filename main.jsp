<%@ page import="java.sql.*"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.Random"%>
<%@ page import="java.security.KeyPair"%>
<%@ page import="java.security.KeyFactory"%>
<%@ page import="java.security.KeyFactory"%>
<%@ page import="java.security.PublicKey"%>
<%@ page import="java.security.PrivateKey"%>
<%@ page import="java.security.KeyPairGenerator"%>
<%@ page import="java.security.spec.RSAPublicKeySpec"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="kro.kr.rhya_network.page.JspPageInfo"%>
<%@ page import="kro.kr.rhya_network.logger.RhyaLogger"%>
<%@ page import="kro.kr.rhya_network.logger.GetClientIPAddress"%>
<%@ page import="kro.kr.rhya_network.databses.DatabaseInfo"%>
<%@ page import="kro.kr.rhya_network.databses.DatabaseConnection"%>
<%@ page import="kro.kr.rhya_network.security.RhyaRSA"%>
<%@ page import="kro.kr.rhya_network.security.SelfXSSFilter"%>
<%@ page import="kro.kr.rhya_network.security.ParameterManipulation"%>
<%@ page import="kro.kr.rhya_network.page.PageParameter"%>
<%@ page import="kro.kr.rhya_network.util.LoginChecker"%>

<%@ page language="java" contentType="text/html; charset=utf-8"
   pageEncoding="utf-8"%>

<!DOCTYPE html>
<html>
	<head>
		<title>통일 알리미</title>
		<meta charset="EUC-KR" />
		<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
		<link rel="apple-touch-icon" sizes="180x180" href="<%=request.getContextPath()%>/webpage/res/icon/apple_touch_logo_icon.png">
		<link rel="icon" type="image/png" sizes="32x32" href="<%=request.getContextPath()%>/webpage/res/icon/logo_32x32.png">
		<link rel="icon" type="image/png" sizes="16x16" href="<%=request.getContextPath()%>/webpage/res/icon/logo_16x16.png">
		<link rel="manifest" href="<%=request.getContextPath()%>/webpage/res/icon/site.webmanifest">
		<link rel="mask-icon" href="<%=request.getContextPath()%>/webpage/res/icon/server_logo.svg" color="#5bbad5">
		<meta name="msapplication-TileColor" content="#da532c">
		<meta name="theme-color" content="#ffffff">
		<link rel="stylesheet" href="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/css/main.css" />
		<noscript><link rel="stylesheet" href="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/css/noscript.css" /></noscript>
	</head>
	
	
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/public_res/js/rsa/jsbn.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/public_res/js/rsa/prng4.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/public_res/js/rsa/rng.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/public_res/js/rsa/rsa.js"></script>
	<script type="text/javascript" src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/js/jquery.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/js/jquery.scrolly.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/js/jquery.dropotron.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/js/jquery.scrollex.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/js/browser.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/js/breakpoints.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/js/util.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/js/manager.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/webpage/res/assets/contest/2021_5th_Coding_Competition_to_Prepare_for_Unification/js/main.js"></script>
	
	
	<%
	String ctoken = request.getParameter(PageParameter.IS_CREATE_TOKEN_PARM);
	int isCreateToken = 0;
	boolean isCreateTokenTOF = true;
	if (ctoken != null) {
		isCreateToken = Integer.parseInt(ctoken);
		if (isCreateToken != 0) {
			isCreateTokenTOF = true;
		}else {
			isCreateTokenTOF = false;
		}
	}
	%>
	
	
	<%
	// Rhya 로거 변수 선언
	RhyaLogger rl = new RhyaLogger();
	// Rhya 로거 설정
	rl.JspName = request.getServletPath();
	rl.LogConsole = true;
	rl.LogFile = true;
	
	// 쿼리 작성 StringBuilder
	StringBuilder sql = new StringBuilder();
	
	// 클라이언트 아이피
	String clientIP = GetClientIPAddress.getClientIp(request);
	
	// 데이터베이스 커넥터 변수 선언
	DatabaseConnection cont = null;
	// 데이터베이스 쿼리 실행 변수 선언
	PreparedStatement stat = null;
	ResultSet rs = null;
	// 데이터베이스 작업 수행 변수 선언
	boolean isTask = true;
	// 파라미터 이름 선언
	final String parm_name_orderby = "orderby";
	final String parm_name_searchtxt = "search";
	// SQL 부과 변수 선언
	final String oder_by_desc = "DESC";
	final String oder_by_asc = "ASC";
	String order_by = oder_by_desc;
	String search = null;
	String order_by_desc = "";
	String order_by_asc = "";
	
	// 데이터베이스 접속 예외 처리
	try {
		// 데이터베이스 접속 및 쿼리 실행
		cont = new DatabaseConnection();
		// 데이터베이스 접속
		cont.Connection(DatabaseInfo.DATABASE_DRIVER_CLASS_NAME,
						DatabaseInfo.DATABASE_CONNECTION_URL,
						DatabaseInfo.DATABASE_ROOT_ACCOUNT_ID,
						DatabaseInfo.DATABASE_ROOT_ACCOUNT_PW);
	}catch (SQLException ex1) {
		// 데이터베이스 접속 오류 처리
		cont = null;
		isTask = false;
		rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv4(clientIP, JspPageInfo.ERROR_PAGE_PATH_HTTP_500, ex1.toString()));
		sql = null;
		// 페이지 이동
		response.sendRedirect(JspPageInfo.ERROR_PAGE_PATH_HTTP_500);
		
		return;
	}catch (ClassNotFoundException ex2) {
		// 데이터베이스 접속 오류 처리
		cont = null;
		isTask = false;
		rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv4(clientIP, JspPageInfo.ERROR_PAGE_PATH_HTTP_500, ex2.toString()));
		sql = null;
		// 페이지 이동
		response.sendRedirect(JspPageInfo.ERROR_PAGE_PATH_HTTP_500);
		
		return;
	}
	
	
	// 페이지 상태 확인
	if (cont != null) {
		// 쿼리 생성
		sql.append("SELECT * FROM ");
		sql.append(DatabaseInfo.DATABASE_TABLE_NAME_JSP_PAGE_SETTING);
		sql.append(" WHERE ");
		sql.append(DatabaseInfo.DATABASE_TABLE_COLUMN_JSP_PAGE_SETTING_PAGE_ID);
		sql.append("=");
		sql.append("?;");

		
		// 쿼리 설정
		stat = cont.GetConnection().prepareStatement(sql.toString());
		stat.setInt(1, JspPageInfo.PageID_2021_5th_Coding_Competition_to_Prepare_for_Unification_Main);
		// 쿼리 생성 StringBuilder 초기화
		sql.delete(0,sql.length());
		// 쿼리 실행
		rs = stat.executeQuery();
		// 쿼리 실행 결과
		int state = 0;
		if (rs.next()) {
			state = rs.getInt(DatabaseInfo.DATABASE_TABLE_COLUMN_JSP_PAGE_SETTING_PAGE_STATE);
		}
		// 상태 확인 - 결과 처리
		if (!JspPageInfo.JspPageStateManager(state)) {
			// 연결 종료
			rs.close();
			stat.close();
			cont.Close();
			sql = null;
			
			// 페이지 이동
			response.sendRedirect(JspPageInfo.ERROR_PAGE_PATH_HTTP_403);
			
			return;
		}
		
		// 예외 처리
		try {
			// 파라미터 가지고 오기
			String searchtxt = request.getParameter(parm_name_searchtxt);
			String orderby = request.getParameter(parm_name_orderby);
			String key = request.getParameter(ParameterManipulation.INTRandomKeyParameter);

			// 파라미터 값 Null 확인
			if (key != null) {
				// 비밀키 가지고 오기
		        PrivateKey get_privateKey = (PrivateKey) session.getAttribute(ParameterManipulation.RSAPrivateKeySession);
		     	// 정수형 인증키 가지고 오기
				String get_int_random_key_org = (String) session.getAttribute(ParameterManipulation.INTRandomKeySession);
		     	
				// 데이터 복호화
				key = RhyaRSA.decryptRsa(get_privateKey, key);
				
				// 정수형 인증키 비교
				if (key.equals(get_int_random_key_org)) {
					// 파라미터 값 Null 확인
					if (searchtxt != null) {
						searchtxt = RhyaRSA.decryptRsa(get_privateKey, searchtxt);	
					}
					if (orderby != null) {
						orderby = RhyaRSA.decryptRsa(get_privateKey, orderby);	
					}
				}else {
					// 작업 비활성화
					isTask = false;
					// 로그 작성
					rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv5(clientIP, JspPageInfo.GetJspPageURL(request, 0)));
					// 연결 종료
					rs.close();
					stat.close();
					cont.Close();
					sql = null;
					// 페이지 이동
					response.sendRedirect(JspPageInfo.GetJspPageURL(request, 0));
					
					return;
				}
			}
			
			// 변수 설정
			if (orderby == null) {
				order_by_desc = "checked";
			}else {
				if (orderby.equals(oder_by_desc)) {
					order_by_desc = "checked";
				}
				
				if (orderby.equals(oder_by_asc)) {
					order_by_asc = "checked";
				}	
				
				order_by = orderby;
			}
			if (searchtxt != null) {
				search = java.net.URLDecoder.decode(searchtxt, "UTF-8");
			}
			
			// XSS 필터 적용
			if (search != null) {
				search = SelfXSSFilter.TextXSSFilter(search);	
			}
			if (order_by != null) {
				order_by = SelfXSSFilter.TextXSSFilter(order_by);	
			}
			if (key != null) {
				key = SelfXSSFilter.TextXSSFilter(key);	
			}
			
			// 로그 작성
			rl.Log(RhyaLogger.Type.Info, rl.CreateLogTextv1(clientIP, new String[] { parm_name_orderby, parm_name_searchtxt, ParameterManipulation.INTRandomKeyParameter }, new String[] { order_by, search, key }));
		}catch (Exception ex) {
			// 작업 비활성화
			isTask = false;
			// 로그 작성
			rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv4(clientIP, JspPageInfo.GetJspPageURL(request, 0), ex.toString()));
			// 연결 종료
			rs.close();
			stat.close();
			cont.Close();
			sql = null;
			// 페이지 이동
			response.sendRedirect(JspPageInfo.GetJspPageURL(request, 0));
			
			return;
		}

		// -------------- 로그인 확인 --------------
		LoginChecker.AutoLoginTask(rl, session, request, response, false, false, null, isCreateTokenTOF);
		// ----------------------------------------
		
		// 파라미터 암호화 RSA키 생성
		KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
		// RSA 키 - 1024bit
		generator.initialize(1024);
		KeyPair keyPair = generator.genKeyPair();
		KeyFactory keyFactory = KeyFactory.getInstance("RSA");
		// 공개키 추출
		PublicKey publicKey = keyPair.getPublic();
		// 비공개키 추출
		PrivateKey privateKey = keyPair.getPrivate();
		// session data - 키설정
		session.setAttribute(ParameterManipulation.RSAPrivateKeySession, privateKey);
		// 공개키 설정
		RSAPublicKeySpec publicSpec = (RSAPublicKeySpec) keyFactory.getKeySpec(publicKey, RSAPublicKeySpec.class);
		String publicKeyModulus = publicSpec.getModulus().toString(16);
		String publicKeyExponent = publicSpec.getPublicExponent().toString(16);
		request.setAttribute("RSAModulus", publicKeyModulus);
		request.setAttribute("RSAExponent", publicKeyExponent);
		// 정수형 랜덤키 생성
		Random random = new Random();
		int randomInt = random.nextInt();
		// 양수로 변경
		randomInt = Math.abs(randomInt);
		// 정수형 랜덤키 설정 
		session.setAttribute(ParameterManipulation.INTRandomKeySession, Integer.toString(randomInt));
	}
	%>
	
	
	<body class="is-preload">
		<div id="page-wrapper">
			<!-- Header -->
			<header id="header">
				<h1 id="logo">통일 알리미</h1>
			</header>
			
			<!-- Security -->
			<input type="hidden" id="RSAModulus" value="${RSAModulus}" />
			<input type="hidden" id="RSAExponent" value="${RSAExponent}" />
			<input type="hidden" id="INTRandom" value="${_INT_WEB_Key_}" />
			
			<!-- Main -->
			<div id="main" class="wrapper style1">
				<div class="container">
					<header class="major">
						<h2>통일 알리미</h2>
						<p>통일 관련 소식을 쉽고 빠르게 볼 수 있습니다.</p>
					</header>
	
					<!-- Table -->
					<section>
						<h3>통일 관련 소식</h3>
						<div class="row gtr-uniform gtr-50">
							<div class="col-12 col-12-xsmall">
								<input type="text" name="name" id="search_txt" value="" placeholder="검색" />
							</div>
							
							<div class="col-4 col-12-medium">
								<input type="radio" id="cbx_new" name="priority" <%out.print(order_by_desc);%>>
								<label for="cbx_new">최신순으로 정렬</label>
							</div>
	
							<div class="col-4 col-12-medium">
								<input type="radio" id="cbx_old" name="priority" <%out.print(order_by_asc);%>>
								<label for="cbx_old">오래된 순으로 정렬</label>
							
							</div>
							
							<ul class="actions">
								<li><a href="javascript:void(0);" onclick="hrefSort('<%=JspPageInfo.GetJspPageURL(request, 0)%>', '<%=parm_name_searchtxt%>', '<%=parm_name_orderby%>', '<%=ParameterManipulation.INTRandomKeyParameter%>')" class="button">검색</a></li>
							</ul>
						</div>
								
						<br></br>
						<br></br>
	
						<div class="table-wrapper">
							<table>
								<thead>
									<tr>
										<th>날자</th>
										<th>내용</th>
										<th></th>
									</tr>
								</thead>
								<tbody>
									<tr>
										<td><%=new SimpleDateFormat("yyyy년 MM월 dd일").format(new Date()).toString()%></td>
										<td><p style="font-weight: bold;">통일 알리미 서비스 시작!</p>통일 알리미 서비스를 이용하시고 있는 여러분 고맙습니다. 업데이트를 통해 더 좋은 서비스를 제공하겠습니다.</td>
										<td></td>
									</tr>
									<!-- List -->
									<%
									// 작업 수행 확인
									if (isTask) {
										// 쿼리 실행 예외 처리
										try {
											// 검색 키워드 확인
											if (search != null) {
												// 쿼리 작성
												sql.append("SELECT * FROM ");
												sql.append(DatabaseInfo.DATABASE_TABLE_NAME_CONTEST_CCTPFU_2021_5TH);
												sql.append(" WHERE ");
												sql.append(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_TITLE);
												sql.append(" LIKE ?");
												sql.append(" ORDER BY ");
												sql.append(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_DATE);
												sql.append(" ");
												sql.append(order_by);
												sql.append(";");
												
												// 쿼리 설정
												StringBuilder sb = new StringBuilder();
												sb.append("%");
												sb.append(search);
												sb.append("%");
												// 리소스 해제
												stat.close();
												stat = cont.GetConnection().prepareStatement(sql.toString());
												
												stat.setString(1, sb.toString());
												sb = null;
											}else {
												// 쿼리 작성
												sql.append("SELECT * FROM ");
												sql.append(DatabaseInfo.DATABASE_TABLE_NAME_CONTEST_CCTPFU_2021_5TH);
												sql.append(" ORDER BY ");
												sql.append(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_DATE);
												sql.append(" ");
												sql.append(order_by);
												sql.append(";");
												// 리소스 해제
												stat.close();
												// 쿼리 설정
												stat = cont.GetConnection().prepareStatement(sql.toString());
											}
											
											// 쿼리 생성 StringBuilder null 처리
											sql = null;
											// 쿼리 실행
											rs = stat.executeQuery();
											// 쿼리 실행 결과
											while(rs.next()) {
												// HTML 코드 삽입
												out.println("<tr>");
												
												out.print("<td>");
												out.print(new SimpleDateFormat("yyyy년 MM월 dd일").format(rs.getDate(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_DATE)));
												out.println("</td>");
												
												out.print("<td><p style=\"font-weight: bold;\">");
												out.print(rs.getString(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_TITLE));
												out.print("</p>");
												if (rs.getString(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_TEXT).length() > 45) {
													out.print(rs.getString(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_TEXT).substring(0, 45));
													out.print("....");
												}else {
													out.print(rs.getString(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_TEXT));
												}
												out.println("</td>");
												
												out.print("<td><ul style=\"min-width: 70px\" class=\"actions\"><li><a href=\"javascript:void(0);\" onclick=\"ShowMessage('");
												out.print(rs.getString(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_ID));
												out.print("', '");
												out.print(JspPageInfo.GetJspPageURL(request, 1));
												out.print("', '");
												out.println("')\" class=\"button primary icon solid fa-plus\"></a></li></ul></td>");
												
												out.println("</tr>");
											}
										}catch (SQLException ex1) {
											// 예외 처리
											rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv4(clientIP, JspPageInfo.ERROR_PAGE_PATH_HTTP_500, ex1.toString()));
											// 닫기
											sql = null;
											rs.close();
											stat.close();
											cont.Close();
											// 페이지 이동
											response.sendRedirect(JspPageInfo.ERROR_PAGE_PATH_HTTP_500);
										}catch (Exception ex2) {
											// 예외 처리
											rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv4(clientIP, JspPageInfo.ERROR_PAGE_PATH_HTTP_500, ex2.toString()));
											// 닫기
											sql = null;
											rs.close();
											stat.close();
											cont.Close();
											// 페이지 이동
											response.sendRedirect(JspPageInfo.ERROR_PAGE_PATH_HTTP_500);
										}finally {
											// 닫기
											sql = null;
											rs.close();
											stat.close();
											cont.Close();
										}
									}else {
										// 닫기
										sql = null;
										rs.close();
										stat.close();
										cont.Close();
									}
									%>
								</tbody>
							</table>
						</div>
					</section>
				</div>
			</div>
		</div>
		
		
		<!-- Footer -->
		<footer id="footer">
			<ul class="copyright">
				<li>Design: HTML5 UP &copy; Untitled. All rights reserved.</li><li>RHYA.Network</li>
			</ul>
		</footer>
		
		
		<script type="text/javascript">
			function hrefSort(url, parm1, parm2, parm3) {
				var rsa = new RSAKey();
				rsa.setPublic(document.getElementById("RSAModulus").value, document.getElementById("RSAExponent").value);
				var cbx_new_id = document.getElementById("cbx_new");
				var input_search_txt = document.getElementById("search_txt");
				var parm1_v;
				var parm2_v;
				
				if (cbx_new_id.checked == true) {
					parm2_v = "DESC";
				}else {
					parm2_v = "ASC";
				}
				
				parm1_v = encodeURI(input_search_txt.value,"UTF-8");
				
				if (input_search_txt.value.replace(' ','') == '') {
					url = url + "?" + parm2 + "=" + rsa.encrypt(parm2_v) + "&" + parm3 + "=" + rsa.encrypt(document.getElementById("INTRandom").value);
				}else {
					url = url + "?" + parm2 + "=" + rsa.encrypt(parm2_v) + "&" + parm1 + "=" + rsa.encrypt(parm1_v) + "&" + parm3 + "=" + rsa.encrypt(document.getElementById("INTRandom").value);
				}
				
				location.href = url;
			}
		</script>
	</body>
</html>