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

function RequestCloudboxDownload(type, id, rev)
	// sometimes GetConVar returns nil here
	local adminonly = GetConVar("cloudbox_adminonly")
	if adminonly and adminonly:GetBool() and !LocalPlayer():IsAdmin() then
		notification.AddLegacy("Sorry, you must be an admin to do that!", NOTIFY_ERROR, 3)
		surface.PlaySound("buttons/button10.wav")
		return
	end

	if type == "savemap" then
		notification.AddLegacy("Sorry, save loading isn't finished!", NOTIFY_ERROR, 3)
		surface.PlaySound("buttons/button10.wav")
		return
	end

	if type == "map" and !GetConVar("cloudbox_userchangelevel"):GetBool() and !LocalPlayer():IsAdmin() then
		notification.AddLegacy("Sorry, you must be an admin to do that!", NOTIFY_ERROR, 3)
		surface.PlaySound("buttons/button10.wav")
		return
	end

	surface.PlaySound("garrysmod/content_downloaded.wav")

	net.Start("CloudboxClientDownloadRequest")
	net.WriteUInt(id, 32)
	net.WriteUInt(rev, 32)
	net.SendToServer()
end

net.Receive("CloudboxServerDownloadRequest", function()
	local size = net.ReadUInt(16)
	local data = net.ReadData(size)
	local steamid = net.ReadString()

	local requester = player.GetBySteamID64(steamid)
	local info = util.JSONToTable(util.Decompress(data))

	// register
	ActiveCloudboxDownloads[info["id"]] = {["info"] = info, ["requester"] = requester}

	notification.AddProgress("CloudboxPackageDownload" .. info["id"], "Downloading \"" .. info["name"] .. "\"")

	timer.Create("CloudboxNotificationKiller" .. info["id"], 30, 1, function()
		notification.Kill("CloudboxPackageDownload" .. info["id"])
	end)

	MountCloudboxPackage(info)
end)

net.Receive("CloudboxServerDownloadProgress", function()
	local id = net.ReadUInt(32)
	local progress = net.ReadFloat()

	notification.AddProgress("CloudboxPackageDownload" .. id, "Downloading \"" .. ActiveCloudboxDownloads[id]["info"]["name"] .. "\"", progress)

	if progress == 1 then
		notification.Kill("CloudboxPackageDownload" .. id)
		timer.Remove("CloudboxNotificationKiller" .. id)

		// if it's not us
		if ActiveCloudboxDownloads[id]["requester"]:SteamID64() != LocalPlayer():SteamID64() then
			// unregister
			ActiveCloudboxDownloads[id] = nil
		end
	end
end)

net.Receive("CloudboxServerDownloadFinished", function()
	local id = net.ReadUInt(32)

	local type = ActiveCloudboxDownloads[id]["info"]["type"]
	local classname = "toybox_" .. id

	if type == "weapon" then
		RunConsoleCommand("gm_giveswep", classname)
	elseif type == "entity" then
		RunConsoleCommand("gm_spawnsent", classname)
	end

	surface.PlaySound("ui/buttonclickrelease.wav")

	// unregister
	ActiveCloudboxDownloads[id] = nil
end)
