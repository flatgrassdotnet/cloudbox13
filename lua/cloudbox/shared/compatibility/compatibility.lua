/*
	cloudbox13 - cloudbox client for gmod 13
	Copyright (C) 2024 - 2025  patapancakes <patapancakes@pagefault.games>

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Affero General Public License for more details.

	You should have received a copy of the GNU Affero General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

local cEntity = FindMetaTable("Entity")
local cIMaterial = FindMetaTable("IMaterial")
local cPlayer = FindMetaTable("Player")
local cWeapon = FindMetaTable("Weapon")
local cParticle = FindMetaTable("CLuaParticle")
local cAngle = FindMetaTable("Angle")
local cVector = FindMetaTable("Vector")

// "KeyValuesToTable and TableToKeyValues are now in the util library"
KeyValuesToTable = util.KeyValuesToTable
TableToKeyValues = util.TableToKeyValues

// "SetMaterialOverride, cam.StartMaterialOverride (which did the same thing) are removed and replaced with render.MaterialOverride"
if CLIENT then
	SetMaterialOverride = render.MaterialOverride
	cam.StartMaterialOverride = render.MaterialOverride
end

// "IMaterial:SetMaterialTexture is now IMaterial:SetTexture"
cIMaterial.GetMaterialFloat = cIMaterial.GetFloat
cIMaterial.SetMaterialFloat = cIMaterial.SetFloat
cIMaterial.GetMaterialInt = cIMaterial.GetInt
cIMaterial.SetMaterialInt = cIMaterial.SetInt
cIMaterial.GetMaterialMatrix = cIMaterial.GetMatrix
cIMaterial.SetMaterialMatrix = cIMaterial.SetMatrix
cIMaterial.GetMaterialString = cIMaterial.GetString
cIMaterial.SetMaterialString = cIMaterial.SetString
cIMaterial.GetMaterialTexture = cIMaterial.GetTexture
cIMaterial.SetMaterialTexture = cIMaterial.SetTexture
cIMaterial.GetMaterialVector = cIMaterial.GetVector
cIMaterial.SetMaterialVector = cIMaterial.SetVector

// "utilx no longer exists. Please replace all ocurances of utilx in your code to the util"
utilx = util

// "timer.IsTimer is now timer.Exists"
timer.IsTimer = timer.Exists

// "math duplicate functions removed (Deg2Rad, Rad2Deg)"
math.Deg2Rad = math.rad
math.Rad2Deg = math.deg

// "Renamed Material:[Get|Set]Material to Material:[Get|Set]** (ie, :SetVector instead of :SetMaterialVector)"
cIMaterial.GetMaterialVector = cIMaterial.GetVector
cIMaterial.SetMaterialVector = cIMaterial.SetVector

// "Moved some functions into the game"
isDedicatedServer = game.IsDedicated
SinglePlayer = game.SinglePlayer
MaxPlayers = game.MaxPlayers

// "WorldSound has been replaced with sound.Play"
WorldSound = sound.Play

// "Player:GetCursorAimVector is now Player:GetAimVector"
cPlayer.GetCursorAimVector = cPlayer.GetAimVector
cPlayer.GetPlayerAimVector = cPlayer.GetAimVector

// "ValidEntity has been removed. Use IsValid instead"
ValidEntity = IsValid

// mathx is now math
mathx = math

// Player:GetScriptedVehicle is now Player:GetVehicle
cPlayer.GetScriptedVehicle = cPlayer.GetVehicle

// AccessorFuncNW no longer exists. Replace with AccessorFunc. Will work in SP but will not network in MP.
AccessorFuncNW = AccessorFunc

// VelocityDecay no longer exists and has no replacement. Just prevent it erroring.
if CLIENT then
	function cParticle:VelocityDecay(...) end
end

function cPlayer:GetInfoNumCloudbox(cVarName, default)
	default = default or 0

	return self:GetInfoNum(cVarName, default)
end

function cPlayer:SetFOVCloudbox(fov, ...)
	fov = fov or 0

	self:SetFOV(fov, ...)
end

function cEntity:SetModelScaleCloudbox(vector)
	// The way GM12's SetModelScale works does not match GM13's version. It much more closely matches EnableMatrix
	// https://wiki.facepunch.com/gmod/Entity:EnableMatrix

	self:SetLegacyTransform(true)

	local mat = Matrix()
	mat:Scale(vector)

	self:EnableMatrix("RenderMultiply", mat)
end

function cEntity:EmitSoundCloudbox(soundName, soundLevel, pitchPercent, volume, channel, soundFlags, dsp, filter)
	// TF2 Fix
	if string.EndsWith(soundName, ".wav") and not file.Exists("sound/" .. soundName, "GAME") and file.Exists("sound/" .. string.Replace(soundName, ".wav", ".mp3"), "GAME") then
		soundName = string.Replace(soundName, ".wav", ".mp3")
	end

	// Using defaults, except channel which will use CHAN_AUTO to make sure weapons sound as in GM12
	self:EmitSound(soundName, soundLevel or 75, pitchPercent or 100, volume or 1, channel or CHAN_AUTO, soundFlags or 0, dsp or 0, filter or nil)
end

function EmitSoundCloudbox(soundName, ...)
	// TF2 Fix
	if string.EndsWith(soundName, ".wav") and not file.Exists("sound/" .. soundName, "GAME") and file.Exists("sound/" .. string.Replace(soundName, ".wav", ".mp3"), "GAME") then
		soundName = string.Replace(soundName, ".wav", ".mp3")
	end

	EmitSound(soundName, ...)
end

function LerpCloudbox(t, from, to)
	// Fix scripts providing non-numerical values
	if not isnumber(t) then t = 0 end
	if not isnumber(from) then from = 0 end
	if not isnumber(to) then to = 0 end
	return Lerp(t, from, to)
end

function CreateFontCloudbox(font_name, size, weight, antialiasing, additive, new_font_name, drop_shadow, outlined, blur)
	surface.CreateFont(new_font_name, {
		font = font_name,
		size = size,
		weight = weight,
		antialias = antialiasing,
		additive = additive,
		shadow = drop_shadow,
		outline = outlined,
		blur = blursize
	})
end

function DrawTexturedRectUVCloudbox(x, y, rectwidth, rectheight, texturewidth, textureheight)
	local u1, v1 = rectwidth / texturewidth, rectheight / textureheight
	surface.DrawTexturedRectUV(x, y, rectwidth, rectheight, 0, 0, u1, v1 )
end

function GetMountedContent()
	local games = {}

	for _, v in pairs(engine.GetGames()) do
		if v["mounted"] then games[v["title"]] = v["folder"] end
	end

	return games
end

function GetAddonList()
	local addons = {}

	for _, v in pairs(engine.GetAddons()) do
		if v["mounted"] then table.insert(addons, v["title"]) end // probably not correct
	end

	return addons
end

function cPlayer:ViewPunchCloudbox(ang)
	if isangle(ang) then self:ViewPunch(ang) return end

	local x, y, z = ang:Unpack()

	self:ViewPunch(Angle(x, y, z))
end

function cWeapon:DefaultReloadCloudbox(act)
	return self:DefaultReload(act or ACT_VM_RELOAD)
end

function cWeapon:SetWeaponHoldTypeCloudbox(t)
	self:SetWeaponHoldType(t or "normal")
end

function cWeapon:SetDeploySpeedCloudbox(speed)
	self:SetDeploySpeed(speed or GetConVar("sv_defaultdeployspeed"):GetFloat())
end

function pairsCloudbox(tab)
	if not istable(tab) then tab = {} end
	return pairs(tab)
end

function HookAddCloudbox(eventName, identifier, func)
	// Some scripts incorrectly use numbers
	if isnumber(identifier) then identifier = tostring(identifier) end

	// Override callback function for EntityTakeDamage. 
	// Arguments 'ent,inflictor,attacker,amount,dmginfo' have been collapsed to just 'ent,dmginfo'.
	if eventName == "EntityTakeDamage" then
		local hooked = func
		func = function(ent, dmginfo) return hooked(ent, dmginfo:GetInflictor(), dmginfo:GetAttacker(), dmginfo:GetDamage(), dmginfo) end
	end

	hook.Add(eventName, identifier, func)
end

function cAngle:NormalizeCloudbox()
	self:Normalize()
	return self
end

function cVector:NormalizeCloudbox()
	self:Normalize()
	return self
end

CloudboxScriptReplacements = {
	// "Entity:SetColor and Entity:GetColor now deal with Colors only"
	[":SetColor%s*%("] = ":SetColorCloudbox%(",

	// GetColor only returns the Color now. Some scripts require it split. Hacky fix.
	["local r,%s*g,%s*b,%s*a%s*=%s*self:GetColor%(%)"] = "local r, g, b, a = self:GetColor%(%):Unpack%(%)",

	// "entity.Classname. Caps is now enforced properly. Use entity.ClassName instead. (N is upper case)"
	["%.Classname"] = ".ClassName",

	// "DMultiChoice is replaced by DComboBox"
	["\"DMultiChoice\""] = "\"DComboBox\"",

	// "Angle functions have been unified. Before some were Set/GetAngles and some were Set/GetAngle. Now they're all Set/GetAngles()"
	[":SetAngle%s*%("] = ":SetAngles%(",
	[":GetAngle%s*%("] = ":GetAngles%(",

	// SetModelScale takes number now, not Vector
	[":SetModelScale%s*%("] = ":SetModelScaleCloudbox%(",

	// CreateFont takes a table now
	["surface.CreateFont%s*%("] = "CreateFontCloudbox%(",

	// Comment out AddCSLuaFile call, we already do this with Cloudbox
	["AddCSLuaFile%s*%("] = "//AddCSLuaFile%(",

	// Use weapon_cs_base_cloudbox for weapon_cs_base
	["\"weapon_cs_base\""] = "\"weapon_cs_base_cloudbox\"",

	// Use base_vehicle_cloudbox for base_vehicle
	["\"base_vehicle\""] = "\"base_vehicle_cloudbox\"",

	// Use base_vehicle_cloudbox for base_vehicle
	["\"base_vehicle\""] = "\"base_vehicle_cloudbox\"",

	// Experimental fix for bitwise OR
	["([%u%d])%s*(|)%s*(%u)"] = "%1 %+ %3",

	// Experimental fix for bitwise AND (blame Darth for this)
	["([%w_%.]+)%s*&%s*([%w_%.]+)%s*([=><]=?)%s*([%w_%.]+)"] = " bit.band(%1, %2) %3 %4 ",
	["util%.PointContents%s*%(%s*([%w_%.]+)%s*%)%s*&%s*([%w_%.]+)%s*([=><!]=?)%s*([%w_%.]+)"] = " bit.band(util.PointContents(%1), %2) %3 %4 ",

	// Fonts
	["\"ConsoleText\""] = "\"DefaultFixed\"",
	["\"Trebuchet19\""] = "\"Trebuchet18\"",
	["\"HUDNumber5\""] = "\"CloseCaption_Bold\"",
	["\"MenuLarge\""] = "\"HudSelectionText\"",
	["\"ScoreboardText\""] = "\"ScoreboardDefault\"",
	["\"HUDNumber\""] = "\"HUDNumbers\"",
	["\"TitleFont2\""] = "\"ClientTitleFont\"",
	["\"De_Tips\""] = "\"Trebuchet24\"",

	// DSysButton was removed in favour of native closing. To prevent errors, replace with a normal button
	["\"DSysButton\""] = "\"DButton\"",
	[":SetType%s*%(%s*\"close\"%s*%)"] = ":SetText%(\"x\"%)",

	// surface.DrawTexturedRectUV parameters have changed
	["surface.DrawTexturedRectUV%s*%("] = "DrawTexturedRectUVCloudbox%(",

	// Use ACT_GMOD_GESTURE_ITEM_PLACE for ACT_ITEM_PLACE
	["([,%(])%s*ACT_ITEM_PLACE%s*([,%)])"] = " %1 ACT_GMOD_GESTURE_ITEM_PLACE %2 ",

	// Update FVPHYSICS enums
	["([,%(])%s*NO_SELF_COLLISIONS%s*([,%)])"] = " %1 FVPHYSICS_NO_SELF_COLLISIONS %2 ",
	["([,%(])%s*HEAVY_OBJECT%s*([,%)])"] = " %1 FVPHYSICS_HEAVY_OBJECT %2 ",

	// Update DMG enums
	["([,%(])%s*DMG_FIRE%s*([,%)])"] = " %1 DMG_BURN %2 ",

	// Update RENDERGROUP enums
	["([,%(])%s*RENDER_GROUP_VIEW_MODEL_OPAQUE%s*([,%)])"] = " %1 RENDERGROUP_VIEWMODEL %2 ",

	// EmitSound fix for TF2, and other sound issues
	[":EmitSound%s*%("] = ":EmitSoundCloudbox%(",
	["EmitSound%s*%("] = "EmitSoundCloudbox%(",

	// Fix GetInfoNum not providing a default
	[":GetInfoNum%s*%("] = ":GetInfoNumCloudbox%(",

	// SetFOV can't be nil
	[":SetFOV%s*%("] = ":SetFOVCloudbox%(",

	// ViewPunch takes Angle now
	[":ViewPunch%s*%("] = ":ViewPunchCloudbox%(",

	// DefaultReload arg is not optional now
	[":DefaultReload%s*%("] = ":DefaultReloadCloudbox%(",

	// Fix incorrect(?) coding, passing Angle into certain things when it needs to be Vector
	[":SetPos%s*%(%s*Angle%s*%("] = ":SetPos%(Vector%(",
	[":AddAngleVelocity%s*%(%s*Angle%s*%("] = ":AddAngleVelocity%(Vector%(",

	// Some scripts incorrectly use numbers as an identifier. Intercept the .Add to fix it.
	["hook%.Add%s*%("] = "HookAddCloudbox%(",

	// TF2 Models
	["\"models/items/tf/plate%.mdl\""] = "\"models/items/plate.mdl\"",

	// SetMaterial doesn't take a Material object
	[":SetMaterial%s*%(%s*Material%s*%(%s*\"([%w_/]+)\"%s*%)%s*%)"] = ":SetMaterial%( \"%1\" %)",

	// Normalize no longer returns a value
	[":Normalize%(%)"] = ":NormalizeCloudbox%(%)",

	// Fix some scripts providing non-numerical values to Lerp. Global Lerp only.
	["%sLerp%s*%("] = " LerpCloudbox%(",

	// 180179 "Pixel Weapon"
	["colorPnl:GetTable%(%)%.AlphaBar:GetTable%(%)%.imgBackground%.Paint = function%(%) end"] = "",

	// pairs breaks when provided with nil
	["%spairs%s*%("] = " pairsCloudbox%(",

	// SetWeaponHoldType can't accept nil
	[":SetWeaponHoldType%s*%("] = ":SetWeaponHoldTypeCloudbox%(",

	// SetDeploySpeed can't accept nil
	[":SetDeploySpeed%s*%("] = ":SetDeploySpeedCloudbox%(",
}

// "stopsounds" is now "stopsound"
concommand.Add("stopsounds", function() RunConsoleCommand("stopsound") end)

function gm13ize(script)
	script = "local timer = timercb\nlocal file = filecb\n\n" .. script

	for match, replacement in pairs(CloudboxScriptReplacements) do
		script = string.gsub(script, match, replacement)
	end

	return script
end
