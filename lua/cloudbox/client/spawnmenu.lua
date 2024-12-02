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

	html.OnChangeTitle = function(_, title)
		if not (not cbOnline and title == "Cloudbox") then return end

		cbOnline = true
		html:SetVisible(true)

		if cbHtmlOffline != nil then cbHtmlOffline:Remove() end
	end

	timer.Simple(5, function() if not cbOnline then LoadCloudboxOffline(panel) end end)

	cbHtmlOnline = html
end

function LoadCloudboxOffline(panel)
	if cbHtmlOnline != nil then cbHtmlOnline:SetVisible(false) end

	local cbHomeIcon = "data:image/png;base64,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"
	// ^ PNG image of the Cloudbox Home icon

	local cbItemFallback = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' preserveAspectRatio='none' x='0px' y='0px' width='128px' height='128px' viewBox='0 0 128 128'%3E%3Cdefs%3E%3Cg id='missing_3_Layer3_0_FILL'%3E%3Cpath fill='%2365C2FF' stroke='none' d='M 0 128 L 128 128 128 0 0 0 0 128 Z'/%3E%3C/g%3E%3Cg id='missing_3_Layer2_0_FILL'%3E%3Cpath fill='%2392D2FF' stroke='none' d='M 105.7 74.65 Q 90.25 74.05 83.35 90 77.7 82.15 71.75 82.25 L 71.15 97.1 61.1 103.05 51.1 96.4 50.2 87.6 Q 47.55 89.4 45.9 93.7 45.95 84.15 37.9 82.4 29.8 80.65 24.15 89.1 21.9 63.3 0 67.35 L 0 128 128 128 128 67.4 Q 124.05 60.15 115.35 61.85 106.85 63.35 105.7 74.65 Z'/%3E%3Cpath fill='%232C89E9' stroke='none' d='M 128 33.55 L 128 0 0 0 0 35.1 Q 4.25 25.65 12.95 27.75 21.6 29.85 20.7 42.2 26.9 32.9 34.5 33.85 42.1 34.75 45.95 41.2 52.7 32.55 61.9 33.7 71.1 34.85 75.25 41.25 78.8 34.25 86.4 35.45 94 36.65 95.25 44.35 95.35 37.95 100.25 36.75 105.15 35.6 108.15 40.15 105.85 30.05 114.7 27.7 123.5 25.35 128 33.55 Z'/%3E%3C/g%3E%3Cg id='missing_3_Layer0_0_FILL'%3E%3Cpath fill='%23ADDDFF' stroke='none' d='M 52.6 87.5 L 60.55 90.85 69.7 87.35 60.85 85 52.6 87.5 M 86.2 57.5 L 92.9 43.2 60.6 28.15 35.15 46.35 43.2 56.35 61.6 43.95 75.9 50.15 74.5 55.9 56.95 61.6 56.6 63.25 Q 68.65 64.3 86.2 57.5 Z'/%3E%3Cpath fill='%239BD6FF' stroke='none' d='M 52.6 87.5 L 53.9 95.55 61.3 99.85 68.6 96.3 69.7 87.35 60.55 90.85 52.6 87.5 M 85.2 60.35 L 86.2 57.5 Q 68.65 64.3 56.6 63.25 L 53.35 78.9 69.05 80.5 65.9 65.5 85.2 60.35 Z'/%3E%3C/g%3E%3C/defs%3E%3Cg transform='matrix( 1, 0, 0, 1, 0,0) '%3E%3Cg transform='matrix( 1, 0, 0, 1, 0,0) '%3E%3Cuse xlink:href='%23missing_3_Layer3_0_FILL'/%3E%3C/g%3E%3Cg transform='matrix( 1, 0, 0, 1, 0,0) '%3E%3Cuse xlink:href='%23missing_3_Layer2_0_FILL'/%3E%3C/g%3E%3Cg transform='matrix( 1, 0, 0, 1, 0,0) '%3E%3Cuse xlink:href='%23missing_3_Layer0_0_FILL'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E"
	// ^ SVG image used for item thumbnails when the online image isn't available

	local cbScrollbarCSS = "::-webkit-scrollbar {background-color: #4096EE; border-radius: 4px;} ::-webkit-scrollbar-button, ::-webkit-scrollbar-thumb {background-color: white; border: 2px solid #595959;} ::-webkit-scrollbar-button:hover, ::-webkit-scrollbar-thumb:hover {background-color: #B8E3FF;} ::-webkit-scrollbar-button:active, ::-webkit-scrollbar-thumb:active {border-color: #4096EE;} ::-webkit-scrollbar-button:decrement {border-radius: 4px 4px 0px 0px; background-position: 3px 4px; background-repeat: no-repeat; background-image: url('data:image/gif;base64,R0lGODlhBwAEAIABAFlZWf///yH5BAEAAAEALAAAAAAHAAQAQAIHjGEHi9oMCwA7');} ::-webkit-scrollbar-button:decrement:active {background-image: url('data:image/gif;base64,R0lGODlhBwAEAIABAECW7v///yH5BAEAAAEALAAAAAAHAAQAQAIHjGEHi9oMCwA7')} ::-webkit-scrollbar-button:increment {border-radius: 0px 0px 4px 4px; background-position: 3px 5px; background-repeat: no-repeat; background-image: url('data:image/gif;base64,R0lGODlhBwAEAIABAFlZWf///yH5BAEAAAEALAAAAAAHAAQAQAIIhA8Rp4u9WgEAOw==');} ::-webkit-scrollbar-button:increment:active {background-image: url('data:image/gif;base64,R0lGODlhBwAEAIABAECW7v///yH5BAEAAAEALAAAAAAHAAQAQAIIhA8Rp4u9WgEAOw==')}"

	local fallbackContent = ""
	local fallbackCats = {{"entity","Entities"}, {"weapon","Weapons"}, {"map","Maps"}}
	local fallbackCatsList = {entity = "", weapon = "", map = ""}

	local cachedFiles = file.Find("cloudbox/downloads/*.json", "DATA")
	for _, filename in pairs(cachedFiles) do
		local meta = util.JSONToTable(file.Read("cloudbox/downloads/" .. filename))
		local str = "<a onclick='cloudbox.GetPackage(\"offline\", " .. tonumber(meta["id"]) .. "  ,  " .. tonumber(meta["rev"]) .. " )' class='item'><div class='thumb' style=\"background-image:url('http://img.cl0udb0x.com/" .. tonumber(meta["id"]) .. "_thumb_128.png'), url(&quot;" .. cbItemFallback .. "&quot;)\"></div><div class='name'>" .. string.gsub(meta["name"], "[><]", "") .. "</div></a>"

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
	html:SetHTML("<html><head><style>html,body{background:transparent;width:100%;height:100%;overflow:hidden;}body{height: 100%;margin: 0px;font-family: Helvetica;color: #333;display: -webkit-box;-webkit-box-orient: vertical;} #retry {width:64px; height:50px; font-size:11px; text-align:center; margin-top:10px; margin-left:4px; margin-right:4px; font-weight:bolder; cursor:pointer; display:inline-block; vertical-align:top;} #retry:hover {color:white;} #retry .navicon {background-image:url(\"" .. cbHomeIcon .. "\"); width: 32px; height: 32px; margin-bottom: 2px; display: inline-block; background-size: cover; background-repeat: no-repeat;} #retry:hover .navicon {background-position: -32px 0px;} .content{background:#B8E3FF;padding: 16px 0px; overflow-y: auto; -webkit-box-flex: 1; box-sizing:border-box; text-align:center;} .column_container {display:-webkit-box; webkit-box-orient: vertical;} .pillbox {background: white; -webkit-border-radius: 8px; border-radius:8px; padding: 5px 10px; overflow: hidden; margin-left: auto; margin-right: auto; width: 92%; box-sizing:border-box;} .pillbox.thin {display: inline-block; margin-left: 4%; width: auto; max-width: 92%;} .pillbox.column {width:33%; margin-left:0; margin-right:0; display:inline-block; vertical-align:top; text-align:center; -webkit-box-flex:1; background:transparent; -webkit-border-radius:0px; border-radius:0px;} .pillbox.column:not(:first-child) {border-left:1px dotted #4096ee;} .pillbox.column:not(:last-child) {border-right:1px dotted #4096ee;} .pillbox.column:nth-child(2n) {margin-top:1px;}  .pillbox:not(:last-child):not(.column) {margin-bottom: 6px;} .pillbox h2, .pillbox h3, .pillbox h4 {color: #4096ee; margin: 0; margin-bottom: 6px; margin-top:3px; } .pillbox p {font-size:13px;} .item {cursor:pointer; display:inline-block; margin-left:2.5px; margin-right:2.5px; margin-bottom:7px; width:132px;} .item .thumb {width:128px; height:100px; border:2px solid #595959; border-radius:4px; margin-bottom:1px; background-position:center;}  .item .name {font-size:11px; font-weight:bolder; text-align:center; white-space:nowrap; letter-spacing:-0.1px; text-overflow:ellipsis; overflow:hidden;} .item:hover .thumb {border-color:#4096EE;} .item:hover .name {color:#4096EE;} " .. cbScrollbarCSS .. "</style></head><body><div style='height:80px;background:#4096ee;margin-bottom:40px;'><div id='retry' onclick='cloudbox.RetryOnline();' style='float:right'><div class='navicon'></div><br>Reconnect</div> <div class='pillbox thin' style='margin-top:10px; padding: 3px 5px;   margin-left:10px; background-color:rgb(255, 226, 146); border-radius:0; color:black;'><p style='margin-top:3px; margin-bottom:3px'>You are in offline mode. Browse cached downloads or click Reconnect to go online.</p></div> </div><div class='content'> <div class='column_container'>" .. fallbackContent .. "</div> </div></body></html>")
	html:AddFunction("cloudbox", "GetPackage", RequestCloudboxDownload)
	html:AddFunction("cloudbox", "RetryOnline", function()
		timer.Simple(0.01, function() // delay to prevent crash in Awesomium. CEF doesn't require this.
			cbOnline = false
			html:Remove()
			if cbHtmlOnline != nil then cbHtmlOnline:Remove() end
			LoadCloudbox(panel)
		end)
	end)

	cbHtmlOffline = html
end

function AddCloudboxTab()
	local panel = vgui.Create("DPanel")

	local cbCloud = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' preserveAspectRatio='none' x='0px' y='0px' width='318px' height='40px' viewBox='0 0 318 40'%3E%3Cdefs%3E%3Cg id='Symbol_1_0_Layer0_0_FILL'%3E%3Cpath fill='%23B8E3FF' stroke='none' d='M 318 40.1 L 318 23.7 Q 317.265234375 14.282421875 311.85 8.1 306.485546875 1.9638671875 295.65 2.6 284.865625 3.2451171875 279.4 16 277.2279296875 7.325390625 266.45 9.2 255.722265625 11.071484375 254.4 19.7 248.0794921875 14.203515625 240.1 15.2 232.1705078125 16.246484375 229.25 22.2 227.3853515625 11.9029296875 218.15 8.3 208.9048828125 4.7490234375 201.25 7.75 193.55 10.7 190.8 19.7 184.75 13.1 176.1 14.4 167.4 15.65 165.65 22.2 163.6 15.15 157.3 10.6 150.95 6 142 6.95 133.05 7.85 130.15 13.75 127.5 6.5 119 2 110.45 -2.55 99.4 3.25 88.35 9.05 85.4 22.2 81.55 14.7 73.3 15.2 65 15.65 63.4 23.7 60.15 5.55 45.1 6.25 30.05 6.95 25.15 22.2 22.95 17.05 14.4 15.7 5.8 14.3 0 23.3 L 0 40.1 318 40.1 Z'/%3E%3C/g%3E%3C/defs%3E%3Cg transform='matrix( 1, 0, 0, 1, 0,0) '%3E%3Cg transform='matrix( 1, 0, 0, 1, 0,0) '%3E%3Cuse xlink:href='%23Symbol_1_0_Layer0_0_FILL'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E"
	// ^ SVG image of a cloud, used for the background

	local cbLoading = "data:image/png;base64,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"
	// ^ PNG image of the loading icon

	local htmlBG = vgui.Create("DHTML", panel)
	htmlBG:Dock(FILL)
	htmlBG:SetHTML("<style type='text/css'>html,body{background:#B8E3FF;width:100%;height:100%;overflow:hidden;}#top{width:100%; height:86px; position:absolute;top:0;left:0;right:0;background:#4096ee;}  #topclouds {width:100%;position:absolute;top:86px; left:0; right:0; height: 40px;  background-image: url(\"" .. cbCloud .. "\");  background-color: #4096EE; -webkit-animation: swoosh 10s linear infinite;} @-webkit-keyframes swoosh {0% {background-position: 318px;} 100% {background-position: 0px;}} @-webkit-keyframes spin { 0% {-webkit-transform:rotateZ(0deg)} 100% {-webkit-transform:rotateZ(360deg)} } #load {-webkit-animation:spin 10s linear infinite; text-align:center; display:inline-block; position:absolute; top:50%; left:50%;} #load img {position:relative;}</style><div id='top'></div><div id='topclouds'></div><div id='load'><img src=\"" .. cbLoading .. "\" /></div>")

	LoadCloudbox(panel)

	concommand.Add("cloudbox_localmode", function()
		cbOnline = true
		LoadCloudboxOffline(panel)
		spawnmenu.SwitchCreationTab("Cloudbox")
	end)

	return panel
end

spawnmenu.AddCreationTab("Cloudbox", AddCloudboxTab, "materials/icon16/weather_clouds.png", 999, "Download stuff from Cloudbox!")
