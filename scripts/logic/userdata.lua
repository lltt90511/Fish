module("logic.userdata", package.seeall)

UserInfo = nil
CharIdToImageFile = {}
goldAction = false
isLottery = false
goldPos = {x=0,y=0}

deviceId = nil --设备id
sdkplatform = ""
messageId = nil --推送收到的消息id
messageType = nil
appInfo = {}

isFirstGame = 1  	 	 --是否没有点击下注按钮 0否 1是
isInGame = false 		 --是否是在抽奖或者是游戏进行中，当为false的时候跑道上才会有消息
lastFruitSingleIndex = 0 --上一次水果机单注金额
lastFruitSingleType = "" --上一次水果机下注内容,可能有多个内容，因此是一个字符串
userFruitHistoryGold = "" --用户在水果机中的中奖纪录,可能有多个内容，因此是一个字符串,一共有5条纪录
lastFishSingleIndexSmall = 0  --上一次海底世界小场单注金额
lastFishSingleIndexBig = 0  --上一次海底世界大场单注金额
lastFishSingleIndex = {} --上一次海底世界所有场单注金额
lastFishSingleType = {} --上一次海底世界所有场下注内容,可能有多个内容，因此是一个字符串数组
lastFishSingleTypeSmall = ""  --上一次海底世界小场下注内容,可能有多个内容，因此是一个字符串
lastFishSingleTypeBig = ""  --上一次海底世界大场下注内容,可能有多个内容，因此是一个字符串
userFishHistoryGold = "" --用户在海底世界中的中奖纪录,可能有多个内容，因此是一个字符串，一共有5条纪录
