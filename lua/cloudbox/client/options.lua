hook.Add("AddToolMenuCategories", "AddCloudboxOptionsCategory", function()
	spawnmenu.AddToolCategory("Options", "Cloudbox", "Cloudbox")
end)

hook.Add("PopulateToolMenu", "AddCloudboxOptions", function()
	spawnmenu.AddToolMenuOption("Options", "Cloudbox", "CloudboxUser", "User", "", "", function(panel)
		panel:ClearControls()

		panel:CheckBox("Show Cloudbox chat message on join", "cloudbox_showjoinmessage")

		panel:Help("Enter offline mode to view cached downloads")
		panel:Button("Offline Mode", "cloudbox_localmode")

		panel:Help("Clear local downloads cache")
		panel:Button("Delete Downloads", "cloudbox_purgecache"):SetTextColor(Color(255, 0, 0))
	end)

	if game.SinglePlayer() then return end

	spawnmenu.AddToolMenuOption("Options", "Cloudbox", "CloudboxServer", "Server", "", "", function(panel)
		panel:ClearControls()

		panel:CheckBox("Allow non-admins to changelevel to Cloudbox maps", "cloudbox_userchangelevel")
		panel:CheckBox("Only allow admins to download from Cloudbox", "cloudbox_adminonly")

		panel:Help("Clear server's local download cache")
		panel:Button("Delete Downloads", "sv_cloudbox_purgecache"):SetTextColor(Color(255, 0, 0))
	end)
end)
