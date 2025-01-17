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

function ExecuteCloudboxPackage(info)
	// if there's a script then decode it
	local script = ""
	if info["data"] then
		script = gm13ize(util.Base64Decode(info["data"]))
	end

	// execute script / change map
	local classname = "toybox_" .. info["id"]

	if info["type"] == "entity" then
		script = "local ENT = {}\nlocal BASE_ENT = ENT\n" .. script
		script = script .. "\nENT.Spawnable = true\nENT.AdminSpawnable = true\nscripted_ents.Register(BASE_ENT, \"" .. classname .. "\")"

		RunString(script)
	elseif info["type"] == "weapon" then
		script = "local SWEP = {Primary = {}, Secondary = {}}\nlocal BASE_SWEP = SWEP\n" .. script
		script = script .. "\nSWEP.Spawnable = true\nSWEP.AdminSpawnable = true\nweapons.Register(BASE_SWEP, \"" .. classname .. "\")"

		RunString(script)
	elseif info["type"] == "map" then
		if SERVER then
			local map = ""
			for _, content in pairs(info["content"]) do
				_, _, map = string.find(content["path"], "maps/([%w_%.%-]+)%.bsp")
				if map then break end
			end

			RunConsoleCommand("changelevel", map)
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
		net.WriteUInt(info["id"], 32)
		net.WriteBool(ActiveCloudboxDownloads[info["id"]]["isInclude"])
		net.Send(ActiveCloudboxDownloads[info["id"]]["requester"])

		ActiveCloudboxDownloads[info["id"]] = nil
	end
end

function MountCloudboxPackage(info, attempt)
	attempt = attempt or 1

	// if client and package has no content then execute the script now
	if CLIENT and !info["content"] then ExecuteCloudboxPackage(info) return end

	// mount content, downloading first if needed
	local path = "cloudbox/downloads/" .. info["id"] .. "r" .. info["rev"] .. ".gma"
	if file.Exists(path, "DATA") then // if we have the package content locally then load it
		local success = game.MountGMA("data/" .. path)
		if !success and attempt < 3 then // delete and reacquire
			file.Delete(path, "DATA") // FIXME: doesn't actually work because MountGMA doesn't release the file
			MountCloudboxPackage(info, attempt + 1)
			return
		end

		if CLIENT then ExecuteCloudboxPackage(info) end
		return
	end

	// otherwise get it from cloudbox

	local pid = info["id"] .. "r" .. info["rev"]

	// add stuff to download indicator
	if CLIENT and info["content"] then for k, v in pairs(info["content"]) do UpdatePackageDownloadStatus(pid, v["id"], v["path"], 0, "downloading", v["size"]) end end

	local url = "https://api.cl0udb0x.com/packages/getgma?id=" .. info["id"] .. "&rev=" .. info["rev"]
	http.Fetch(url, function(body, size)
		if size == 0 then return end // something broke

		file.Write(path, body) // write to disk

		local success = game.MountGMA("data/" .. path)
		if !success and attempt < 3 then // delete and reacquire
			file.Delete(path, "DATA") // FIXME: doesn't actually work because MountGMA doesn't release the file
			MountCloudboxPackage(info, attempt + 1)
			return
		end

		if !CLIENT then return end // client only after this

		local total = table.Count(CloudboxContentDownloads[pid])
		local delay = 1 / total

		// show download animation finishing
		timer.Create("CloudboxDownloadSimulator" .. pid, 0, delay, function()
			timer.Adjust("CloudboxDownloadSimulator" .. pid, delay * math.Rand(0.5, 1.5))

			for id, dl in pairs(CloudboxContentDownloads[pid]) do UpdatePackageDownloadStatus(pid, id, dl.name, 1, "success", dl.size) break end

			if !table.IsEmpty(CloudboxContentDownloads[pid]) then return end

			ExecuteCloudboxPackage(info)
			timer.Remove("CloudboxDownloadSimulator" .. pid)
			CloudboxContentDownloads[pid] = nil
		end)
	end)
end

CreateConVar("cloudbox_userchangelevel", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Allow non-admins to changelevel to Cloudbox maps", 0, 1)
CreateConVar("cloudbox_adminonly", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Only allow admins to download from Cloudbox", 0, 1)
