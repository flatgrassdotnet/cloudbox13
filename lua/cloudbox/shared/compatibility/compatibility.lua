/*
	cloudbox13 - cloudbox client for gmod 13
	Copyright (C) 2024  patapancakes <patapancakes@pagefault.games>

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

function cPlayer:GetInfoNumCloudbox(cVarName, default)
	default = default or 0

	self:GetInfoNum(cVarName, default)
end

function cPlayer:SetFOVCloudbox(fov, ...)
	fov = fov or 0

	self:SetFOV(fov, ...)
end

function cEntity:SetModelScaleCloudbox(vector)
	self:SetLegacyTransform(true)

	local x, y, z = vector:Unpack()

	self:SetModelScale((x + y + z) / 3)
end

function cEntity:EmitSoundCloudbox(soundName, ...)
	// TF2 Fix
	if string.EndsWith(soundName, ".wav") and not file.Exists("sound/" .. soundName, "GAME") and file.Exists("sound/" .. string.Replace(soundName, ".wav", ".mp3"), "GAME") then
		soundName = string.Replace(soundName, ".wav", ".mp3")
	end

	self:EmitSound(soundName, ...)
end

function EmitSoundCloudbox(soundName, ...)
	// TF2 Fix
	if string.EndsWith(soundName, ".wav") and not file.Exists("sound/" .. soundName, "GAME") and file.Exists("sound/" .. string.Replace(soundName, ".wav", ".mp3"), "GAME") then
		soundName = string.Replace(soundName, ".wav", ".mp3")
	end

	EmitSound(soundName, ...)
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

CloudboxScriptReplacements = {
	// "Entity:SetColor and Entity:GetColor now deal with Colors only"
	[":SetColor%s*%("] = ":SetColorCloudbox%(",

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

	// Fonts: Use DefaultFixed instead of ConsoleText
	["\"ConsoleText\""] = "\"DefaultFixed\"",

	// surface.DrawTexturedRectUV parameters have changed
	["surface.DrawTexturedRectUV%s*%("] = "DrawTexturedRectUVCloudbox%(",

	// Get a Normalized vector instead of changing it to Normalized
	[":Normalize%(%)"] = ":GetNormalized%(%)",

	// Use ACT_GMOD_GESTURE_ITEM_PLACE for ACT_ITEM_PLACE
	["([,%(])%s*ACT_ITEM_PLACE%s*([,%)])"] = " %1 ACT_GMOD_GESTURE_ITEM_PLACE %2 ",

	// Update FVPHYSICS enums
	["([,%(])%s*NO_SELF_COLLISIONS%s*([,%)])"] = " %1 FVPHYSICS_NO_SELF_COLLISIONS %2 ",
	["([,%(])%s*HEAVY_OBJECT%s*([,%)])"] = " %1 FVPHYSICS_HEAVY_OBJECT %2 ",

	// Fonts: Use Trebuchet18 instead of Trebuchet19
	["\"Trebuchet19\""] = "\"Trebuchet18\"",

	// EmitSound fix for TF2
	[":EmitSound%s*%("] = ":EmitSoundCloudbox%(",
	["EmitSound%s*%("] = "EmitSoundCloudbox%(",

	// Fix GetInfoNum not providing a default
	[":GetInfoNum%s*%("] = ":GetInfoNumCloudbox%(",

	// SetFOV can't be nil
	[":SetFOV%s*%("] = ":SetFOVCloudbox%(",

	// ViewPunch takes Angle now
	[":ViewPunch%s*%("] = ":ViewPunchCloudbox%(",

	// DefaultReload arg is not optional now
	[":DefaultReload%s*%("] = ":DefaultReloadCloudbox%("
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
