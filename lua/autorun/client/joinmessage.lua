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
