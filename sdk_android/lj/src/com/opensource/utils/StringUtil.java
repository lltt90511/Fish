/*
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Auther锛?yinglovezhuzhu@gmail.com
 * File: StringUtil.java
 * Date锛?2014骞?1???2???
 * Version锛?v1.0
 */	
package com.opensource.utils;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 浣????锛?
 * @author yinglovezhuzhu@gmail.com
 */
public class StringUtil {
	
	private StringUtil() {}
	
	public static boolean isEmpty(String str) {
		return str == null || "".equals(str.trim());
	}
	
	/**
	 * ?????ゆ????????startStr???endStr涔???寸??瀛?绗?涓诧????????startStr???endStr,??冲????ら????洪?达蓟startStr锛?endStr锛?
	 * @param sb
	 * @param startStr
	 * @param endStr
	 */
	public static void deleteAllIn(StringBuilder sb, String startStr, String endStr) {
		int startIndex = 0;
		int endIndex = 0;
		while((startIndex = sb.indexOf(startStr)) >= 0 && (endIndex = sb.indexOf(endStr)) >= 0) {
			sb.delete(startIndex, endIndex + endStr.length());
		}
	}
	
	/**
	 * ??规????稿?癸??缁?瀵硅矾寰???峰?????浠跺??
	 * @param path
	 * @return
	 */
	public static String getFileName(String path) {
		return path.substring(path.lastIndexOf("/") + 1, path.length());
	}
	
	/**
	 * ??峰??瀛?绗?涓蹭袱涓?瀛?绗?涓蹭????寸??瀛?绗?锛?绗?涓?涓?锛?
	 * @param source
	 * @param start
	 * @param end
	 * @return
	 */
	public static String getStringIn(String source, String start, String end) {
		return source.substring(source.indexOf(start) + start.length(), source.indexOf(end));
	}
	
	/**
	 * Whether the input is valid mobile phone number or not.
	 * @param phone
	 * @return
	 */
	public static boolean isValidPhoneNumber(String phone) {
		if(StringUtil.isEmpty(phone)) {
			return false;
		}
		String p = "1[358][0-9]{9}";
		Pattern pattern = Pattern.compile(p, Pattern.MULTILINE|Pattern.COMMENTS);
		Matcher m = pattern.matcher(phone);
		return m.find();
	}
}
