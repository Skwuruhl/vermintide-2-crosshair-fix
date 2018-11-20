return {
	run = function()
		fassert(rawget(_G, "new_mod"), "crosshairs must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("crosshairs", {
			mod_script       = "scripts/mods/crosshairs/crosshairs",
			mod_data         = "scripts/mods/crosshairs/crosshairs_data",
			mod_localization = "scripts/mods/crosshairs/crosshairs_localization"
		})
	end,
	packages = {
		"resource_packages/crosshairs/crosshairs"
	}
}
