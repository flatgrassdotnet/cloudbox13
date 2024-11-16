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
	// client
	util.AddNetworkString("CloudboxClientDownloadRequest")
	util.AddNetworkString("CloudboxClientDownloadFinished")

	// server
	util.AddNetworkString("CloudboxServerDownloadRequest")
	util.AddNetworkString("CloudboxServerDownloadProgress")
end

if !file.IsDir("cloudbox", "DATA") then
	file.CreateDir("cloudbox")
end

if !file.IsDir("cloudbox/downloads", "DATA") then
	file.CreateDir("cloudbox/downloads")
end

function ExecuteCloudboxPackage(info)
	// if there's a script then decode it
	local script = ""
	if info["data"] then
		script = gm13ize(util.Base64Decode(info["data"]))
	end

	// execute script / change map
	local classname = "toybox_" .. info["id"]

	if SERVER and ActiveCloudboxDownloads[info["id"]]["isInclude"] then
		RunString(script)
	elseif info["type"] == "entity" then
		ENT = {}

		RunString(script)
		scripted_ents.Register(ENT, classname)

		ENT = nil
	elseif info["type"] == "weapon" then
		SWEP = {
			Primary = {},
			Secondary = {}
		}

		RunString(script)
		weapons.Register(SWEP, classname)

		SWEP = nil
	elseif info["type"] == "map" then
		if SERVER then
			local split = string.Split(info["name"], ".")
			RunConsoleCommand("changelevel", split[1])
		end
	end

	if CLIENT then
		// tell server we have it downloaded
		net.Start("CloudboxClientDownloadFinished")
		net.WriteUInt(info["id"], 32)
		net.SendToServer()
	else // server
		ActiveCloudboxDownloads[info["id"]]["requester"]:Give(classname)

		ActiveCloudboxDownloads[info["id"]] = nil
	end
end

function MountCloudboxPackage(info)
	// if client and package has no content then execute the script now
	if CLIENT and !info["content"] then ExecuteCloudboxPackage(info) return end

	// mount content, downloading first if needed
	local path = "cloudbox/downloads/" .. info["id"] .. "r" .. info["rev"] .. ".gma"
	if file.Exists(path, "DATA") then // if we have the package content locally then load it
		game.MountGMA("data/" .. path)
		if CLIENT then ExecuteCloudboxPackage(info) end
	else // otherwise get it from cloudbox
		local url = "https://api.cl0udb0x.com/packages/getgma?id=" .. info["id"] .. "&rev=" .. info["rev"]
		http.Fetch(url, function(body, size)
			if size > 0 then
				file.Write(path, body) // write to disk
				game.MountGMA("data/" .. path)
				if CLIENT then ExecuteCloudboxPackage(info) end
			end
		end)
	end
end

CreateConVar("cloudbox_userchangelevel", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Allow non-admins to changelevel to Cloudbox maps", 0, 1)
CreateConVar("cloudbox_adminonly", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Only allow admins to download from Cloudbox", 0, 1)
