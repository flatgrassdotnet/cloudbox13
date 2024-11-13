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
	util.AddNetworkString("CloudboxServerDownloadFinished")
end

if !file.IsDir("cloudbox", "DATA") then
	file.CreateDir("cloudbox")
end

if !file.IsDir("cloudbox/downloads", "DATA") then
	file.CreateDir("cloudbox/downloads")
end

ActiveCloudboxDownloads = {}

function DownloadCloudboxScript(id)
	local url = "https://api.cl0udb0x.com/packages/get?id=" .. id
	http.Fetch(url, PackageScriptSuccess)
end

function MountCloudboxPackage(id)
	local filename = "cloudbox/downloads/" .. id .. ".gma"

	if file.Exists(filename, "DATA") then
		game.MountGMA("data/" .. filename)
	end

	if CLIENT then
		DownloadCloudboxScript(id)
	end
end

function PackageContentSuccess(body, size, headers)
	local id = headers["x-package-id"]

	// if there's content, write it to disk
	if size > 0 then
		local filename = "cloudbox/downloads/" .. id .. ".gma"
		file.Write(filename, body)
	end

	MountCloudboxPackage(id)
end

function PackageScriptSuccess(body, size, headers)
	local info = util.JSONToTable(body)

	// if there's a script then decode it
	local script = ""
	if info["data"] then
		script = util.Base64Decode(info["data"])
	end

	// execute script / change map
	local classname = "toybox_" .. info["id"]

	if info["type"] == "entity" then
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
		if SERVER and ActiveCloudboxDownloads[info["id"]]["requester"]:IsAdmin() then
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
		// tell requester everyone has it downloaded
		net.Start("CloudboxServerDownloadFinished")
		net.WriteString(info["type"])
		net.WriteUInt(info["id"], 32)
		net.Send(ActiveCloudboxDownloads[info["id"]]["requester"])

		ActiveCloudboxDownloads[info["id"]] = nil
	end
end
