local mod = get_mod("crosshairs")
local definitions = local_require("scripts/ui/views/crosshair_ui_definitions")

-- Everything here is optional, feel free to remove anything you're not using

--[[
	Functions
--]]

-- "Private" function - not accessible to other mods
--local function my_function()

--end

-- "Public" function - accessible to other mods
--function mod.my_function()

--end


--[[
	Hooks
--]]

-- If you simply want to call a function after SomeObject.some_function has been executed
-- Arguments for SomeObject.some_function will be passed to my_function as well
--mod:hook_safe(SomeObject, "some_function", my_function)

-- If you want to do something more involved\

--changed function to use raw pitch and yaw instead of x_percentage
mod:hook_origin(CrosshairUI, "update_spread", function (self, dt, equipment)
	local wielded_item_data = equipment.wielded
	local item_template = BackendUtils.get_item_template(wielded_item_data)
	local pitch = 0
	local yaw = 0

	if item_template.default_spread_template then
		local weapon_unit = equipment.right_hand_wielded_unit or equipment.left_hand_wielded_unit

		if weapon_unit and ScriptUnit.has_extension(weapon_unit, "spread_system") then
			local spread_extension = ScriptUnit.extension(weapon_unit, "spread_system")
			pitch, yaw = spread_extension:get_current_pitch_and_yaw()
		end
	end

	self:draw(dt, pitch, yaw)
end)

--for the draw_x_style_crosshair functions I had to move the calculations of pitch_radius and yaw_radius from _get_point_offset into the draw_x_style_crosshair so that I could account for each crosshair type's different sizes without changing the inputs of the _get_point_offset function
--I also set all pitch/yaw_offsets to 0 as it's broken and I'm accounting for crosshair size using " + definitions.scenegraph_definition.crosshair_x.size[1]/2" instead.
--I also moved "UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)" to draw last as that ensures it's on top of crosshairs instead of under them for 0 spread.

mod:hook_origin(CrosshairUI, "draw_default_style_crosshair", function (self, ui_renderer, pitch, yaw)
	local camera_manager = Managers.state.camera
	local viewport_name = Managers.player:local_player().viewport_name
	local fieldOfView = (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1 --needed to call current field of view (important that it's current and not just configured FOV)

	local num_points = 4
	local start_degrees = 45
	local pitch_offset = 0 -- 0 on all spreads since it's broken
	local yaw_offset = 0 -- offset is added manually in x_radius line
	pitch = math.max(0, pitch)--changed from min of 0.0001 to 0 since my offset in the next lines puts it above 0 anyway. Will only ever break if Fatshark make a crosshair have a length of 0 pixels.
	yaw = math.max(0, yaw)
	local pitch_radius = 1080 * math.tan(math.rad(pitch)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_line.size[1]/2 --1  radius is equal to 1 pixel on a 1080p monitor and gets scaled for resolution, e.g. a 4k monitor would have 2 pixels per 1 radius.
	local yaw_radius = 1080 * math.tan(math.rad(yaw)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_line.size[1]/2--1080 * tan(spread/2)/tan(vertical fov/2) + half crosshair length

	for i = 1, num_points, 1 do
		self:_set_widget_point_offset(self.crosshair_line, i, num_points, pitch_radius, yaw_radius, start_degrees, pitch_offset, yaw_offset)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_line)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)--moved to the bottom from top of function
end)

mod:hook_origin(CrosshairUI, "draw_arrows_style_crosshair", function (self, ui_renderer, pitch, yaw)
	local camera_manager = Managers.state.camera
	local viewport_name = Managers.player:local_player().viewport_name
	local fieldOfView = (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1

	local num_points = 4
	local start_degrees = 45
	local pitch_offset = 0
	local yaw_offset = 0
	pitch = math.max(0, pitch)
	yaw = math.max(0, yaw)
	local pitch_radius = 1080 * math.tan(math.rad(pitch)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_arrow.size[1]/2
	local yaw_radius = 1080 * math.tan(math.rad(yaw)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_arrow.size[1]/2

	for i = 1, num_points, 1 do
		self:_set_widget_point_offset(self.crosshair_arrow, i, num_points, pitch_radius, yaw_radius, start_degrees, pitch_offset, yaw_offset)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_arrow)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)
end)

mod:hook_origin(CrosshairUI, "draw_shotgun_style_crosshair", function (self, ui_renderer, pitch, yaw)
	local camera_manager = Managers.state.camera
	local viewport_name = Managers.player:local_player().viewport_name
	local fieldOfView = (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1

	local num_points = 4
	local start_degrees = 45
	local pitch_offset = 0
	local yaw_offset = 0
	pitch = math.max(0, pitch)
	yaw = math.max(0, yaw)
	local pitch_radius = 1080 * math.tan(math.rad(pitch)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_shotgun.size[1]/2
	local yaw_radius = 1080 * math.tan(math.rad(yaw)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_shotgun.size[1]/2

	for i = 1, num_points, 1 do
		self:_set_widget_point_offset(self.crosshair_shotgun, i, num_points, pitch_radius, yaw_radius, start_degrees, pitch_offset, yaw_offset)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_shotgun)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)
end)

mod:hook_origin(CrosshairUI, "draw_projectile_style_crosshair", function (self, ui_renderer, pitch, yaw)
	local camera_manager = Managers.state.camera
	local viewport_name = Managers.player:local_player().viewport_name
	local fieldOfView = (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1

	local num_points = 2
	local start_degrees = 0
	local pitch_offset = 0
	local yaw_offset = 0
	pitch = math.max(0.0001, pitch)
	yaw = math.max(0.0001, yaw)
	local pitch_radius = 1080 * math.tan(math.rad(pitch)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_line.size[1]/2
	local yaw_radius = 1080 * math.tan(math.rad(yaw)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_line.size[1]/2

	for i = 1, num_points, 1 do
		self:_set_widget_point_offset(self.crosshair_line, i, num_points, pitch_radius, yaw_radius, start_degrees, pitch_offset, yaw_offset)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_line)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)
	UIRenderer.draw_widget(ui_renderer, self.crosshair_projectile) --also moved to bottom just because
end)


--removed max_radius as it was used in calculating radius which is already done. It was also 228 pixels instead of 1080 pixels which is just not useful.
--obviously also removed calculation of pitch/yaw_radius
mod:hook_origin(CrosshairUI, "_get_point_offset", function (self, point_index, max_points, pitch_radius, yaw_radius, start_degrees)
	local x = 0
	local y = 0
	local start_progress = ((start_degrees or 0) / 360) % 1
	local real_index = point_index - 1
	local fraction = real_index / max_points
	local rotation_progress = (start_progress + fraction) % 1
	local degress = rotation_progress * 360
	local angle = -((degress * math.pi) / 180)
	local pty = y + pitch_radius * math.sin(angle)
	local ptx = x + yaw_radius * math.cos(angle)

	return ptx, pty, angle
end)

--
--Unable to make the circle crosshair scale since it's just a static image with no input variables (that I know of)
--


--[[
	Callbacks
--]]

-- All callbacks are called even when the mod is disabled
-- Use mod:is_enabled() to check that the mod is enabled

-- Called on every update to mods
-- dt - time in milliseconds since last update
mod.update = function(dt)
	
end

-- Called when all mods are being unloaded
-- exit_game - if true, game will close after unloading
mod.on_unload = function(exit_game)
	
end

-- Called when game state changes (e.g. StateLoading -> StateIngame)
-- status - "enter" or "exit"
-- state  - "StateLoading", "StateIngame" etc.
mod.on_game_state_changed = function(status, state)
	
end

-- Called when a setting is changed in mod settings
-- Use mod:get(setting_name) to get the changed value
mod.on_setting_changed = function(setting_name)
	
end

-- Called when the checkbox for this mod is unchecked
-- is_first_call - true if called right after mod initialization
mod.on_disabled = function(is_first_call)

end

-- Called when the checkbox for this is checked
-- is_first_call - true if called right after mod initialization
mod.on_enabled = function(is_first_call)

end


--[[
	Initialization
--]]

-- Initialize and make permanent changes here
