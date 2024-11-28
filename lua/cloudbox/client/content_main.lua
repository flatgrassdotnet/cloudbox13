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

local PANEL = {}

function PANEL:Init()
	self:SetSize(256, 100)
	self:SetPos(0, ScrH() + 10)
	self:SetZPos(100)
end

function PANEL:Think()
	self:SetParent(GetHUDPanel())

	/*if self.LastActivity && (SysTime() - self.LastActivity) > 2 then // has a 2 sec timeout before it removes the icons, cloudbox doesn't do progress so this is disabled
		self:MoveTo( self.x, ScrH() + 5, 0.5, 0.5 )
		self.LastActivity = nil;
		self.MaxFileCount = 0
	end*/

	for k, v in pairs(Downloads) do
		local x = (self:GetWide() * 0.5) + math.sin(SysTime() + k * -0.43) * self:GetWide() * 0.45
		local y = 20 + math.cos( SysTime() + k * -0.43) * 20 * 0.5
		v:SetPos(x - 13, y)
		v:SetZPos(y)

		v.accel = accel;
	end
end

function PANEL:OnActivity(dlt)
	if !self.LastActivity then
		self:MoveTo(self.x, ScrH() - self:GetTall() + 20, 0.1)
	end

	self.LastActivity = SysTime()
end

function PANEL:PerformLayout()
	self:CenterHorizontal()
end

function PANEL:Add(p)
	local x, y = self:GetPos()
	local ypos = math.random(20, 25)
end

vgui.Register( "DContentMain", PANEL, "Panel" )
