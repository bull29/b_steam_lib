local fetch = http.Fetch
local idto64 = util.SteamIDTo64
local idtoid = util.SteamIDFrom64
local fetched_profiles = {}

local function validatesteam(ste)
	if ste:match("76%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d") then
		return ste
	elseif ste:match("STEAM_%d.%d:%d%A+") then
		return idto64(ste)
	end

	return false
end

--[[
	returned Table structure:
			Base Data:
			         Name: <>
			  	    State: <>
			         ID64: <>
			      SteamID: <>
			    CustomURL: <>
			   AvatarMini: <>
			 AvatarMedium: <>
			  AvatarLarge: <>
			
			if NotPrivate:
				if inGameInfo and State:ingame :
						gameName:
					  gameBanner:
				  
]]
function util.SteamProfileFetch(steamid, func )
	local steamid = validatesteam(steamid)

	if not steamid then return false end
	fetch("http://steamcommunity.com/profiles/" .. steamid .. "/?xml=1", function(body)
		local tab = {}

		if storeraw then
			tab.RawData = body
		end

		tab.Name = body:match("<steamID><!%[CDATA%[.+%]%]></steamID>"):sub(19, -14)
		tab.ID64 = steamid
		tab.SteamID = idtoid(steamid)
		tab.State = body:match("<onlineState>.+</onlineState>"):sub(14, -15)
		local av = body:match("http://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/.-jpg"):sub(1, -5)
		tab.AvatarMini = av .. ".jpg"
		tab.AvatarMedium = av .. "_medium.jpg"
		tab.AvatarLarge = av .. "_large.jpg"

		local GAME = body:match("<inGameInfo>.+</inGameInfo>")
		if GAME then
			tab.GameInfo = {}
			tab.GameInfo.gameName = GAME:match("<gameName><!%[CDATA%[.-]]></gameName>"):sub( 20, -15 )
			tab.GameInfo.gameBanner = GAME:match("<gameIcon><!%[CDATA%[.-]]></gameIcon>"):sub(20,-15)
		else

		end
		
		print( tab.getName )
		func( tab, body )
	end)
end

util.SteamProfileFetch( "76561198045139792", function( t ) PrintTable( t ) end)