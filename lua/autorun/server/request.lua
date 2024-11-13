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

function GetCloudboxDownloadProgress(id)
	local total = 0
	local done = 0

	for _, finished in pairs(ActiveCloudboxDownloads[id]["downloaders"]) do
		total = total + 1
		if finished then
			done = done + 1
		end
	end

	return done / total
end

function RegisterCloudboxDownload(id, requester)
	// get downloaders list
	local downloaders = {}
	for _, ply in ipairs(player.GetAll()) do
		downloaders[ply:SteamID()] = false
	end

	ActiveCloudboxDownloads[id] = {["requester"] = requester, ["downloaders"] = downloaders}

	// tell clients they need to start downloading this
	net.Start("CloudboxServerDownloadRequest")
	net.WriteUInt(id, 32)
	net.Broadcast()

	if file.Exists("cloudbox/downloads/" .. id .. ".gma", "DATA") then
		MountCloudboxPackage(id)
	else
		local url = "https://api.cl0udb0x.com/packages/getgma?id=" .. id
		http.Fetch(url, PackageContentSuccess)
	end
end

function NotifyCloudboxDownloadProgress(id, progress)
	net.Start("CloudboxServerDownloadProgress")
	net.WriteUInt(id, 32)
	net.WriteFloat(progress)
	net.Broadcast()
end

net.Receive("CloudboxClientDownloadRequest", function(_, ply)
	local id = net.ReadUInt(32)

	RegisterCloudboxDownload(id, ply)
end)

net.Receive("CloudboxClientDownloadFinished", function(_, ply)
	local id = net.ReadUInt(32)

	ActiveCloudboxDownloads[id]["downloaders"][ply:SteamID()] = true

	progress = GetCloudboxDownloadProgress(id)

	NotifyCloudboxDownloadProgress(id, progress)

	if progress == 1 then
		DownloadCloudboxScript(id)
	end
end)
