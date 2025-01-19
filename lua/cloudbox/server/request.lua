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

ActiveCloudboxDownloads = {}

function GetCloudboxDownloadProgress(id)
	local done = 0

	for _, finished in pairs(ActiveCloudboxDownloads[id]["downloaders"]) do
		if finished then done = done + 1 end
	end

	return done / #ActiveCloudboxDownloads[id]["downloaders"]
end

function BroadcastCloudboxPackageDownload(info, requester)
	local data = util.Compress(util.TableToJSON(info))

	net.Start("CloudboxServerDownloadRequest")
	net.WriteUInt(string.len(data), 16)
	net.WriteData(data)
	net.WriteString(requester:SteamID64())
	net.Broadcast()
end

function LoadCloudboxPackage(info, requester, isInclude)
	isInclude = isInclude or false

	if info["type"] == "map" and !GetConVar("cloudbox_userchangelevel"):GetBool() and !requester:IsAdmin() then
		print("User \"" .. requester:Name() .. "\" (" .. requester:SteamID64() .. ") tried to changelevel to a Cloudbox map without permission.")
		return
	end

	// experimental includes support
	if info["includes"] then
		for _, inc in pairs(info["includes"]) do
			RegisterCloudboxDownload(inc["id"], inc["rev"], requester, true)
		end
	end

	// get downloaders list
	local downloaders = {}
	for _, ply in ipairs(player.GetAll()) do
		downloaders[ply:SteamID()] = false
	end

	// register
	ActiveCloudboxDownloads[info["id"]] = {["info"] = info, ["requester"] = requester, ["downloaders"] = downloaders, ["isInclude"] = isInclude}

	// tell everyone to start downloading the package
	BroadcastCloudboxPackageDownload(info, requester)

	MountCloudboxPackage(info)
end

function RegisterCloudboxDownload(id, rev, requester, isInclude)
	isInclude = isInclude or false

	local path = "cloudbox/downloads/" .. id .. "r" .. rev .. ".json"
	if file.Exists(path, "DATA") then // if we have the package info locally then load it
		LoadCloudboxPackage(util.JSONToTable(file.Read(path)), requester, isInclude)
	else // otherwise get it from cloudbox
		local url = "https://api.cl0udb0x.com/packages/get?id=" .. id .. "&rev=" .. rev
		http.Fetch(url, function(body, size)
			if size == 0 then return end // something broke

			file.Write(path, body) // write to disk
			LoadCloudboxPackage(util.JSONToTable(body), requester, isInclude)
		end)
	end
end

function NotifyCloudboxDownloadProgress(id, progress)
	net.Start("CloudboxServerDownloadProgress")
	net.WriteUInt(id, 32)
	net.WriteFloat(progress)
	net.Broadcast()
end

net.Receive("CloudboxClientDownloadRequest", function(_, ply)
	if GetConVar("cloudbox_adminonly"):GetBool() and !ply:IsAdmin() then return end

	local id = net.ReadUInt(32)
	local rev = net.ReadUInt(32)

	RegisterCloudboxDownload(id, rev, ply)
end)

net.Receive("CloudboxClientDownloadFinished", function(_, ply)
	local id = net.ReadUInt(32)

	if !ActiveCloudboxDownloads[id] then return end

	ActiveCloudboxDownloads[id]["downloaders"][ply:SteamID()] = true

	progress = GetCloudboxDownloadProgress(id)

	NotifyCloudboxDownloadProgress(id, progress)

	if progress == 1 then
		ExecuteCloudboxPackage(ActiveCloudboxDownloads[id]["info"])
	end
end)
