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
	// server
	include("cloudbox/server/commands.lua")
	include("cloudbox/server/request.lua")

	// client
	AddCSLuaFile("cloudbox/client/commands.lua")
	AddCSLuaFile("cloudbox/client/joinmessage.lua")
	AddCSLuaFile("cloudbox/client/request.lua")
	AddCSLuaFile("cloudbox/client/spawnmenu.lua")

	// shared
	AddCSLuaFile("cloudbox/shared/cloudbox.lua")
	AddCSLuaFile("cloudbox/shared/compatibility.lua")
end

if CLIENT then
	include("cloudbox/client/commands.lua")
	include("cloudbox/client/joinmessage.lua")
	include("cloudbox/client/request.lua")
	include("cloudbox/client/spawnmenu.lua")
end

include("cloudbox/shared/cloudbox.lua")
include("cloudbox/shared/compatibility.lua")