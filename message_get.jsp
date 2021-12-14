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
<%@ page import="kro.kr.rhya_network.page.JspPageInfo"%>
<%@ page import="kro.kr.rhya_network.logger.RhyaLogger"%>
<%@ page import="kro.kr.rhya_network.logger.GetClientIPAddress"%>
<%@ page import="kro.kr.rhya_network.databses.DatabaseInfo"%>
<%@ page import="kro.kr.rhya_network.databses.DatabaseConnection"%>
<%@ page import="kro.kr.rhya_network.security.RhyaRSA"%>
<%@ page import="kro.kr.rhya_network.security.SelfXSSFilter"%>
<%@ page import="kro.kr.rhya_network.security.ParameterManipulation"%>

<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>

<%
// URL 직접 접근 확인
String strReferer = request.getHeader("referer");
if(strReferer == null) {
	// 리다이렉트
	response.sendRedirect(JspPageInfo.ERROR_PAGE_PATH_HTTP_403);
	return;
}


// Rhya 로거 변수 선언
RhyaLogger rl = new RhyaLogger();
// Rhya 로거 설정
rl.JspName = request.getServletPath();
rl.LogConsole = true;
rl.LogFile = true;

// 클라이언트 아이피
String clientIP = GetClientIPAddress.getClientIp(request);

// 데이터베이스 커넥터 변수 선언
DatabaseConnection cont = null;
// 데이터베이스 쿼리 실행 변수 선언
PreparedStatement stat = null;
ResultSet rs = null;
// 쿼리 작성 StringBuilder
StringBuilder sql = new StringBuilder();
// 파라미터 이름 선언
final String parm_name_id = "id";
// Split 텍스트 문자
final String split_txt = "<#SPLIT#>";

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
	rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv5(clientIP, ex1.toString()));
	// 연결 종료
	cont = null;
	rl = null;
	sql = null;
	out.println(JspPageInfo.GetAjaxResult(new String[] { "오류 발생", "데이터베이스 접속 중 오류 발생!", "error" }, split_txt));
	
	return;
}catch (ClassNotFoundException ex2) {
	// 데이터베이스 접속 오류 처리
	rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv5(clientIP, ex2.toString()));
	// 연결 종료
	cont = null;
	rl = null;
	sql = null;
	out.println(JspPageInfo.GetAjaxResult(new String[] { "오류 발생", "데이터베이스 접속 중 오류 발생!", "error" }, split_txt));
	
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
	stat.setInt(1, JspPageInfo.PageID_2021_5th_Coding_Competition_to_Prepare_for_Unification_GetMessage);
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
		rl = null;
		sql = null;
		
		// 페이지 이동
		response.sendRedirect(JspPageInfo.ERROR_PAGE_PATH_HTTP_403);
	}
	
	// 파라미터 가지고 오기
	String uuid = request.getParameter(parm_name_id);
	String key = request.getParameter(ParameterManipulation.INTRandomKeyParameter);
	
	// 입력 값 Null 확인
	if ((uuid != null) && (key != null)) {
		// 예외 처리
		try {
			// 세션 데이터 가지고 오기
	        PrivateKey privateKey = (PrivateKey) session.getAttribute(ParameterManipulation.RSAPrivateKeySession);
			String int_random_key_org = (String) session.getAttribute(ParameterManipulation.INTRandomKeySession);
			// 데이터 복호화
			uuid = RhyaRSA.decryptRsa(privateKey, uuid);
			key = RhyaRSA.decryptRsa(privateKey, key);
			// XSS 필터링
			uuid = SelfXSSFilter.TextXSSFilter(uuid);
			key = SelfXSSFilter.TextXSSFilter(key);
			// 로그 작성
			rl.Log(RhyaLogger.Type.Info, rl.CreateLogTextv1(clientIP, new String[] { parm_name_id, ParameterManipulation.INTRandomKeyParameter }, new String[] { uuid, key }));
			
			// 정수형 인증키 비교
			if (int_random_key_org.equals(key)) {
				// 쿼리 생성
				sql.append("SELECT * FROM ");
				sql.append(DatabaseInfo.DATABASE_TABLE_NAME_CONTEST_CCTPFU_2021_5TH);
				sql.append(" WHERE ");
				sql.append(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_ID);
				sql.append("=");
				sql.append("?;");
				
				// 쿼리 설정
				stat.close();
				stat = cont.GetConnection().prepareStatement(sql.toString());
				stat.setString(1, uuid);
				// 쿼리 실행
				rs = stat.executeQuery();
				// 쿼리 실행 결과
				if (rs.next()) {
					// 결과 처리
					out.println(JspPageInfo.GetAjaxResult(new String[] { rs.getString(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_TITLE), rs.getString(DatabaseInfo.DATABASE_TABLE_COLUMN_CONTEST_CCTPFU_2021_5TH_CONTENT_TEXT), "info" }, split_txt));
				}
			}else {
				// 정수형 인증키 불일치
				rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv3(clientIP));
				out.println(JspPageInfo.GetAjaxResult(new String[] { "오류 발생", "인증키가 일치하지 않습니다.", "error" }, split_txt));
			}
		}catch (Exception ex) {
			// 오류 처리
			rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv5(clientIP, ex.toString()));
			out.println(JspPageInfo.GetAjaxResult(new String[] { "오류 발생", "알 수 없는 오류!", "error" }, split_txt));
		}finally {
			// 연결 종료
			rs.close();
			stat.close();
			cont.Close();
			rl = null;
			sql = null;
		}
	}else {
		// 파라미터 값 Null
		rl.Log(RhyaLogger.Type.Error, rl.CreateLogTextv7(clientIP));
		out.println(JspPageInfo.GetAjaxResult(new String[] { "오류 발생", "잘못된 인자 값입니다.", "error" }, split_txt));
		// 연결 종료
		rs.close();
		stat.close();
		cont.Close();
		rl = null;
		sql = null;
	}
}
%>