package com.java.platform;

/**
 *应用接入iAppPay云支付平台sdk集成信息 
 */
public class IAppPaySDKConfig{

	/**
	 * 应用名称：
	 * 应用在iAppPay云支付平台注册的名称
	 */
	public final static  String APP_NAME = "富豪水果机CQ";

	/**
	 * 应用编号：
	 * 应用在iAppPay云支付平台的编号，此编号用于应用与iAppPay云支付平台的sdk集成 
	 */
	public final static  String APP_ID = "3004116435";

	/**
	 * 商品编号：
	 * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
	 * 编号对应商品名称为：10元超值大礼包
	 */
	public final static  int WARES_ID_1=1;

	/**
	 * 商品编号：
	 * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
	 * 编号对应商品名称为：500万金币
	 */
	public final static  int WARES_ID_2=2;

	/**
	 * 商品编号：
	 * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
	 * 编号对应商品名称为：300万金币
	 */
	public final static  int WARES_ID_3=3;

	/**
	 * 商品编号：
	 * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
	 * 编号对应商品名称为：100万金币
	 */
	public final static  int WARES_ID_4=4;

	/**
	 * 商品编号：
	 * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
	 * 编号对应商品名称为：50万金币
	 */
	public final static  int WARES_ID_5=5;

	/**
	 * 商品编号：
	 * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
	 * 编号对应商品名称为：30万金币
	 */
	public final static  int WARES_ID_6=6;

	/**
	 * 商品编号：
	 * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
	 * 编号对应商品名称为：10万金币
	 */
	public final static  int WARES_ID_7=7;

	/**
	 * 应用私钥：
	 * 用于对商户应用发送到平台的数据进行加密
	 */
	public final static String APPV_KEY = "MIICWwIBAAKBgQCE2osLKwZGQbcLp5EJAAkwl1SJlYzAkCV4J0P42pmHEI96fZv7gTx/M/kUOtdBC5Di18rX58yfN2K0QNv0YGBxYzCHzBtN2/NAbAk+beugkLGU2UMwDPRj9kTRVZl/oEj0PyRvhBXIyPnf0vsE1+wE9dUCFsMYUg/2E/NSKF8LuQIDAQABAoGAAO63wyBOLvgPHNnUPsftSJYHVd/i2Qcp/CnqZDjEkxoep7FyAtXpYssumGHBWQeHwM/a8KED4qo02ycJZDG4+5AhvjGzaB+f7FhrOSXR1pXqOozBF2P4OYsiD4UB7TvyeAhU6wTb0LGICEB+8g0tiI4DZEEz+fMS4KkqQKyuvsECQQDbrTRsWR8kdfPkdmN75Ux+8Dcqf2Ert5hvuinJ2xLYEtWGh6BhEVUU2xjr9iNXzBaR/peXCilmfNs8mpu6Idp1AkEAmtIrnTKymExXeDsqgQ8B12yEF5c0sHpIizbQIlAZX8AmESCCdggKU/6eifhVMDd0NR6dXjPW9j6pSXtOZahbtQJAQGTuaBBb46k73C2kDe5yVQd/dFKwnksMQTwWAdjZFkO3Gd9p8OpOwXVUQd7+Dz+BIjy6HQlah3N0JLjBi3de/QJAA67SOMgW9YaDYinOJgnMWmqLbeA78aLHDQC9zMMpB10Tyr6CO/qO/FaHQPL2W9JF4mmbBr2m9G6jKktTnxl1LQJAMcNRaN46N44qkc91gGHIePiRhgIzd6ikroCY1vez6q3khBma4vFXBXe+YfrxbznMmvFEFxi8bKNnCUA6vO3yCQ==";

	/**
	 * 平台公钥：
	 * 用于商户应用对接收平台的数据进行解密
	 */
	public final static String PLATP_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCQlnTYJjxiKTIfnmCASxLF5G5qq1zBlLFu3TmmfEBgSQA2jH7lYxNiOy542wocVoagoQaDC02bc/EkEXXx2DEe+griOsZW7SCzVl80QRoS2ohIq4yJ+Zhmg+Djq4Ot7yYZy74icRZtN/TBeBbzLa1ZBYNLUBBO4Lbf43bCPeARtQIDAQAB";

}