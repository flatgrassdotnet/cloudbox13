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

function RequestCloudboxDownload(type, id, rev)
	if type == "savemap" then
		notification.AddLegacy("Sorry, save loading isn't finished!", NOTIFY_ERROR, 3)
		surface.PlaySound("buttons/button10.wav")
		return
	end

	if type == "map" and !LocalPlayer():IsAdmin() then
		notification.AddLegacy("Sorry, only admins can change map!", NOTIFY_ERROR, 3)
		surface.PlaySound("buttons/button10.wav")
		return
	end

	surface.PlaySound("garrysmod/content_downloaded.wav")

	net.Start("CloudboxClientDownloadRequest")
	net.WriteUInt(id, 32)
	net.SendToServer()
end

net.Receive("CloudboxServerDownloadRequest", function()
	local id = net.ReadUInt(32)

	notification.AddProgress("CloudboxPackageDownload" .. id, "Downloading...")

	timer.Create("CloudboxNotificationKiller" .. id, 30, 1, function()
		notification.Kill("CloudboxPackageDownload" .. id)
	end)

	if file.Exists("cloudbox/downloads/" .. id .. ".gma", "DATA") then
		MountCloudboxPackage(id)
	else
		local url = "https://api.cl0udb0x.com/packages/getgma?id=" .. id
		http.Fetch(url, PackageContentSuccess)
	end
end)

net.Receive("CloudboxServerDownloadProgress", function()
	local id = net.ReadUInt(32)
	local progress = net.ReadFloat()

	notification.AddProgress("CloudboxPackageDownload" .. id, "Downloading...", progress)

	if progress == 1 then
		notification.Kill("CloudboxPackageDownload" .. id)
		timer.Remove("CloudboxNotificationKiller" .. id)
	end
end)

net.Receive("CloudboxServerDownloadFinished", function()
	local type = net.ReadString()
	local id = net.ReadUInt(32)

	local classname = "toybox_" .. id

	if type == "weapon" then
		RunConsoleCommand("gm_giveswep", classname)
	elseif type == "entity" then
		RunConsoleCommand("gm_spawnsent", classname)
	end

	surface.PlaySound("ui/buttonclickrelease.wav")
end)
