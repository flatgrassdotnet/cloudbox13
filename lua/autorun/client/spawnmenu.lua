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

function AddCloudboxTab()
	local panel = vgui.Create("DPanel")
	panel:SetBackgroundColor(Color(184, 227, 255))

	local html = vgui.Create("DHTML", panel)

	local function CloudboxFocus(focus)
		if (focus) then
			hook.Run("OnTextEntryGetFocus", html)
		else
			hook.Run("OnTextEntryLoseFocus", html)
		end
	end

	html:Dock(FILL)
	html:OpenURL("https://ingame.cl0udb0x.com")
	html:AddFunction("cloudbox", "GetPackage", RequestCloudboxDownload)
	html:AddFunction("cloudbox", "SetFocused", CloudboxFocus)

	return panel
end

spawnmenu.AddCreationTab("Cloudbox", AddCloudboxTab, "materials/icon16/weather_clouds.png", 999, "Download stuff from Cloudbox!")
