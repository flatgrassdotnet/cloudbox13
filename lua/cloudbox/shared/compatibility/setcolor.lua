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

local cCEffectData = FindMetaTable("CEffectData")
local cEntity = FindMetaTable("Entity")

function cCEffectData:SetColorCloudbox(r, g, b, a)
	if IsColor(r) then
		self:SetColor(r)
	else
		self:SetColor(Color(r, g, b, a))
	end
end

function cEntity:SetColorCloudbox(r, g, b, a)
	if IsColor(r) then
		self:SetColor(r)
	else
		self:SetColor(Color(r, g, b, a))
	end
end

if CLIENT then
	local cCLuaParticle = FindMetaTable("CLuaParticle")
	local cProjectedTexture = FindMetaTable("ProjectedTexture")

	function cCLuaParticle:SetColorCloudbox(r, g, b, a)
		if IsColor(r) then
			self:SetColor(r)
		else
			self:SetColor(Color(r, g, b, a))
		end
	end

	function cProjectedTexture:SetColorCloudbox(r, g, b, a)
		if IsColor(r) then
			self:SetColor(r)
		else
			self:SetColor(Color(r, g, b, a))
		end
	end
end
