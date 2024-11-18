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

function cEntity:SetModelScaleCloudbox(vector)
	self:SetLegacyTransform(true)

	local x, y, z = vector:Unpack()

	self:SetModelScale((x + y + z) / 3)
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

function gm13ize(script)
	script = "local timer = timercb\nlocal file = filecb\n\n" .. script

	// "Entity:SetColor and Entity:GetColor now deal with Colors only"
	local translated = string.gsub(script, ":SetColor%s*%(", ":SetColorCloudbox%(")

	// "entity.Classname. Caps is now enforced properly. Use entity.ClassName instead. (N is upper case)"
	translated = string.gsub(translated, ".Classname", ".ClassName")

	// "DMultiChoice is replaced by DComboBox"
	translated = string.gsub(translated, "\"DMultiChoice\"", "\"DComboBox\"")

	// "Angle functions have been unified. Before some were Set/GetAngles and some were Set/GetAngle. Now they're all Set/GetAngles()"
	translated = string.gsub(translated, ":SetAngle%s*%(", ":SetAngles%(")
	translated = string.gsub(translated, ":GetAngle%s*%(", ":GetAngles%(")

	// SetModelScale takes number now, not Vector
	translated = string.gsub(translated, ":SetModelScale%s*%(", ":SetModelScaleCloudbox%(")

	// CreateFont takes a table now
	translated = string.gsub(translated, "surface.CreateFont%s*%(", "CreateFontCloudbox%(")

	// Comment out AddCSLuaFile call, we already do this with Cloudbox
	translated = string.gsub(translated, "AddCSLuaFile%s*%(", "//AddCSLuaFile%(")

	// Use weapon_cs_base_cloudbox for weapon_cs_base
	translated = string.gsub(translated, "\"weapon_cs_base\"", "\"weapon_cs_base_cloudbox\"")

	// Use base_vehicle_cloudbox for base_vehicle
	translated = string.gsub(translated, "\"base_vehicle\"", "\"base_vehicle_cloudbox\"")

	// Experimental fix for bitwise OR
	translated = string.gsub(translated, "([%u%d])%s*(|)%s*(%u)", "%1 %+ %3")

	// Experimental fix for bitwise AND (blame Darth for this)
	translated = string.gsub(translated, "([%w_%.]+)%s*&%s*([%w_%.]+)%s*([=><]=?)%s*([%w_%.]+)", " bit.band(%1, %2) %3 %4 ")
	translated = string.gsub(translated, "util%.PointContents%s*%(%s*([%w_%.]+)%s*%)%s*&%s*([%w_%.]+)%s*([=><!]=?)%s*([%w_%.]+)", " bit.band(util.PointContents(%1), %2) %3 %4 ")

	return translated
end
