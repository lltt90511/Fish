local classic = require("template.data.classic")
local classicType = require("template.data.classicType")
local vipExp = require("template.data.vipExp")
local quest = require("template.data.quest")
local questCountType = require("template.data.questCountType")
local chargeGift = require("template.data.chargeGift")
local dailyGift = require("template.data.dailyGift")
local charge = require("template.data.charge")
local random = require("template.data.random")
local freeGold = require("template.data.freeGold")
local activity = require("template.data.activity")
local tips = require("template.data.tips")
module("template.data.gametemplate")
gameTemplate = {}
gameTemplate["classic"] =classic.data
gameTemplate["classicType"] =classicType.data
gameTemplate["vipExp"] =vipExp.data
gameTemplate["quest"] =quest.data
gameTemplate["questCountType"] =questCountType.data
gameTemplate["chargeGift"] =chargeGift.data
gameTemplate["dailyGift"] =dailyGift.data
gameTemplate["charge"] =charge.data
gameTemplate["random"] =random.data
gameTemplate["freeGold"] =freeGold.data
gameTemplate["activity"] =activity.data
gameTemplate["tips"] =tips.data
return gameTemplate
