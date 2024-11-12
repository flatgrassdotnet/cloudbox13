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

function IsCloudboxDownloadFinished(id)
	for _, finished in pairs(ActiveCloudboxDownloads[id]["downloaders"]) do
		// if someone isn't done then we're not finished
		if !finished then
			return false
		end
	end

	// otherwise it's done
	return true
end

function RegisterCloudboxDownload(id, requester)
	// get downloaders list
	local downloaders = {}
	for _, ply in ipairs(player.GetAll()) do
		downloaders[ply:SteamID()] = false
	end

	ActiveCloudboxDownloads[id] = {["requester"] = requester, ["downloaders"] = downloaders}

	if file.Exists("cloudbox/downloads/" .. id .. ".gma", "DATA") then
		MountCloudboxPackage(id)
	else
		local url = "https://api.cl0udb0x.com/packages/getgma?id=" .. id
		http.Fetch(url, PackageContentSuccess)
	end
end

net.Receive("CloudboxClientDownloadRequest", function(_, ply)
	local id = net.ReadUInt(32)

	RegisterCloudboxDownload(id, ply)
end)

net.Receive("CloudboxClientDownloadFinished", function(_, ply)
	local id = net.ReadUInt(32)

	ActiveCloudboxDownloads[id]["downloaders"][ply:SteamID()] = true

	if IsCloudboxDownloadFinished(id) then
		local url = "https://api.cl0udb0x.com/packages/get?id=" .. id
		http.Fetch(url, PackageScriptSuccess)
	end
end)
