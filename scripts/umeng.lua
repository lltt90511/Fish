--友盟统计
payOrderId = nil
-- 充值
	-- _cash 真实币数量
	-- _source 支付渠道 1(App Store) 2(支付宝) 3(网银) 4(财付通) 5(移动通信) 6(联通通信) 7(电信通信) 8(paypal)
	-- _coin  游戏币数量
function umengPay(_cash, _source, _coin)
	print("umengPay", _cash, _source, _coin)
	luaoc.callStaticMethod("umeng","umengPay",{cash=tostring(_cash),source=tostring(_source),coin=tostring(_coin)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengPay",{tostring(_cash),tostring(_source),tostring(_coin)})
	umengChargeSuccess()
end

-- 购买
	-- _item 道具名称
	-- _amount 道具数量
	-- _price 道具价格
function umengBuy(_item, _amount, _price)
	print("umengBuy", _item, _amount, _price)
	luaoc.callStaticMethod("umeng","umengBuy",{item=tostring(_item),amount=tostring(_amount),price=tostring(_price)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengBuy",{tostring(_item),tostring(_amount),tostring(_price)})
end

-- 充值请求
	-- _orderId 订单号
	-- _productId 产品id
	-- _price 真钱
	-- _amount 虚拟币
	-- _type 支付类型
function umengChargeRequest(_orderId, _productId, _price, _amount, _payType)
	print("umengChargeRequest", _orderId, _productId, _price, _amount, _payType)
	payOrderId = _orderId
	luaoc.callStaticMethod("umeng","umengChargeRequest",{orderId=tostring(_orderId),productId=tostring(_productId),price=tostring(_price),amount=tostring(_amount),payType=tostring(_payType)})
end

-- 充值成功
function umengChargeSuccess()
	print("umengChargeSuccess", payOrderId)
	if payOrderId ~= nil then
		luaoc.callStaticMethod("umeng","umengChargeSuccess",{orderId=tostring(payOrderId)})
	end
	payOrderId = nil
end

-- 版本号
function umengVersion(_version)
	print("umengVersion", _version)
	luaoc.callStaticMethod("umeng","umengVersion",{version=tostring(_version)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengVersion",{tostring(_version)})
end

-- 关卡耗时 startLevel开始记录，调用finishLevel或failLevel，结束记录，finishLevel和failLevel参数为nil时，为startLevel的传入level
-- 开始
function umengStartLevel(_level)
	if _level == nil then
		_level = ""
	end
	print("umengStartLevel", _level)
	luaoc.callStaticMethod("umeng","umengStartLevel",{level=tostring(_level)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengStartLevel",{tostring(_level)})
end

-- 结束
function umengFinishLevel(_level)
	if _level == nil then
		_level = ""
	end
	print("umengFinishLevel", _level)
	luaoc.callStaticMethod("umeng","umengFinishLevel",{level=tostring(_level)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengFinishLevel",{tostring(_level)})
end

-- 失败
function umengFailLevel(_level)
	if _level == nil then
		_level = ""
	end
	print("umengFailLevel", _level)
	luaoc.callStaticMethod("umeng","umengFailLevel",{level=tostring(_level)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengFailLevel",{tostring(_level)})
end

function umengStartTask(_task, _type)
	print("umengStartTask", _task, _type)
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengStartTask",{tostring(_task), tostring(_type)})
end

function umengFinishTask(_task)
	print("umengFinishTask", _task)
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengFinishTask",{tostring(_task)})
end

function umengFailTask(_task, _reason)
	print("umengFailTask", _task, _reason)
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengFailTask",{tostring(_task), tostring(_reason)})
end

-- 使用道具
	-- _item 道具名称
	-- _amount 道具数量
	-- _price 道具价格
function umengUse(_item, _amount, _price)
	print("umengUse", _item, _amount, _price)
	luaoc.callStaticMethod("umeng","umengUse",{item=tostring(_item),amount=tostring(_amount),price=tostring(_price)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengUse",{tostring(_item),tostring(_amount),tostring(_price)})
end

-- 额外奖励，如系统赠送，节日奖励，打怪掉落等
	-- _coin 游戏币数量
	-- _source 奖励渠道(1~10，1已被预定义为系统奖励，其他自定义)
-- 奖励游戏币
function umengBonusCoin(_coin, _source)
	print("umengBonusCoin", _coin, _source)
	luaoc.callStaticMethod("umeng","umengBonusCoin",{coin=tostring(_coin),source=tostring(_source)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengBonusCoin",{tostring(_coin),tostring(_source)})
end

-- 奖励道具
function umengBonusItem(_item, _amount, _price, _source)
	print("umengBonusItem", _item, _amount, _price, _source)
	luaoc.callStaticMethod("umeng","umengBonusItem",{item=tostring(_item),amount=tostring(_amount),price=tostring(_price),source=tostring(_source)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengBonusItem",{tostring(_item),tostring(_amount),tostring(_price),tostring(_source)})
end

-- 玩家等级
function umengUserLevel(_level)
	print("umengUserLevel", _level)
	luaoc.callStaticMethod("umeng","umengUserLevel",{level=tostring(_level)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengUserLevel",{tonumber(_level)})
end

-- 玩家信息
function umengUserInfo(_userId, _sex, _age, _platform)
	print("umengUserInfo", _userId, _sex, _age, _platform)
	luaoc.callStaticMethod("umeng","umengUserInfo",{userId=tostring(_userId),sex=tostring(_sex),age=tostring(_age),platform=tostring(_platform)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengUserInfo",{tostring(_userId),tostring(_sex),tostring(_age),tostring(_platform)})
end

function umengUserInfo2(_userId, _age, _sex, _source, _level, _server, _comment)
	print("umengUserInfo2", _userId, _age, _sex, _source, _level, _server, _comment)
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengUserInfo2",{tostring(_userId),tostring(_age),tostring(_sex),"qihoo360",tostring(_lv),tostring(_server),""})
end

function umengUserInfo3(_userId, _userName, _sex)
	print("umengUserInfo3", _userId, _userName)
	luaoc.callStaticMethod("umeng","umengUserInfo3",{userId=tostring(_userId),userName=tostring(_userName),sex=tostring(_sex)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengUserInfo3",{tostring(_userId),tostring(_userName),tostring(_sex)})
end

function umengUserName(_userName)
	print("umengUserName", _userName)
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengUserName",{_userName})
end

-- 自定义事件
	-- _eventId 事件id
function umengEvent(_eventId)
	print("umengEvent", _eventId)
	luaoc.callStaticMethod("umeng","umengEvent",{eventId=tostring(_eventId)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengEvent",{tostring(_eventId)})
end

function umengEventLB(_eventId, _eventLabel)
	print("umengEventLB", _eventId, _eventLabel)
	luaoc.callStaticMethod("umeng","umengEventLB",{eventId=tostring(_eventId),eventLabel=tostring(_eventLabel)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengEventLB",{tostring(_eventId),tostring(_eventLabel)})
end

-- 自定义事件统计
-- 开始
function umengEventBegin(_eventId)
	print("umengEventBegin", _eventId)
	luaoc.callStaticMethod("umeng","umengEventBegin",{eventId=tostring(_eventId)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengEventBegin",{tostring(_eventId)})
end

-- 结束
function umengEventEnd(_eventId)
	print("umengEventEnd", _eventId)
	luaoc.callStaticMethod("umeng","umengEventEnd",{eventId=tostring(_eventId)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengEventEnd",tostring(_eventId))
end

-- 自己上传时长
	-- _eventId 事件id
	-- _millisecond 毫秒
function umengEventDurations(_eventId, _millisecond)
	print("umengEventDurations", _eventId, _millisecond)
	luaoc.callStaticMethod("umeng","umengEventDurations",{eventId=tostring(_eventId),millisecond=tostring(_millisecond)})
	luaj.callStaticMethod("cc/yongdream/nshx/umeng","umengEventDurations",{tostring(_eventId),tostring(_millisecond)})
end