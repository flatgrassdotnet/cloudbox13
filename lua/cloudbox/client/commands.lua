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

concommand.Add("cloudbox_getpackage", function(_, _, args)
	if !args[1] and !isnumber(args[1]) then
		print("A package ID is required")
		return
	end

	if args[2] and !isnumber(args[2]) then
		print("Invalid revision")
		return
	end

	RequestCloudboxDownload("", args[1], args[2])
end, nil, "Download a package from Cloudbox by ID and (optionally) revision")

concommand.Add("cloudbox_purgecache", function()
	files = file.Find("cloudbox/downloads/*", "DATA")
	for _, filename in pairs(files) do
		file.Delete("cloudbox/downloads/" .. filename, "DATA")
	end
end, nil, "Purge the Cloudbox downloads cache")
