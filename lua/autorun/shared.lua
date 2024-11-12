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

if SERVER then
	util.AddNetworkString("CloudboxClientDownloadRequest")
	util.AddNetworkString("CloudboxServerDownloadRequest")
end

if !file.IsDir("cloudbox", "DATA") then
	file.CreateDir("cloudbox")
end

if !file.IsDir("cloudbox/downloads", "DATA") then
	file.CreateDir("cloudbox/downloads")
end

function PackageContentSuccess(body, size, headers)
	local id = headers["x-package-id"]
	local rev = headers["x-package-revision"]

	if SERVER then
		net.Start("CloudboxServerDownloadRequest")
		net.WriteUInt(id, 32)
		net.WriteUInt(rev, 16)
		net.Broadcast()
	end

	if size > 0 then
		local filename = "cloudbox/downloads/" .. id .. "r" .. rev .. ".gma"

		file.Write(filename, body)
		game.MountGMA("data/" .. filename)

		if headers["x-package-type"] == "map" then
			local split = string.Split(headers["x-package-name"], ".")
			RunConsoleCommand("changelevel", split[1])
		end
	end

	local url = "https://api.cl0udb0x.com/packages/get?id=" .. id .. "&rev=" .. rev
	http.Fetch(url, PackageScriptSuccess)
end

function PackageScriptSuccess(body, size, headers)
	local info = util.JSONToTable(body)

	// if there's no script then stop
	if !info["data"] then
		return
	end

	local script = util.Base64Decode(info["data"])
	local classname = "toybox_" .. info["id"]

	if info["type"] == "entity" then
		ENT = {}

		RunString(script)
		scripted_ents.Register(ENT, classname)

		ENT = nil

		if CLIENT then
			RunConsoleCommand("gm_spawnsent", classname)
			surface.PlaySound("ui/buttonclickrelease.wav")
		end
	elseif info["type"] == "weapon" then
		SWEP = {
			Primary = {},
			Secondary = {}
		}

		RunString(script)
		weapons.Register(SWEP, classname)

		SWEP = nil

		if CLIENT then
			RunConsoleCommand("gm_giveswep", classname)
			surface.PlaySound("ui/buttonclickrelease.wav")
		end
	end
end
