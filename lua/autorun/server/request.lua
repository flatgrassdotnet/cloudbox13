net.Receive("CloudboxClientDownloadRequest", function()
	local id = net.ReadUInt(32)
	local rev = net.ReadUInt(16)

	local url = "https://api.cl0udb0x.com/packages/getgma?id=" .. id .. "&rev=" .. rev

	http.Fetch(url, PackageContentSuccess)
end)
