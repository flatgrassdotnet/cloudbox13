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

CloudboxContentDownloads = {}
local Main = nil

function UpdatePackageDownloadStatus(pid, id, name, f, status, size)
	if !Main then
		Main = vgui.Create("DContentMain", GetHUDPanel())
	end

	local p = CloudboxContentDownloads[pid]

	if !p then
		CloudboxContentDownloads[pid] = {}
	end

	local dl = CloudboxContentDownloads[pid][id]

	if !dl then
		dl = vgui.Create("DContentDownload", Main)
		dl.Velocity = Vector(0, 0, 0)
		//dl:SetAlpha(10) // starts mostly transparent because it's waiting for download progress, we can't do this on cloudbox
		CloudboxContentDownloads[pid][id] = dl
	end

	dl:Update(f, name, size)

	if status == "success" then
		dl:Bounce()
		CloudboxContentDownloads[pid][id] = nil
		surface.PlaySound("garrysmod/content_downloaded.wav")

		timer.Simple(2, function() dl:Remove() end)
	end

	if status == "failed" then
		dl:Failed()
		CloudboxContentDownloads[pid][id] = nil
		surface.PlaySound("garrysmod/content_downloaded.wav")

		timer.Simple(2, function() dl:Remove() end)
	end

	Main:OnActivity(CloudboxContentDownloads)
end
