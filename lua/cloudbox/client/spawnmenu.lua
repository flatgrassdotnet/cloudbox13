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
			cbHtmlBackground:QueueJavascript("document.getElementById('darkmode').innerText=\"html,body{background-color:#1b2838} #top{background-color:#171d25} #topclouds {background-image:url('asset://garrysmod/materials/cloudbox/clouds-dark.png');  background-color:#171d25;}\";")
		else
			cbHtmlBackground:QueueJavascript("document.getElementById('darkmode').innerText=\"\";")
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

	local cbScrollbarCSS = "::-webkit-scrollbar {background-color: #4096EE; border-radius: 4px;} ::-webkit-scrollbar-button, ::-webkit-scrollbar-thumb {background-color: white; border: 2px solid #595959;} ::-webkit-scrollbar-button:hover, ::-webkit-scrollbar-thumb:hover {background-color: #B8E3FF;} ::-webkit-scrollbar-button:active, ::-webkit-scrollbar-thumb:active {border-color: #4096EE;} ::-webkit-scrollbar-button:decrement {border-radius: 4px 4px 0px 0px; background-position: 3px 4px; background-repeat: no-repeat; background-image: url('data:image/gif;base64,R0lGODlhBwAEAIABAFlZWf///yH5BAEAAAEALAAAAAAHAAQAQAIHjGEHi9oMCwA7');} ::-webkit-scrollbar-button:decrement:active {background-image: url('data:image/gif;base64,R0lGODlhBwAEAIABAECW7v///yH5BAEAAAEALAAAAAAHAAQAQAIHjGEHi9oMCwA7')} ::-webkit-scrollbar-button:increment {border-radius: 0px 0px 4px 4px; background-position: 3px 5px; background-repeat: no-repeat; background-image: url('data:image/gif;base64,R0lGODlhBwAEAIABAFlZWf///yH5BAEAAAEALAAAAAAHAAQAQAIIhA8Rp4u9WgEAOw==');} ::-webkit-scrollbar-button:increment:active {background-image: url('data:image/gif;base64,R0lGODlhBwAEAIABAECW7v///yH5BAEAAAEALAAAAAAHAAQAQAIIhA8Rp4u9WgEAOw==')}"

	local fallbackContent = ""
	local fallbackCats = {{"entity","Entities"}, {"weapon","Weapons"}, {"map","Maps"}}
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
			txt = "<span style='color:#333; font-size:small; font-weight:bold;'>No items locally cached</span><br/><span>&#x1F641;</span>"
		end

		fallbackContent = fallbackContent .. "<div class='pillbox column'><h2 class='pillbox ' style='margin-left:auto;margin-bottom: 12px; margin-right:auto;'>" .. v[2] .. "</h2><br/>" .. txt .. "</div> "
	end

	local html = vgui.Create("DHTML", panel)
	html:Dock(FILL)
	html:SetHTML("<html><head><style>html,body{background:transparent;width:100%;height:100%;overflow:hidden;}body{height: 100%;margin: 0px;font-family: Helvetica;color: #333;display: -webkit-box;-webkit-box-orient: vertical;} #retry {width:64px; height:50px; font-size:11px; text-align:center; margin-top:10px; margin-left:4px; margin-right:4px; font-weight:bolder; cursor:pointer; display:inline-block; vertical-align:top;} #retry:hover {color:white;} #retry .navicon {background-image:url(\"asset://garrysmod/materials/cloudbox/reconnect.png\"); width: 32px; height: 32px; margin-bottom: 2px; display: inline-block; background-size: cover; background-repeat: no-repeat;} #retry:hover .navicon {background-position: -32px 0px;} .content{background:#B8E3FF;padding: 16px 0px; overflow-y: auto; -webkit-box-flex: 1; box-sizing:border-box; text-align:center;} .column_container {display:-webkit-box; webkit-box-orient: vertical;} .pillbox {background: white; -webkit-border-radius: 8px; border-radius:8px; padding: 5px 10px; overflow: hidden; margin-left: auto; margin-right: auto; width: 92%; box-sizing:border-box;} .pillbox.thin {display: inline-block; margin-left: 4%; width: auto; max-width: 92%;} .pillbox.column {width:33%; margin-left:0; margin-right:0; display:inline-block; vertical-align:top; text-align:center; -webkit-box-flex:1; background:transparent; -webkit-border-radius:0px; border-radius:0px;} .pillbox.column:not(:first-child) {border-left:1px dotted #4096ee;} .pillbox.column:not(:last-child) {border-right:1px dotted #4096ee;} .pillbox.column:nth-child(2n) {margin-top:1px;}  .pillbox:not(:last-child):not(.column) {margin-bottom: 6px;} .pillbox h2, .pillbox h3, .pillbox h4 {color: #4096ee; margin: 0; margin-bottom: 6px; margin-top:3px; } .pillbox p {font-size:13px;} .item {cursor:pointer; display:inline-block; margin-left:2.5px; margin-right:2.5px; margin-bottom:7px; width:132px;} .item .thumb {width:128px; height:100px; border:2px solid #595959; border-radius:4px; margin-bottom:1px; background-position:center;}  .item .name {font-size:11px; font-weight:bolder; text-align:center; white-space:nowrap; letter-spacing:-0.1px; text-overflow:ellipsis; overflow:hidden;} .item:hover .thumb {border-color:#4096EE;} .item:hover .name {color:#4096EE;} " .. cbScrollbarCSS .. "</style></head><body><div style='height:80px;background:#4096ee;margin-bottom:40px;'><div id='retry' onclick='cloudbox.RetryOnline();' style='float:right'><div class='navicon'></div><br>Reconnect</div> <div class='pillbox thin' style='margin-top:10px; padding: 3px 5px;   margin-left:10px; background-color:rgb(255, 226, 146); border-radius:0; color:black;'><p style='margin-top:3px; margin-bottom:3px'>You are in offline mode. Browse cached downloads or click Reconnect to go online.</p></div> </div><div class='content'> <div class='column_container'>" .. fallbackContent .. "</div> </div></body></html>")
	html:AddFunction("cloudbox", "GetPackage", RequestCloudboxDownload)
	html:AddFunction("cloudbox", "RetryOnline", function()
		timer.Simple(0.01, function() // delay to prevent crash in Awesomium. CEF doesn't require this.
			cbOnline = false
			html:Remove()
			if cbHtmlOnline then cbHtmlOnline:Remove() end
			LoadCloudbox(panel)
		end)
	end)

	cbHtmlBackground:QueueJavascript("document.getElementById('darkmode').innerText=\"\";") // offline mode doesn't support dark mode

	cbHtmlOffline = html
end

function AddCloudboxTab()
	local panel = vgui.Create("DPanel")

	local htmlBG = vgui.Create("DHTML", panel)
	htmlBG:Dock(FILL)
	htmlBG:SetHTML("<html><body><style type='text/css'>html,body{background:#B8E3FF;width:100%;height:100%;overflow:hidden;}#top{width:100%; height:86px; position:absolute;top:0;left:0;right:0;background:#4096ee;}  #topclouds {width:100%;position:absolute;top:86px; left:0; right:0; height: 40px;  background-image: url(\"asset://garrysmod/materials/cloudbox/clouds.png\");  background-color: #4096EE; -webkit-animation: swoosh 10s linear infinite;} @-webkit-keyframes swoosh {0% {background-position: 318px;} 100% {background-position: 0px;}} @-webkit-keyframes spin { 0% {-webkit-transform:rotateZ(0deg)} 100% {-webkit-transform:rotateZ(360deg)} } #load {-webkit-animation:spin 10s linear infinite; text-align:center; display:inline-block; position:absolute; top:50%; left:50%;} #load img {position:relative;}</style><style type='text/css' id='darkmode'></style><div id='top'></div><div id='topclouds'></div><div id='load'><img src=\"asset://garrysmod/materials/cloudbox/loading.png\" /></div></body></html>")

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
