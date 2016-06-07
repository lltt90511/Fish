package com.java.platform;

/**
 *应用接入iAppPay云支付平台sdk集成信息 
 */
public class IAppPaySDKConfig{

	/**
	 * 应用名称：
	 * 应用在iAppPay云支付平台注册的名称
	 */
	public final static  String APP_NAME = "海底大捕获";

	/**
	 * 应用编号：
	 * 应用在iAppPay云支付平台的编号，此编号用于应用与iAppPay云支付平台的sdk集成 
	 */
	public final static  String APP_ID = "3005527671";

	/**
	 * 商品编号：
	 * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
	 * 编号对应商品名称为：充值金币
	 */
	public final static  int WARES_ID_1=1;

	/**
	 * 应用私钥：
	 * 用于对商户应用发送到平台的数据进行加密
	 */
	public final static String APPV_KEY = "MIICXQIBAAKBgQDdzzRkoB9XoksR8ADAnTvTB+bEQEGrAbW2IBU8CzhnIu3LvS/xLf345QwN0NU/dHIbrIml5ZO2ZiX93t65X0/dhcqzW9IL+mvUkwn+EHmXzkyAuC+BGQ/3uX7r/8MtGXYD8vR5nyLMiSpaUF0j72/E4g/wYXwJ6G5deQaJqeqjFQIDAQABAoGAbelOIgrCXS97mZDfHpMLYQAKVvcsUyvOukfdndpFgb3qLco6pn1O23XMalAwS3hNTu9Jah5/+qNVch5tKVhUfxmN6846b34X1p7NzryVHQbwI15AWjqVgFpFuuOXkzJXWfduSouHDWWlLHLE298aDj1ALlVcQCM1Spzj60DCCqECQQD2whr01DFdDkPQbu4JifhiUisWdiaxz6ROQzjXQdsOASUh1Rq+AIiKGaBtxiwUnnBPNQWseiDwZHyNXJomvEcNAkEA5h3kbrsWVwXioLikqGF61Bxe7jsKTgcgnWRZ44R5sF9GxYRJ744U8feaMCXjutRAlHnJMzmpmA1NHPW2r7/KKQJAYkJ/G3kXwxd4F5rkvPWs6/IOaF5aIDowEl4gV09JHHWGRMeoY3qw5FU6Fhxw1zEUReY2QS1Myo0pL91tIPmeTQJBAMMkJksgrFkvzHevHTMNNzQYuwgbWSnCMY5HQ1MFTIycv09QV8KmImzvI/ogp3YP+JPwkwa1p3QiE3qzhDCV28ECQQDWoAL8VhqG0GU6lLo0SG/gAVy0tI5T7HIOaZZXD3JTd2g+ZJCdP78j9zXqdV1eOpt3pXhFv1aq1ydZGuRUayrr";

	/**
	 * 平台公钥：
	 * 用于商户应用对接收平台的数据进行解密
	
	 */
	public final static String PLATP_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCBzPdgvljFvz9Xb0knPaML5rYTSCNeyCGAu383BnlYFaAKIPwVEwkgh5KyEJyvPDsEN9eAwu4HfIwd4y6CKlrLLQuiFr4xWM8cXwx7gA/zVmjlgq1eUmNnNvoWVuND58Wst5ZZD3i3RGt8N/4DlfKCmFTKgn7qewg8GNCr8QQ1wwIDAQAB";

}