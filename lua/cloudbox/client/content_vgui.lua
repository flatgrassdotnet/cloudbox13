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
	self:SetSize(24, 24)
	self:NoClipping(true)

	self.imgPanel = vgui.Create("DImage", self)
	self.imgPanel:SetImage("icon16/weather_clouds.png")
	self.imgPanel:SetSize(16, 16)
	self.imgPanel:SetPos(4, 4)

	self.imgPanel:SetAlpha(30)

	self.BoxW = 0
	self.BoxH = 0
end

local ExtensionIcons = {
	["vtf"] = "picture",
	["vmt"] = "picture_add",

	["mdl"] = "brick",
	["vtx"] = "brick_add",
	["vvd"] = "brick_add",
	["phy"] = "brick_add",

	["wav"] = "sound",
	["mp3"] = "sound",

	["bsp"] = "world",

	["ain"] = "chart_organisation",
	["nav"] = "chart_organisation",

	["raw"] = "color_swatch",
	["pcf"] = "lightning",

	["txt"] = "script"
}

local HiddenExtensions = {
	["vmt"] = true,

	["vtx"] = true,
	["vvd"] = true,
	["phy"] = true
}

function PANEL:SetUp(name)
	local ext = string.GetExtensionFromFilename(name)

	local icon = ExtensionIcons[ext]
	if icon then
		self.imgPanel:SetImage("icon16/" .. icon .. ".png")
	end

	self.imgPanel:AlphaTo(255, 0.2, 0)
end

function PANEL:Update(f, name, size)
	self.f = f
	self.size = size

	if self.name != name then
		self:SetUp(name)
		self.name = name
	end
end

function PANEL:Think()
	if !self.Bouncing then return end

	local ft = FrameTime() * 20

	self.yvel = self.yvel + 2.0 * ft
	self.xvel = math.Approach(self.xvel, 0.0, ft * 0.01)

	self.xpos = self.xpos + self.xvel * ft * 3
	self.ypos = self.ypos + self.yvel * ft * 3

	if self.ypos > (ScrH() - 24) then
		self.ypos = (ScrH() - 24)
		self.yvel = self.yvel * -0.6
		self.xvel = self.xvel * 0.8
	end

	self:SetPos(self.xpos, self.ypos)
end

function PANEL:Paint()
	local r = 255 - 255 * self.f
	local g = 255
	local b = 255 - 255 * self.f
	local a = self.imgPanel:GetAlpha()

	if self.f == 1.0 && !self.Bouncing then
		r = 255
		g = 55 + math.Rand(0, 200)
		b = 5
	end

	if self.DownloadFailed then
		r = 255
		g = 50
		b = 50
	end

	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(20, 20, 20, a * 0.4))
	draw.RoundedBox(4, 1, 1, self:GetWide() - 2, self:GetTall() - 2, Color(r, g, b, a * 0.7))

	// If the file is bigger than 3MB, give us some info.
	//if self.f < 1.0 && self.size > (1024 * 1024 * 3) then
	//	self:DrawSizeBox(a)
	//end

	if !HiddenExtensions[string.GetExtensionFromFilename(self.name)] then self:DrawNameBox(a, self.name) end
end

function PANEL:DrawSizeBox(a)
	local x = (self.BoxW - self:GetWide()) * -0.5
	local txt = math.Round(self.f * 100, 2) .. "% of " .. string.NiceSize(self.size)

	self.BoxW, self.BoxH = draw.WordBox(4, x, self.BoxH * -1.1, txt, "DefaultSmall", Color(50, 55, 60, a * 0.8), Color(255, 255, 255, a))
end

function PANEL:DrawNameBox(a, name)
	local x = (self.BoxW - self:GetWide()) * -0.5
	local txt = string.StripExtension(string.GetFileFromFilename(name))

	self.BoxW, self.BoxH = draw.WordBox(4, x, self.BoxH * -1.1, txt, "DefaultSmall", Color(50, 55, 60, a * 0.8), Color(255, 255, 255, a))
end

function PANEL:Bounce()
	local x, y = self:LocalToScreen(0, 0)
	self:SetParent(GetHUDPanel())
	self:SetPos(x, y)

	self.Bouncing = true

	self.xvel = math.random(-12, 12)
	self.yvel = math.random(-20, -10)

	self.xpos = x
	self.ypos = y

	self.imgPanel:AlphaTo(0, 1, 1)
end

function PANEL:Failed()
	self.DownloadFailed = true
end

vgui.Register("DContentDownload", PANEL, "DPanel")
