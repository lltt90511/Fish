

module("handler.network",package.seeall)

function onChangedNetwork(t)
   local isChanged = false
   if NETWORK_TYPE ~= t then
      isChanged = true
   end
   NETWORK_TYPE = t
   print("changeNetWork "..NETWORK_TYPE)
   -- if isChanged == true then
   --    local nc = package.loaded["logic.nc"]
   --    nc.disConnect()
   -- end
end
