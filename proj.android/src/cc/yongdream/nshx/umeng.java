package cc.yongdream.nshx;

import com.umeng.analytics.game.UMGameAgent;

public class umeng {

	public static void umengPay(String cash, String source, String coin) {
		UMGameAgent.pay(Double.valueOf(cash), Double.valueOf(coin), Integer.parseInt(source));
	}
	
	public static void umengBuy(String item, String amount, String price) {
		UMGameAgent.buy(item, Integer.parseInt(amount), Double.valueOf(price));
	}
	
	public static void umengVersion(String version) {
		
	}
	
	public static void umengStartLevel(String level) {
		UMGameAgent.startLevel(level);
	}
	
	public static void umengFinishLevel(String level) {
		if ("".equals(level))
			UMGameAgent.finishLevel(null);
		else
			UMGameAgent.finishLevel(level);
	}
	
	public static void umengFailLevel(String level) {
		if ("".equals(level))
			UMGameAgent.failLevel(null);
		else
			UMGameAgent.failLevel(level);
	}
	
	public static void umengUse(String item, String amount, String price) {
		UMGameAgent.use(item, Integer.parseInt(amount), Double.valueOf(price));
	}
	
	public static void umengBonusCoin(String coin, String source) {
		UMGameAgent.bonus(Double.valueOf(coin), Integer.parseInt(source));
	}
	
	public static void umengBonusItem(String item, String amount, String price, String source) {
		UMGameAgent.bonus(item, Integer.parseInt(amount), Double.valueOf(price), Integer.parseInt(source));
	}
	
	public static void umengUserLevel(String level) {
		UMGameAgent.setPlayerLevel(level);
	}
	
	public static void umengUserInfo(String userId, String sex, String age, String platform) {
		UMGameAgent.setPlayerInfo(userId, Integer.parseInt(sex), Integer.parseInt(age), platform);
	}

	public static void umengUserInfo2(String userId, String age, String sex, String source, String level, String server, String comment) {
		
	}

	public static void umengUserInfo3(String userId, String userName) {
		
	}
	
	public static void umengEvent(String eventId) {
		UMGameAgent.onEvent(mainActivity.main, eventId);
	}
	
	public static void umengEventLB(String eventId, String eventLabel) {
		UMGameAgent.onEvent(mainActivity.main, eventId, eventLabel);
	}
	
	public static void umengEventBegin(String eventId) {
		UMGameAgent.onEventBegin(mainActivity.main, eventId);
	}
	
	public static void umengEventEnd(String eventId) {
		UMGameAgent.onEventEnd(mainActivity.main, eventId);
	}
	
	public static void umengEventDurations(String eventId, String millisecond) {
		UMGameAgent.onEventDuration(mainActivity.main, eventId, Long.valueOf(millisecond));
	}
}
