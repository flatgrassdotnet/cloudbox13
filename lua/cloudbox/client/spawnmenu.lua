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

	local html = vgui.Create("DHTML", panel)
	html:Dock(FILL)
	html:SetHTML("<html><head><link rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/cloudbox.css.txt' type='text/css'><link class='darkmode' rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/cloudbox-dark.css.txt' type='text/css' " .. darkCSS .. "><link rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/offline.css.txt' type='text/css'><link class='darkmode' rel='stylesheet' href='asset://garrysmod/data_static/cloudbox/offline-dark.css.txt' type='text/css' " .. darkCSS .. "></head><body><div class='header'><div id='offlinenote'><p>You are in offline mode. Browse cached downloads or click Reconnect to go online.</p></div><div class='navbar'><a id='retry' onclick='cloudbox.RetryOnline(); return false;' href=\"javascript:void(0);\"><div class='navicon'></div><br>Reconnect</a></div></div><div class='topclouds'></div><div class='content'><div class='column_container'>" .. fallbackContent .. "</div></div></body></html>")
	html:AddFunction("cloudbox", "GetPackage", RequestCloudboxDownload)
	html:AddFunction("cloudbox", "RetryOnline", function()
		local spnMenu = panel:GetParent()
		panel:Remove()
		cbOnline = false
		timer.Simple(0, function() -- timer required to prevent crash in Awesomium. Not needed for CEF.
			local newPanel = AddCloudboxTab()
			newPanel:Dock(FILL)
			spnMenu:Add(newPanel)
		end)
	end)

	cbHtmlOffline = html
end

function AddCloudboxTab()

	-- Blue background container
	local panel = vgui.Create("DPanel")
	function panel:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(184, 227, 255, 255) )
	end

	-- Loading spinner
	local spinner = vgui.Create("DPanel", panel)
	local spinnerImg = Material( "cloudbox/loading.png", "noclamp smooth" )
	local isSpinning = true
	spinner:SetSize( 78, 78 )
	function spinner:Paint( w, h )
		if isSpinning then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(spinnerImg)
			surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, -((CurTime() / 5) % 1) * 360)
		end
	end
	timer.Simple(10, function()
		isSpinning = false
	end)


	-- Fallback panel
	local container = vgui.Create("DPanel", panel)
	function container:Paint( w, h )
		draw.RoundedBox( 8, 0, 0, w, h, Color(255, 255, 255, 255) )
	end
	container:InvalidateLayout(true)
	container:SetSize(400,95)
	container:DockPadding(5,0,5,0)

	local txt1 = vgui.Create("DLabel", container)
	txt1:SetText("Loading Cloudbox...")
	txt1:SetFont("HudDefault")
	txt1:SetAutoStretchVertical(true)
	txt1:SetContentAlignment(5)
	txt1:SetTextColor(Color(64, 150, 238,255))
	txt1:Dock(TOP)
	txt1:DockMargin(10,10,10,0)

	local txt2 = vgui.Create("DLabel", container)
	txt2:SetText("If Cloudbox does not load, try Reconnect or spawn cached items Offline.")
	txt2:SetFont("DermaDefault")
	txt2:SetAutoStretchVertical(true)
	txt2:SetContentAlignment(5)
	txt2:SetTextColor(Color(51, 51, 51,255))
	txt2:Dock(TOP)
	txt2:DockMargin(10,5,10,0)

	local btnRetry = vgui.Create("DButton", container)
	btnRetry:SetText("Reconnect")
	btnRetry:SetFont("Trebuchet18")
	btnRetry.DoClick = function()
		local spnMenu = panel:GetParent()
		panel:Remove()
		cbOnline = false
		timer.Simple(0, function() -- timer required to prevent crash in Awesomium. Not needed for CEF.
			local newPanel = AddCloudboxTab()
			newPanel:Dock(FILL)
			spnMenu:Add(newPanel)
		end)
	end
	btnRetry:Dock(LEFT)
	btnRetry:DockMargin(5,10,5,10)
	btnRetry:SetWidth(120)

	local btnOpt = vgui.Create("DButton", container)
	btnOpt:SetText("Options")
	btnOpt:SetFont("Trebuchet18")
	btnOpt.DoClick = function() spawnmenu.ActivateTool("CloudboxUser", true) end
	btnOpt:Dock(LEFT)
	btnOpt:DockMargin(5,10,5,10)
	btnOpt:SetWidth(120)

	local btnData = vgui.Create("DButton", container)
	btnData:SetText("Offline Mode")
	btnData:SetFont("Trebuchet18")
	btnData:SetConsoleCommand("cloudbox_localmode")
	btnData:Dock(LEFT)
	btnData:DockMargin(5,10,5,10)
	btnData:SetWidth(120)

	panel.PerformLayout = function()
		spinner:Center()
		spinner:SetPos(spinner:GetX(), spinner:GetY() - 100)
		container:Center()
	end

	-- Online panel
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
	end)

	html.OnChangeTitle = function(_, title)
		if not (not cbOnline and title == "Cloudbox") then return end

		cbOnline = true
		html:SetVisible(true)
		if GetConVar("cloudbox_darkmode"):GetBool() then html:QueueJavascript("forceMode(true);") end

		if cbHtmlOffline then cbHtmlOffline:Remove() end
	end

	concommand.Add("cloudbox_localmode", function()
		cbOnline = true
		LoadCloudboxOffline(panel)
		spawnmenu.SwitchCreationTab("Cloudbox")
	end)

	cbHtmlOnline = html

	return panel
end

CreateConVar("cloudbox_darkmode", "0", FCVAR_ARCHIVE, "Cloudbox interface dark mode", 0, 1)

spawnmenu.AddCreationTab("Cloudbox", AddCloudboxTab, "materials/icon16/weather_clouds.png", 999, "Download stuff from Cloudbox!")
