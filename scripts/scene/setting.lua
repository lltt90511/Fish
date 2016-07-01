local tool = require"logic.tool"
local event = require"logic.event"
local fruitMachine = require"scene.fruitMachine.main"
local fishMachine = require"scene.fishMachine.main"
local scaleList = require"widget.scaleList"
local userdata = require"logic.userdata"
local countLv = require "logic.countLv"
module("scene.setting", package.seeall)

this = nil
subWidget = nil
 boxList ={}
 Setting = {
   music ={percent = "musicPercent",open = "musicOpen"},
   effect ={percent = "effectPercent",open = "effectOpen"},
   -- zhengdong ={open = "zhengdongOpen"},
   light ={open = "lightOpen"},
   -- push ={open = "pushOpen"},
}
SettingObjList = {}
function create(parent)
  this = tool.loadWidget("cash/setting",widget,parent,99)
  SettingObjList = {
    music = widget.panel.bg.music.check.obj,
    effect = widget.panel.bg.effect.check.obj,
    -- zhengdong = widget.panel.bg.zhengdong.check.obj,
    light = widget.panel.bg.light.check.obj,
    -- push = widget.panel.bg.push.check.obj,
  }
  widget.panel.bg.zhengdong.check.obj:setTouchEnabled(false)
  widget.panel.bg.push.check.obj:setTouchEnabled(false)
  initSettingStatus()
   return this
end
function initSettingStatus()
  print("initSettingStatus!!!!!!!!!!!")
  printTable(UserSetting)
  for i,v in pairs(SettingObjList) do
    print (i)
      local tmp = Setting[i]
      if tmp and tmp.percent then
         if not UserSetting[tmp.percent] then
            saveSetting(tmp.percent,50)
         end
      end
      if tmp and tmp.open then
         if not UserSetting[tmp.open] then
            saveSetting(tmp.open,1)
            v:setSelectedState(true)
         else 
            v:setSelectedState(tonumber(UserSetting[tmp.open]) == 1)
         end
      end
      -- if Setting[i] and Setting[i].open then
      --     v:setSelectedState(true)
      -- else
      --     v:setSelectedState(false)
      -- end
  end
  setBackgrdoundMusic(UserSetting[Setting.music.percent])
  setEffectMusic(UserSetting[Setting.effect.percent])
end
function exit()
  if this then
      event.pushEvent("ON_BACK")
      this:removeFromParentAndCleanup(true)
      tool.cleanWidgetRef(widget)
      this = nil
  end
end
function onBack(event)
  if event == "releaseUp" then
     tool.buttonSound("releaseUp","effect_12")
     exit()
  end
end

function setBackgrdoundMusic(percent)
  print("setBackgrdoundMusic",percent/100,Setting.music.percent)
  saveSetting(Setting.music.percent,percent)
  widget.panel.bg.bottom.music.slider.obj:setPercent(percent)
end

function setEffectMusic(percent)
  print("setEffectMusic",percent/100,Setting.effect.percent)
  saveSetting(Setting.effect.percent,percent)
   widget.panel.bg.bottom.effect.slider.obj:setPercent(percent)
end

function onBackgroundMusic(event)
  print("onBackgroundMusic----")
  if event == "releaseUp" then
    local music = widget.panel.bg.bottom.music.slider.obj:getPercent()
    print("onBackgroundMusic",music)
     UserSetting[Setting.music.percent] = music
    setBackgrdoundMusic(music)
    AudioEngine.setMusicVolume(music/100)
    -- saveSetting(Setting.music.percent,music/100)
    musicVolume = music/100
    if musicVolume == 0 then
      AudioEngine.stopMusic()
      MusicOnce = true
    else
      if MusicOnce then
        AudioEngine.playMusic("bgm01.mp3",true)
        MusicOnce = false
      end
    end
    -- Setting.music.percent = music
  end
end

function onMusic(event)
  print("onMusic----")
  if event == "releaseUp" then
    local music =widget.panel.bg.bottom.effect.slider.obj:getPercent()
    print("onMusic",music)
     UserSetting[Setting.effect.print] = music
    setEffectMusic(music)
    AudioEngine.setEffectsVolume(music/100)
    saveSetting(Setting.effect.percent,music/100)
    effectVolume = music/100
    -- Setting.effect.percent = music
  end
end
function onCloseMusic(event,data1,data)
  if event == "releaseUp" then
    tool.buttonSound("releaseUp","effect_12")
    data = tolua.cast(data,"CheckBox")
    local check = data:getSelectedState()
    check = not check
     local c = 0
     if check == true then
        c = 1
        UserSetting[Setting.music.open] = c
        AudioEngine.playMusic("bgm01.mp3",true)
     else
        UserSetting[Setting.music.open] = c
        AudioEngine.stopMusic()
     end

     -- AudioEngine.switchMusic(check)
     -- print("onCloseMusic",Setting.music.open)
     saveSetting(Setting.music.open,c)
  end
end
function onCloseEffect(event,data1,data)
  if event == "releaseUp" then
    tool.buttonSound("releaseUp","effect_12")
    data = tolua.cast(data,"CheckBox")
    local check = data:getSelectedState()
    check = not check
     local c = 0
     if check == true then
        c = 1
     end
     UserSetting[Setting.effect.open] = c
     saveSetting(Setting.effect.open,c)
     AudioEngine.switchEffect(check)

  end
end
function onZhengdong(event,data1,data)
  if event == "releaseUp" then
    --   tool.buttonSound("releaseUp","effect_12")
    -- data = tolua.cast(data,"CheckBox")
    -- local check = data:getSelectedState()
    -- check = not check
    --  local c = 0
    --  if check == true then
    --     c = 1
    --  end
    --  UserSetting[Setting.zhengdong.open] = c
    --  saveSetting(Setting.zhengdong.open,c)

  end
end
function onLight(event,data1,data)
  if event == "releaseUp" then
      tool.buttonSound("releaseUp","effect_12")
    data = tolua.cast(data,"CheckBox")
    local check = data:getSelectedState()
    check = not check
     local c = 0
     if check == true then
        c = 1
     end
     UserSetting[Setting.light.open] = c
     saveSetting(Setting.light.open,c)
     setAutoLockScreen(tonumber(UserSetting[Setting.light.open]) == 1 and true or false)

  end
end
function onPush(event,data1,data)
  if event == "releaseUp" then
    --   tool.buttonSound("releaseUp","effect_12")
    -- data = tolua.cast(data,"CheckBox")
    -- local check = data:getSelectedState()
    -- check = not check
    --  local c = 0
    --  if check == true then
    --     c = 1
    --  end
    --  saveSetting(Setting.push.open,c)

  end
end
widget = {
_ignore = true,
  panel = {
    bg = {
        back = {_type="Button",_func=onBack},
       music = {
              check = {
                _type = "CheckBox",_func = onCloseMusic,
              },
              text = {
                _type = "Label",
              }
       },
   
         effect = {
              check = {
                _type = "CheckBox",_func = onCloseEffect,
              },
              text = {
                _type = "Label",
              }
       },
         zhengdong = {
              check = {
                _type = "CheckBox",_func = onZhengdong,
              },
              text = {
                _type = "Label",
              }
       },
         light = {
              check = {
                _type = "CheckBox",_func = onLight,
              },
              text = {
                _type = "Label",
              }
       },
         push = {
              check = {
                _type = "CheckBox",_func = onPush,
              },
              text = {
                _type = "Label",
              }
       },

       bottom ={
          music = {slider = {_type = "Slider",_func = onBackgroundMusic},},
          effect = {slider = {_type = "Slider",_func = onMusic},},
       },
       },
  },
}
