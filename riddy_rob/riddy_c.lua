----------------------------------------->>
-- Project: Store Robbery for Gamenet.ga Roleplay
-- Author: RidwanRF (Riddy)
-- Date: 12 March 2016
-- Resource: riddy_rob/rob_c.lua
-- Version: 1.3
----------------------------------------->>

addEvent ( "doWarpPlayerToInterior", true )
-- I store interior ids here from interiors resource (interiors.map)
RobLocID = { "CLOTHGP", "CLOTHGP (2)", "CLOTHGP (3)", "CLOTHGP (4)", 
			 "CSCHP", "CSCHP (2)", "CSCHP (3)", "CSCHP (4)", "CSDESGN",
			 "CSDESGN (2)", "CSDESGN (3)", "CSEXL", "CSSPRT", "CSSPRT (2)",
			 "LACS1 (2)" }


-- Note: I dont know what job handler I should put to define job, You might need to edit it.
-- Player aims at another player or objcet
cooldown = { }
info_cooldown = nil
function targetingActivated ( target )
	-- Check so the player is not policeman, that the player
	-- is aiming and that the location is interior
	local theTeam = getPlayerTeam ( localPlayer )
	if getElementData(localPlayer, "Job") == "Police" and getControlState("aim_weapon") and getElementInterior( localPlayer ) > 0 and isElement( target ) then
		outputChatBox("What are you doing Officer "..getPlayerName(localPlayer).."?", 255, 255, 0)
	elseif not isTimer(cooldown[target]) and not isTimer(info_cooldown) and getControlState("aim_weapon") and getElementInterior( localPlayer ) > 0 and isElement( target ) then
		-- Cooldown during robbery 5 minutes between each rob/store
		triggerServerEvent( "onRob", localPlayer, target )
		cooldown[target] = setTimer(function() end, 300000, 1 )
        info_cooldown = setTimer(function() end, 30000, 1 )
	elseif not isTimer(info_cooldown) and getControlState("aim_weapon") and getElementInterior( localPlayer ) > 0 and isElement( target ) then
		outputChatBox( "You just robbed this store, try another one!", 255, 0, 0 )
    end
end
addEventHandler ( "onClientPlayerTarget", root, targetingActivated )

function cancelPedDamage(attacker)
	if getElementInterior(localPlayer) > 0 then
		cancelEvent() -- Cancel any damage done to shop peds
	end
end
addEventHandler("onClientPedDamage", root, cancelPedDamage)

local color,direction = 0, true
function showTimeLeft( )
	if getElementData( localPlayer, "rob" ) then
		local endTime = tonumber( getElementData( localPlayer, "robTime" ))
		local currentTime = tonumber( getElementData( localPlayer, "robTime2" ))
		local sx, sy = guiGetScreenSize( )
		if endTime and currentTime and math.floor((endTime-currentTime)/1000) > 0 then
			dxDrawText ( "Robbery in progress, time left: "..tostring(math.floor((endTime-currentTime)/1000)).." seconds", ((sx/2)-200), sy-50, 0, 0,
				tocolor( color, color, color, 255 ), 0.7, "bankgothic" )
			if color == 255 then
				direction = false
			elseif color == 0 then
				direction = true
			end
			if direction then
				color = color + 1
			else
				color = color - 1
			end
		end
	end
end
addEventHandler( "onClientRender", root, showTimeLeft )

bindKey( "b", "down", function( key, keyState )
	if keyState == "down" then
		if not blipShow then
			for k, v in ipairs ( getElementsByType( "marker") ) do
				if getMarkerType( v ) == "arrow" and getElementInterior(v) == 0 then
					for i, d in ipairs (RobLocID) do
						if RobLocID[i] == tostring(getElementData(v, "id")) then
							createBlipAttachedTo( v, 31 )
							blipShow = true
						end
					end
				end
			end
		else
			for k, v in ipairs ( getElementsByType( "marker") ) do
				if getMarkerType( v ) == "arrow" and getElementInterior(v) == 0 then
					for k, elem in ipairs( getAttachedElements( v ) ) do
						if getElementType( elem ) == "blip" then
							destroyElement( elem )
							blipShow = false
						end
					end
				end
			end
		end
	end
end )

-- This event is just to check lastLoc before player enters interior
-- This is why interiors resource needs to be running, absolutely hyped when I found this solution
addEventHandler ( "doWarpPlayerToInterior", localPlayer, function()
	if isElement(localPlayer) then
		local x, y, z = getElementPosition(localPlayer)
		local zoneName = tostring(getZoneName(x, y, z, false).." "..getZoneName(x, y, z, true))
		if zoneName ~= "Unknown Unknown" then
			local tabpos = toJSON({x, y, z})
			setElementData(localPlayer, "pos", tabpos)
			setElementData(localPlayer, "lastLoc", zoneName)
		end
	end
end )
