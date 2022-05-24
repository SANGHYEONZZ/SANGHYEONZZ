		/**
		 * 세션 액세스 시간 확인
		 *
		 * 2022.01.16 세션 액세스 시간 확인
		 */
		@ResponseBody
		@RequestMapping(value = "/layout/sessionChk.do", method = RequestMethod.POST)
		public String sessionChk(HttpServletRequest request, HttpSession session, @ModelAttribute("LoginFVo") LoginFVo loginFvo)throws Exception {

			HttpSession ses = request.getSession();

			Map<String, Object> result = new HashMap<String, Object>();

			if(ses.getAttribute("ss_id") != null && ses.getAttribute("ss_level") != null) {

				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				Date lastTime = null;	// 마지막 액세스된 세션 시간
		        Date paramTime = null;	// view에서 전달된 세션 시간
		        Date nowTime = null;	// 현재 시간
		        Calendar cal = null;	// 시간 설정용 변수

		        try {
		        	String lastTimeStr = (String) ses.getAttribute("lastAccessTime");
		        	lastTime = dateFormat.parse(lastTimeStr);
		        	paramTime = dateFormat.parse(loginFvo.getLastAccessTime());
		        	nowTime = new Date();
		        	String nowTimeStr = dateFormat.format(nowTime);
		        	nowTime = dateFormat.parse(nowTimeStr);
				} catch (ParseException e) {
					e.printStackTrace();
				}

		        int compare = lastTime.compareTo(paramTime);

		        // 마지막 엑세스 시간이 이후일 경우
		        if ( compare > 0 ) {
		        	// 마지막 액세스 시간에서 30분을 더한 만료시간을 구함
		        	int remainTime = 0;
		        	int sesTime = 0;

		        	// 세션 설정값이 없을 경우 디폴트 30분 후
		        	if(Globals.SESSION_MAX_TIME.equals("")) {
		        		sesTime = 30;
		        	// 세션 설정값이 있을 경우
		        	} else {
		        		sesTime = Integer.valueOf(Globals.SESSION_MAX_TIME);
		        		sesTime = sesTime/60;
		        	}

		        	cal = Calendar.getInstance();
		        	cal.setTime(lastTime);
		        	cal.add(Calendar.MINUTE, sesTime);
		        	Date suc = null;

		        	// 구해진 만료시간에 현재시간을 빼서 남은 세션 유효시간을 구함
		        	try {
		        		suc = cal.getTime();
		        		remainTime = (int) ((suc.getTime() - nowTime.getTime()) / 1000);
		        	} catch (Exception e) {
		    			e.printStackTrace();
		    		}

		        	// 엑세스 시간으로부터 더해진 시간을 리턴하여 view에서 남은 세션 만료 시간을 갱신하기 위해 리턴함
		        	result.put("remainTime", remainTime); 		// 만료시간 - 현재시간을 보냄
		        	result.put("lastAccessTime", dateFormat.format(lastTime));		// 최근 액세스 타임을 보낸다.
		        	result.put("state", "update");				// view에서 구별할 상태 코드
		        }
		        // 마지막 엑세스 시간과 동일할 경우
		        else if ( compare == 0 ) {
		        	// 액세스 시간과 동일하면 view에서 로그인 연장 확인 팝업을 실행한다.
		        	result.put("remainTime", ses.getMaxInactiveInterval()); // 연장시 타이머 재설정을 위해 세션 설정시간을 보냄
		        	result.put("state", "same");							// view에서 구별할 상태 코드
		        }

			// 세션 정보가 없을 때 상태코드 전달
			} else {
				result.put("state", "NotSes");
			}

	        JSONObject json = new JSONObject(result);

	        return json.toJSONString();
		}

		/**
		 * 세션 연장 처리
		 *
		 * 2022.01.16 세션 연장처리
		 */
		@ResponseBody
		@RequestMapping(value = "/layout/sessionExtension.do", method = RequestMethod.POST)
		public String sessionExtension(HttpServletRequest request, HttpSession session, @ModelAttribute("LoginFVo") LoginFVo loginFvo)throws Exception {

			HttpSession ses = request.getSession();
			String result = null;

			// 세션 정보가 유효할 때 동작
			if(ses.getAttribute("ss_id") != null && ses.getAttribute("ss_level") != null) {
				// 세션 시간 업데이트
				int sesTime = Integer.valueOf(Globals.SESSION_MAX_TIME.equals("") ? "1800" : Globals.SESSION_MAX_TIME);
				ses.setMaxInactiveInterval(sesTime);

				SimpleDateFormat transFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				Date date = null;

				try {
					date = new Date();
					result = transFormat.format(date.getTime());	// 세션을 업데이트 했기 때문에 현재시간을 format
					ses.setAttribute("lastAccessTime", result);		// 세션 lastAccessTime 속성을 format한 현재시간으로 설정
				} catch(Exception e) {
					e.printStackTrace();
				}
			// 세션 정보가 없다면 null 반환
			} else {
				result = "";
			}

			return result;
		}
