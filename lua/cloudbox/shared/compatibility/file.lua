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

local file = file
local string = string

module("filecb")

function Append(filename, contents) file.Append(filename, contents) end

function CreateDir(dir) file.CreateDir(dir) end

function Delete(filename) return file.Delete(filename, "DATA") end

function Exists(filename, usebasefolder)
	local path = "DATA" if usebasefolder then path = "GAME" end
	local ex = file.Exists(filename, path)
	if not ex and string.EndsWith(filename, ".wav") then // TF2 fix
		ex = Exists(string.Replace(filename, ".wav", ".mp3"), usebasefolder)
	end

	return ex
end

function ExistsEx(filename, addons) return file.Exists(filename, "DATA") end

local function FindCommon(filename, usebasefolder, dir)
	local path = "DATA"
	if usebasefolder then
		path = "GAME"
	elseif string.StartsWith(filename, "../") then
		filename = string.sub(filename, 4)
		path = "GAME"
	end

	local files, dirs = file.Find(filename, path)
	if not dir and files == nil and string.EndsWith(filename, ".wav") then // TF2 fix
		files = FindCommon(string.Replace(filename, ".wav", ".mp3"), usebasefolder, false)
	end

	if dir then return dirs else return files end
end

function Find(filename, usebasefolder)
	return FindCommon(filename, usebasefolder, false)
end

function FindDir(dirname, usebasefolder)
	return FindCommon(dirname, usebasefolder, true)
end

function FindInLua(filename) return file.Find(filename, "LUA") end

function IsDir(filename, usebasefolder)
	local path = "DATA" if usebasefolder then path = "GAME" end
	return file.IsDir(filename, path)
end

function Read(filepath, usebasefolder)
	local path = "DATA" if usebasefolder then path = "GAME" end
	return file.Read(filepath, path)
end

function Size(filepath, usebasefolder)
	local path = "DATA" if usebasefolder then path = "GAME" end
	return file.Size(filepath, path)
end

function TFind(path, func)
	local files, dirs = file.Find(path, "GAME")
	func(path, files, dirs)
end

function Time(filename, usebasefolder)
	local path = "DATA" if usebasefolder then path = "GAME" end
	return file.Time(filename, path)
end

function Write(filename, contents) return file.Write(filename, contents) end
