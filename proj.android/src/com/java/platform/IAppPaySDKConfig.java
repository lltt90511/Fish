package com.java.platform;

/**
 *应用接入iAppPay云支付平台sdk集成信息 
 */
public class IAppPaySDKConfig{

	/**
	 * 应用名称：
	 * 应用在iAppPay云支付平台注册的名称
	 */
	public final static  String APP_NAME = "海底大冒险";

	/**
	 * 应用编号：
	 * 应用在iAppPay云支付平台的编号，此编号用于应用与iAppPay云支付平台的sdk集成 
	 */
	public final static  String APP_ID = "3005160435";

	/**
	 * 商品编号：
	 * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
	 * 编号对应商品名称为：金币
	 */
	public final static  int WARES_ID_1=1;

	/**
	 * 应用私钥：
	 * 用于对商户应用发送到平台的数据进行加密
	 */
	public final static String APPV_KEY = "MIICXgIBAAKBgQDYwLDEiQusmAgbchEmJ08xq3x4F8TWpRWBjuALqVFd942UEsAC71gowAkJlc3UVatf+xbZxXbbc1ZE7WSqbfoqeLWdZlPEBESNrgM7jL+b3KgMNRHdQ82ykXkTet05zapWVt5Ahj2T9OtIzLYQVKermLsP7ONA3AcgV6AKN1YpowIDAQABAoGBAKhM3jSMkQL/vXPKGyS76xMPK4N4OT/NSSijDrYfT22eFVF/SZY9z/88NQg7SGnx5zKMnU6Us9hr8vVsOvjWkiJP2KaYinMXJirFc+PlcEv4NrvaRbakeHQal6jiZlNkOz4lDlSirm2tzjLGqOyszqq5G7+d5gm+kJCzu8w1SysRAkEA+Tz7odZOerGQ5rGMJvbJ42J+4wggqs77enB6H+WzPrqecITPPt5NLkibOx9ntI6qLixySbi5OqPVcyRfMeBEGwJBAN6iFo+BhVNv2mALX6Ih5dFGDgWwPrt1z3VujhDnL9C117kM0hScjeT/JoD0DEVYny1Cj+zg5DQNjAoOJhkouRkCQQDjfSAIRX14S56AkknkPpljbEF4o7B9d1LeHM+7UYNbnCaFeRNYxLsZpbfaLP4RNa5rWrIuS+b1eRiYcfhZo+NFAkBi/KiRR+JS1dG/kG8F9JJtOPu1FcberKQAL5ak91WwM5nl4khp962zWqrw/RGTp7KmegjqJpfwePGB6waPeybJAkEA5SvTo5UnE6kKKHHAnPx+Ts9VkhW0GmChB+PTq62x790JR540atk9wMeDKWd3eYQpKQa38P/2kZdfDl87iV6aMQ==";

	/**
	 * 平台公钥：
	 * 用于商户应用对接收平台的数据进行解密
	 */
	public final static String PLATP_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCHpAacBdz7Tl+8u1+7gZ0f/vtinmwYpEb9vxd/+bTqUbXgWr3HCnEXzW/nCgtFq7eG8YA2GraA6ry7CODU9LMGbQ7bwAINez2higWyOhcaXW7xDdWVZy3tcS6jcnQ0/WrdjynFD7+CLJSKgmGJbaAeXT0uN/jdL7JpN8sYtHNC7QIDAQAB";

}