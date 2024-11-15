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

	local htmlBG = vgui.Create("DHTML", panel)
	htmlBG:Dock(FILL)
	htmlBG:SetHTML("<style type='text/css'>html,body{background:#B8E3FF;width:100%;height:100%;overflow:hidden;}#top{width:100%; height:86px; position:absolute;top:0;left:0;right:0;background:#4096ee;} #topclouds {width:100%;position:absolute;top:86px; left:0; right:0; height: 40px;  background-image: url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' preserveAspectRatio='none' x='0px' y='0px' width='318px' height='40px' viewBox='0 0 318 40'%3E%3Cdefs%3E%3Cg id='Symbol_1_0_Layer0_0_FILL'%3E%3Cpath fill='%23B8E3FF' stroke='none' d='M 318 40.1 L 318 23.7 Q 317.265234375 14.282421875 311.85 8.1 306.485546875 1.9638671875 295.65 2.6 284.865625 3.2451171875 279.4 16 277.2279296875 7.325390625 266.45 9.2 255.722265625 11.071484375 254.4 19.7 248.0794921875 14.203515625 240.1 15.2 232.1705078125 16.246484375 229.25 22.2 227.3853515625 11.9029296875 218.15 8.3 208.9048828125 4.7490234375 201.25 7.75 193.55 10.7 190.8 19.7 184.75 13.1 176.1 14.4 167.4 15.65 165.65 22.2 163.6 15.15 157.3 10.6 150.95 6 142 6.95 133.05 7.85 130.15 13.75 127.5 6.5 119 2 110.45 -2.55 99.4 3.25 88.35 9.05 85.4 22.2 81.55 14.7 73.3 15.2 65 15.65 63.4 23.7 60.15 5.55 45.1 6.25 30.05 6.95 25.15 22.2 22.95 17.05 14.4 15.7 5.8 14.3 0 23.3 L 0 40.1 318 40.1 Z'/%3E%3C/g%3E%3C/defs%3E%3Cg transform='matrix( 1, 0, 0, 1, 0,0) '%3E%3Cg transform='matrix( 1, 0, 0, 1, 0,0) '%3E%3Cuse xlink:href='%23Symbol_1_0_Layer0_0_FILL'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E\");  background-color: #4096EE; -webkit-animation: swoosh 10s linear infinite;} @-webkit-keyframes swoosh {0% {background-position: 318px;} 100% {background-position: 0px;}} @-webkit-keyframes spin { 0% {-webkit-transform:rotateZ(0deg)} 100% {-webkit-transform:rotateZ(360deg)} } #load {-webkit-animation:spin 10s linear infinite; text-align:center; background:#fe7; width:24px; height:24px; color:#999; font-size:16px; font-family:arial; font-weight:bold; border-radius:3px; display:inline-block; border:2px solid #999; position:absolute; top:50%; left:50%;} </style><div id='top'></div><div id='topclouds'></div><div id='load'>:v</div>")

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
