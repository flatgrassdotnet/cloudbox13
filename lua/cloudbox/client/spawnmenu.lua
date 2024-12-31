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

local cbOnline = false
local cbHtmlOnline = nil
local cbHtmlOffline = nil
local cbHtmlBackground = nil

function LoadCloudbox(panel)
	local html = vgui.Create("DHTML", panel)

	local function CloudboxFocus(focus)
		local id = "OnTextEntryGetFocus" if not focus then id = "OnTextEntryLoseFocus" end
		hook.Run(id, html)
	end

	html:Dock(FILL)
	html:OpenURL("https://safe.cl0udb0x.com")
	html:SetVisible(false)

	html.Paint = function() return false end

	html:AddFunction("cloudbox", "GetPackage", RequestCloudboxDownload)
	html:AddFunction("cloudbox", "SetFocused", CloudboxFocus)
	html:AddFunction("cloudbox", "InitiateLocalMode", function() cbOnline = true LoadCloudboxOffline(panel) end)
	html:AddFunction("cloudbox", "OpenSettings", function() spawnmenu.ActivateTool("CloudboxUser", true) end)
	html:AddFunction("cloudbox", "OpenLink", function(param)
		if param == "workshop" then
			gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3365311511")
		elseif param == "workshop-comments" then
			gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/comments/3365311511")
		elseif param == "pancakes" then
			gui.OpenURL("https://steamcommunity.com/id/keroronpa")
		end
	end)

	html:AddFunction("cloudbox", "ToggleDarkMode", function(param)
		GetConVar("cloudbox_darkmode"):SetBool(param)
		if param then
			cbHtmlBackground:QueueJavascript("forceMode(true);")
		else
			cbHtmlBackground:QueueJavascript("forceMode(false);")
		end
	end)

	html.OnChangeTitle = function(_, title)
		if not (not cbOnline and title == "Cloudbox") then return end

		cbOnline = true
		html:SetVisible(true)
		if GetConVar("cloudbox_darkmode"):GetBool() then html:QueueJavascript("forceMode(true);") end

		if cbHtmlOffline then cbHtmlOffline:Remove() end
	end

	timer.Simple(5, function() if not cbOnline then LoadCloudboxOffline(panel) end end)

	cbHtmlOnline = html
end

function LoadCloudboxOffline(panel)
	if cbHtmlOnline then cbHtmlOnline:SetVisible(false) end

	local fallbackContent = ""
	local fallbackCats = {{"entity", "Entities"}, {"weapon", "Weapons"}, {"map", "Maps"}}
	local fallbackCatsList = {entity = "", weapon = "", map = ""}

	local cachedFiles = file.Find("cloudbox/downloads/*.json", "DATA")
	for _, filename in pairs(cachedFiles) do
		local meta = util.JSONToTable(file.Read("cloudbox/downloads/" .. filename))
		local str = "<a onclick='cloudbox.GetPackage(\"offline\", " .. tonumber(meta["id"]) .. "  ,  " .. tonumber(meta["rev"]) .. " )' class='item'><div class='thumb' style=\"background-image:url('http://img.cl0udb0x.com/" .. tonumber(meta["id"]) .. "_thumb_128.png'), url(&quot;asset://garrysmod/materials/cloudbox/missing.png&quot;)\"></div><div class='name'>" .. string.gsub(meta["name"], "[><]", "") .. "</div></a>"

		if meta["type"] == "map" then
			fallbackCatsList.map = fallbackCatsList.map .. str
		elseif meta["type"] == "entity" then
			fallbackCatsList.entity = fallbackCatsList.entity .. str
		elseif meta["type"] == "weapon" then
			fallbackCatsList.weapon = fallbackCatsList.weapon .. str
		end
	end

	for k,v in pairs(fallbackCats) do
		local txt = fallbackCatsList[v[1]];
		if txt == "" then
			txt = "<p class='noitems'>No items locally cached</p><span>&#x1F641;</span>"
		end

		fallbackContent = fallbackContent .. "<div class='pillbox column'><h2 class='pillbox'>" .. v[2] .. "</h2><br/>" .. txt .. "</div> "
	end
	
	
	local isDark = GetConVar("cloudbox_darkmode"):GetBool()
	local darkCSS = " disabled"
	if isDark then darkCSS = "" end
	cbHtmlBackground:QueueJavascript("forceMode(" .. tostring(isDark) .. ")")

	local html = vgui.Create("DHTML", panel)
	html:Dock(FILL)
	html:SetHTML("<html><head><link rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/cloudbox.css.txt' type='text/css'><link class='darkmode' rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/cloudbox-dark.css.txt' type='text/css' " .. darkCSS .. "><link rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/offline.css.txt' type='text/css'><link class='darkmode' rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/offline-dark.css.txt' type='text/css' " .. darkCSS .. "></head><body><div class='header'><div id='offlinenote'><p>You are in offline mode. Browse cached downloads or click Reconnect to go online.</p></div><div class='navbar'><a id='retry' onclick='cloudbox.RetryOnline(); return false;' href=\"javascript:void(0);\"><div class='navicon'></div><br>Reconnect</a></div></div><div class='topclouds topclouds_hidden'></div><div class='content'><div class='column_container'>" .. fallbackContent .. "</div></div></body></html>")
	html:AddFunction("cloudbox", "GetPackage", RequestCloudboxDownload)
	html:AddFunction("cloudbox", "RetryOnline", function()
		timer.Simple(0.01, function() // delay to prevent crash in Awesomium. CEF doesn't require this.
			cbOnline = false
			html:Remove()
			if cbHtmlOnline then cbHtmlOnline:Remove() end
			LoadCloudbox(panel)
		end)
	end)
	
	cbHtmlOffline = html
end

function AddCloudboxTab()
	local panel = vgui.Create("DPanel")

	local htmlBG = vgui.Create("DHTML", panel)
	htmlBG:Dock(FILL)
	htmlBG:SetHTML("<html><head><link rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/cloudbox.css.txt' type='text/css'><link class='darkmode' rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/cloudbox-dark.css.txt' type='text/css' disabled><link rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/background.css.txt' type='text/css'><link class='darkmode' rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/background-dark.css.txt' type='text/css' disabled><script src='asset://garrysmod/data_static/cloudbox/background.js.txt'></script></head><body><div class='header'></div><div class='topclouds'></div><div class='content'><div id='load'></div></div></body></html>")
	cbHtmlBackground = htmlBG

	LoadCloudbox(panel)

	concommand.Add("cloudbox_localmode", function()
		cbOnline = true
		LoadCloudboxOffline(panel)
		spawnmenu.SwitchCreationTab("Cloudbox")
	end)

	return panel
end

CreateConVar("cloudbox_darkmode", "0", FCVAR_ARCHIVE, "Cloudbox interface dark mode", 0, 1)

spawnmenu.AddCreationTab("Cloudbox", AddCloudboxTab, "materials/icon16/weather_clouds.png", 999, "Download stuff from Cloudbox!")
