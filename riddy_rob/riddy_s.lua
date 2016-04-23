----------------------------------------->>
-- Project: Store Robbery for Gamenet.ga Roleplay
-- Author: RidwanRF (Riddy)
-- Date: 12 March 2016
-- Resource: riddy_rob/rob_s.lua
-- Version: 1.3
----------------------------------------->>

-- Note: I dont know what job handler I should put to define job, You might need to edit it.

ped = { }
peds = {
	-- Clothes shops
	--x, y, z, dimension, interior, rotation, skinID, nameOfStore
	[1]={ 161, -81, 1001.8046875, 3, 18, 180, 93, "Zip clothes shop" },
	[2]={ 161, -81, 1001.8046875, 2, 18, 180, 226, "Zip clothes shop" },
	[3]={ 161, -81, 1001.8046875, 1, 18, 180, 93, "Zip clothes shop" },
	[4]={ 161, -81, 1001.8046875, 0, 18, 180, 192, "Zip clothes shop" },

	[5]={ 204.7978515625, -7.896484375, 1001.2109375, 2, 5, 270, 233, "Victim" },
	[6]={ 204.7978515625, -7.896484375, 1001.2109375, 1, 5, 270, 93, "Victim" },
	[7]={ 204.7978515625, -7.896484375, 1001.2109375, 0, 5, 270, 93, "Victim" },

	[8]={ 203.4, -41.7, 1001.8046875, 1, 1, 180, 93, "Sub Urban (Hashbury)" },

	[9]={ 204.2080078125, -157.8193359375, 1000.5234375, 0, 14, 180, 226, "DidierSachs (Rodeo)" },

	[10]={ 206.3759765625, -127.5380859375, 1003.5078125, 1, 3, 180, 233, "Pro Laps" },
	[11]={ 206.3759765625, -127.5380859375, 1003.5078125, 0, 3, 180, 192, "Pro Laps (Rodeo)" },

	[12]={ 206.3349609375, -98.703125, 1005.2578125, 3, 15, 180, 192, "Binco clothes shop" },
	[13]={ 206.3349609375, -98.703125, 1005.2578125, 2, 15, 180, 233, "Binco clothes shop" },
	[14]={ 206.3349609375, -98.703125, 1005.2578125, 1, 15, 180, 192, "Binco clothes shop" },
	[15]={ 206.3349609375, -98.703125, 1005.2578125, 0, 15, 180, 233, "Binco clothes shop (Ganton)" },
	
}

-- Trigger respawn each 12 hour
cancelTimers = {}
function loadPeds()
	if ( not getResourceFromName ( "interiors" ) or getResourceState ( getResourceFromName ( "interiors" ) ) ~= "running" ) then
		return outputChatBox ( "The "..getResourceName(getThisResource()).." resource requires interiors.", root, 255, 0, 0 )
	end
	respawn_all_peds()
	setTimer(respawn_all_peds, 60*60*12*1000, 0)
end
addEventHandler("onResourceStart", resourceRoot, loadPeds)

-- Respawn all peds
function respawn_all_peds()
	for k=1, #peds do
		-- Destroy element if it exist
		if isElement(ped[k]) then destroyElement(ped[k]) end

		-- Create the ped
    	ped[k] = createPed( peds[k][7], peds[k][1], peds[k][2], peds[k][3] )
		setElementDimension( ped[k], peds[k][4] )
		setElementInterior( ped[k], peds[k][5] )
		setPedRotation( ped[k], peds[k][6] )
		setElementData( ped[k], "robLoc", peds[k][8] )
	end
end

-- Robbery time
function CounterTime( crim )
	if isElement( crim ) then
		local time = getTickCount( )
		setElementData( crim, "robTime2", time )
	end
end

-- Define law
lawTeams = {
	["Police"] = true,
}
-- Antispam timer
robTimer = {{ }}

-- Check if player is a cop?
function isLawUnit(player)
	if isElement(player) then
		return lawTeams[tostring(getElementData(player, "Job"))]
	end
end

-- Do the rob
function robStore( target )
	if getElementType( target ) == "ped" and ((robTimer[target] and not isTimer(robTimer[target][client])) or not robTimer[target]) then
		-- Robbery in progress
		setElementData( client, "rob", true )
		
		-- Calculating payment
		local onlinePlayers = tonumber(getPlayerCount())
		if onlinePlayers < 5 then
			min, max = 10, 16
		elseif (5 <= onlinePlayers) and (onlinePlayers <= 15) then
			min, max = 20, 50  -- 2k ~ 5k
		elseif (15 <= onlinePlayers) and (onlinePlayers < 30) then
			min, max = 50, 70  -- 5k ~ 7k
		elseif (30 <= onlinePlayers) and (onlinePlayers < 40) then
			min, max = 70, 130 -- 6k ~ 11k
		elseif onlinePlayers > 40 then
			min, max = 140, 170 -- 14k ~ 17k
		end
		
		-- Lets see is there cop arround us?
		-- outputDebugString(tostring(isTherePoliceAround(client)))
		if tonumber(isTherePoliceAround(client)) == 0  then -- if not then extend the time and reduce payment
			money = tonumber(math.random( min, max ) * 100)
			robtime = math.random(120000, 180000)	
		else -- if yes then let it be default
			money = tonumber(math.random( min, max ) * 100 + (math.random(3, 7) * 100))
			robtime = math.random(90000, 150000)	
		end

		-- Allow count down timer
		setElementData( client, "robTime", robtime+getTickCount( ))
		setElementData( client, "robTime2", getTickCount( ))
		setTimer( CounterTime, 1000, (math.floor(robtime)/1000), client )
	
		-- When the robbery is finished
	    setTimer( payForRob, robtime, 1, client, money )
	    setTimer( robStatus, robtime, 1, client, target )
	    cancelTimers[client] = setTimer( cancelRob, (math.floor(robtime)/100), 100, client, target )

	    -- Set the wanted level
		outputChatBox("You committed the crime of robbery", client, 255, 0, 0)
		local addition = math.random(1, 2)
		local wantedLevel = getPlayerWantedLevel(client) + tonumber(addition)
		if ((wantedLevel) >= 6)  then
			--outputDebugString("Wanted level 6 reached")
			setPlayerWantedLevel(client, 6)
		else
			setPlayerWantedLevel(client, wantedLevel)
		end
		setPedAnimation( target, "shop", "shp_rob_givecash", -1, false, false, false )

		-- Send alarm call to all the cops
		local robLoc = getElementData( target, "robLoc" )
		if not robLoc then
			robLoc = "Unknown store"
		end
		
		-- lastloc handler can be found in doWarpPlayerToInterior
		robLoc = robLoc.." ("..getElementData( client, "lastLoc" )..")"
		outputChatBox( "You have robbed "..robLoc..", stay inside!", client, 255, 200, 0 )
		local cops = getElementsByType( "player" )
		for theKey,cop in ipairs(cops) do
			if isLawUnit(cop) then --Get all online Policemen
				outputChatBox( "#0000BB(911): #EEEEEERobbery in progress at: "..robLoc, cop, 255, 255, 255, true )
			end
		end

		-- Set cooldown timer for store to 10 minutes
		if not robTimer[target] then robTimer[target] = { } end
		robTimer[target][client] = setTimer(function() end, tonumber(get("cooldown")*60000) or 600000, 1 )
	elseif robTimer[target] and robTimer[target][client] and isTimer(robTimer[target][client]) then
		outputChatBox( "Get the hell out of here, this shop was recently robbed!", client, 255, 0, 0 )
	end
end
addEvent( "onRob", true )
addEventHandler( "onRob", root, robStore )

function payForRob( crim, amount )
	if isElement( crim ) then
		if getElementData( crim, "rob" ) then
			givePlayerMoney( crim, amount )
		end
	end
end

function robStatus( crim, target, money )
	if isElement( crim ) then
		if getElementData( crim, "rob" ) then
			outputChatBox( "Rob successfully, now escape before the cops arrive!", crim, 0, 255, 0 )
	    end
	    if isElement( target ) and isElement( crim ) then
			setPedAnimation( target, nil, nil )
			setElementData( crim, "rob", false )
		end
	end
end

-- Check if the rob should be interrupted (Please edit element data "Jailed")
function cancelRob( crim, target )
	if isElement( crim ) then
		if getElementInterior( crim ) == 0 or getElementData( crim, "Jailed" ) == "Yes" then
			setElementData( crim, "rob", false )
			outputChatBox( "Robbery failed because you left the store!", crim, 255, 0, 0 )
			setPedAnimation( target, nil, nil )
			if isTimer( cancelTimers[crim] ) then
				killTimer( cancelTimers[crim] )
			end
		end
	end
end

-- Find nearest cop (returns: police)
function isTherePoliceAround(player)
	local dist = 99999
	local nearCop = 0
	for w,cop in ipairs(getElementsByType("player")) do
		if isLawUnit(cop) then
			cx,cy,cz = getElementPosition(cop)
			px, py, pz = unpack(fromJSON(getElementData(player, "pos")))
			if getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz) < dist then
				dist = getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz)
				nearCop = cop
			end
		end
	end
	return nearCop
end

-- Police successfully arrested a crim do this
function arrestCriminals(attacker, attackerweapon)
	-- Get the team
	if not attacker or not isElement(attacker) or getElementType(attacker) ~= "player"
		or not getPlayerTeam(attacker) or not getPlayerTeam(source) then return end

	-- Get the wanted level
	local wl = getPlayerWantedLevel(source) or 0
	if wl <= 3  then
		bonus = math.random(1, 4) * 100
	elseif wl >= 4 then
		bonus = math.random (3, 6) * 100
	end
	local money = tonumber(math.random(7, 13) * 100 + bonus)
	-- Arrest players
	if (attackerweapon == 3 or 23) and wl > 0 and getElementInterior(source) > 0 and
		isLawUnit(attacker) and getElementData(source, "rob") then
		
        outputChatBox("You have successfully taken down: "..getPlayerName(source)..", get bonus of +$"..tostring(money), attacker, 0, 255, 0)
		givePlayerMoney(attacker, money)
		
        -- Arrested players: go to jail or nah
		setElementData(source, "Jailed", "Yes")
  	end
end
addEventHandler("onPlayerDamage", root, arrestCriminals)
