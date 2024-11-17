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

module("filecb")

function Append(filename, contents) file.Append(filename, contents) end

function CreateDir(dir) file.CreateDir(dir) end

function Delete(filename) return file.Delete(filename, "DATA") end

function Exists(filename, usebasefolder)
	local path = "DATA" if usebasefolder then path = "GAME" end
	return file.Exists(filename, path)
end

function ExistsEx(filename, addons) return file.Exists(filename, "DATA") end

function Find(filename, usebasefolder)
	local path = "DATA" if usebasefolder then path = "GAME" end
	return file.Find(filename, path)
end

function FindDir(dirname, usebasefolder)
	local path = "DATA" if usebasefolder then path = "GAME" end
	local _, dirs = file.Find(dirname, path)
	return dirs
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
