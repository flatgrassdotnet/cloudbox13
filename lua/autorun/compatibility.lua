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

// "KeyValuesToTable and TableToKeyValues are now in the util library"
KeyValuesToTable = util.KeyValuesToTable
TableToKeyValues = util.TableToKeyValues

// "SetMaterialOverride, cam.StartMaterialOverride (which did the same thing) are removed and replaced with render.MaterialOverride"
if CLIENT then SetMaterialOverride = render.MaterialOverride end

// "Moved some functions into the game"
isDedicatedServer = game.IsDedicated
SinglePlayer = game.SinglePlayer
MaxPlayers = game.MaxPlayers

// "WorldSound has been replaced with sound.Play"
WorldSound = sound.Play

// "ValidEntity has been removed. Use IsValid instead"
ValidEntity = IsValid

function gm13ize(script)
	local ent = FindMetaTable("Entity")

	// "IMaterial:SetMaterialTexture is now IMaterial:SetTexture"
	local translated, _ = string.gsub(script, ":SetMaterialTexture%(", ":SetTexture%(")

	// "utilx no longer exists. Please replace all ocurances of utilx in your code to the util"
	translated, _ = string.gsub(translated, "utilx.", "util.")

	// "entity.Classname. Caps is now enforced properly. Use entity.ClassName instead. (N is upper case)"
	translated, _ = string.gsub(translated, ".Classname", ".ClassName")

	// "DMultiChoice is replaced by DComboBox"
	translated, _ = string.gsub(translated, "\"DMultiChoice\"", "\"DComboBox\"")

	// "Angle functions have been unified. Before some were Set/GetAngles and some were Set/GetAngle. Now they're all Set/GetAngles()"
	translated, _ = string.gsub(translated, ":SetAngle%(", ":SetAngles%(")
	translated, _ = string.gsub(translated, ":GetAngle%(", ":GetAngles%(")

	// "timer.IsTimer is now timer.Exists"
	translated, _ = string.gsub(translated, "timer.IsTimer%(", "timer.Exists%(")

	// "math duplicate functions removed (Deg2Rad, Rad2Deg)"
	translated, _ = string.gsub(translated, "math.Deg2Rad%(", "math.rad%(")
	translated, _ = string.gsub(translated, "math.Rad2Deg%(", "math.deg%(")

	// "Renamed Material:[Get|Set]Material to Material:[Get|Set]** (ie, :SetVector instead of :SetMaterialVector)"
	translated, _ = string.gsub(translated, ":GetMaterialVector%(", ":GetVector%(")
	translated, _ = string.gsub(translated, ":SetMaterialVector%(", ":SetVector%(")

	// "Player:GetCursorAimVector is now Player:GetAimVector"
	translated, _ = string.gsub(translated, ":GetCursorAimVector%(", ":GetAimVector%(")
	translated, _ = string.gsub(translated, ":GetPlayerAimVector%(", ":GetAimVector%(")

	// SetModelScale takes number now, not Vector
	function ent:SetModelScaleCloudbox(vector)
		self:SetLegacyTransform(true)

		local x, y, z = vector:Unpack()

		self:SetModelScale((x + y + z) / 3)
	end

	translated, _ = string.gsub(translated, ":SetModelScale%(", ":SetModelScaleCloudbox%(")

	// SetColor takes Color() now
	function ent:SetColorCloudbox(r, g, b, a)
		if IsColor(r) then
			self:SetColor(r)
		else
			self:SetColor(Color(r, g, b, a))
		end
	end

	translated, _ = string.gsub(translated, ":SetColor%(", ":SetColorCloudbox%(")

	// CreateFont takes a table now
	function CloudboxCreateFont(font_name, size, weight, antialiasing, additive, new_font_name, drop_shadow, outlined, blur)
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

	translated, _ = string.gsub(translated, "surface.CreateFont%(", "CloudboxCreateFont%(")

	return translated
end


