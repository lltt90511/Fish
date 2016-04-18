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
 * File: DateUtil.java
 * Date锛?2014骞?1???2???
 * Version锛?v1.0
 */	
package com.opensource.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * 浣????锛???堕?存??浣?宸ュ?风被
 * @author yinglovezhuzhu@gmail.com
 */
public class DateUtil {
	private DateUtil() {}
	
	/**
	 * ??峰??绯荤??褰??????ユ??
	 * @param pattern ??ユ????煎??
	 * @return
	 */
	public static String getSystemDate(String pattern) {
		SimpleDateFormat dateFormat = new SimpleDateFormat(pattern, Locale.getDefault());
		return dateFormat.format(new Date(System.currentTimeMillis()));
	}
	
	/**
	 * ??峰??褰????骞翠唤
	 * @return 褰?骞村勾浠?
	 */
	public static int getYear() {
		Calendar c = Calendar.getInstance(Locale.getDefault());
		return c.get(Calendar.YEAR);
	}
	
	/**
	 * ??峰?????
	 * @param timeSecond ??堕?达??绮剧‘??拌豹绉?
	 * @return
	 */
	public static int getDay(long milliseconds) {
		SimpleDateFormat dateFormat = new SimpleDateFormat("d", Locale.getDefault());
		String day = dateFormat.format(new Date(milliseconds));
		try {
			return Integer.valueOf(day);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}
	
	/**
	 * The seconds1 is the same day with seconds2.(绮剧‘??扮??)
	 * @param seconds1
	 * @param seconds2
	 * @return
	 */
	public static boolean isSameDay(long seconds1, long seconds2) {
		return Math.abs(seconds1 - seconds2) < 86400;
	}
	
	/**
	 * ??峰????????骞翠唤??????澶?涓?骞翠唤
	 * @param backStep ????????ㄧЩ???骞翠唤???
	 * @param minYear ???灏?骞翠唤锛?濡????????????ㄧЩ灏?浜?杩?涓????灏?骞翠唤锛??????拌??涓????灏?骞翠唤涓烘??
	 * @return
	 */
	public static List<Integer> getYears(int backStep, int minYear) {
		List<Integer> years = new ArrayList<Integer>();
		int year = getYear();
		for (int i = 0; i < backStep; i++) {
			if(year - i < minYear) {
				break;
			}
			years.add(year - i);
		}
		return years;
	}
	
	/**
	 * ??峰????ㄦ?ユ?ユ??
	 * @param pattern
	 * @return
	 */
	public static String getYesterdayDate(String pattern) {
		SimpleDateFormat dateFormat = new SimpleDateFormat(pattern, Locale.getDefault());
		Calendar calendar = Calendar.getInstance(Locale.getDefault());
		calendar.set(Calendar.DAY_OF_MONTH, calendar.get(Calendar.DAY_OF_MONTH) - 1);
		return dateFormat.format(calendar.getTime());
	}
	
	/**
	 * 杞???㈡?堕?存?煎??锛?浠?srcPattern??煎??杞???㈡??distPattern
	 * 璇存??锛?杞???㈠?????????????堕?寸簿搴??????????锛??????????楂?绮惧害???浣?绮惧害???杞????锛?涓???????浣?绮惧害??抽??绮惧害??堕?磋浆???锛?????????峰?????缁????灏?浼???洪??璇????
	 * 渚?濡?锛???堕?存?煎??涓衡??骞存????ユ?跺??绉????锛???借浆??㈡??浠讳??涓?绉?姣?瀹?绮惧害浣??????煎??濡?????????ユ?跺????????????????ユ?跺??绉????锛?浣??????存??娉????????????ユ?跺???????煎????堕??
	 * 杞???㈡?????骞存????ユ?跺??绉????绛?绮惧害姣?瀹?楂??????煎?????
	 * @param source
	 * @param srcPattern
	 * @param distPattern
	 * @return 杞???㈡?????杩??????版?煎???????堕?达??濡????杞???㈠?????寮?甯稿??杩?????????ユ?煎????堕??
	 */
	public static String changeFormat(String source, String srcPattern, String distPattern) {
		SimpleDateFormat srcFormt = new SimpleDateFormat(srcPattern, Locale.getDefault());
		SimpleDateFormat distFormt = new SimpleDateFormat(distPattern, Locale.getDefault());
		try {
			return distFormt.format(srcFormt.parse(source));
		} catch (ParseException e) {
			e.printStackTrace();
			return source;
		}
	}
	
	/**
	 * Format date.
	 * @param pattern
	 * @param milliseconds
	 * @return
	 */
	public static String format(String pattern, long milliseconds) {
		SimpleDateFormat dateFormat = new SimpleDateFormat(pattern, Locale.getDefault());
		try {
			return dateFormat.format(new Date(milliseconds));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}
}
