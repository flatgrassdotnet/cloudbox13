/*
	cloudbox13 - cloudbox client for gmod 13
	Copyright (C) 2024 - 2025  patapancakes <patapancakes@pagefault.games>

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

hook.Add("Initialize", "CloudboxJoinMessage", function()
	if !GetConVar("cloudbox_showjoinmessage"):GetBool() then return end

	chat.AddText(Color(255, 255, 255), "This server is running ", Color(184, 227, 255), "Cloudbox", Color(255, 255, 255),", the new Toybox!")
	chat.AddText(Color(255, 255, 255), "Use the ", Color(184, 227, 255), "Cloudbox", Color(255, 255, 255)," tab in the spawn menu to spawn things.")

	if file.Exists("cloudbox/seen_full_message.txt", "DATA") then return end

	chat.AddText("")
	chat.AddText(Color(255, 255, 255), "Over a thousand original Toybox uploads are available for you to use.")
	chat.AddText(Color(255, 255, 255), "Compatibility is still being improved, so please expect bugs.")
	chat.AddText("")
	chat.AddText(Color(255, 255, 255), "Check us out on the workshop for more info!")

	file.Write("cloudbox/seen_full_message.txt", "")
end)

CreateConVar("cloudbox_showjoinmessage", "1", FCVAR_ARCHIVE, "Show Cloudbox chat message on join", 0, 1)
