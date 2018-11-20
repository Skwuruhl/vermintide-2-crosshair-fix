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

	local maximum_pitch = SpreadTemplates.maximum_pitch
	local maximum_yaw = SpreadTemplates.maximum_yaw
	local pitch_percentage = pitch
	local yaw_percentage = yaw
	local pitch_offset = math.lerp(0, definitions.max_spread_pitch, pitch_percentage)
	local yaw_offset = math.lerp(0, definitions.max_spread_yaw, yaw_percentage)

	self:draw(dt, pitch_percentage, yaw_percentage)
end)

mod:hook_origin(CrosshairUI, "draw_default_style_crosshair", function (self, ui_renderer, pitch_percentage, yaw_percentage)
	local camera_manager = Managers.state.camera
	local fieldOfView = (camera_manager:has_viewport("player_1") and camera_manager:fov("player_1")) or 1

	local num_points = 4
	local start_degrees = 45
	local pitch_offset = 0
	local yaw_offset = 0
	pitch_percentage = math.max(0.0001, pitch_percentage)
	yaw_percentage = math.max(0.0001, yaw_percentage)
	pitch_percentage = 1080 * math.tan(math.rad(pitch_percentage)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_line.size[1]/2
	yaw_percentage = 1080 * math.tan(math.rad(yaw_percentage)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_line.size[1]/2

	for i = 1, num_points, 1 do
		self:_set_widget_point_offset(self.crosshair_line, i, num_points, pitch_percentage, yaw_percentage, start_degrees, pitch_offset, yaw_offset)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_line)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)
end)

mod:hook_origin(CrosshairUI, "draw_arrows_style_crosshair", function (self, ui_renderer, pitch_percentage, yaw_percentage)
	local camera_manager = Managers.state.camera
	local fieldOfView = (camera_manager:has_viewport("player_1") and camera_manager:fov("player_1")) or 1

	local num_points = 4
	local start_degrees = 45
	local pitch_offset = 0
	local yaw_offset = 0
	pitch_percentage = math.max(0.0001, pitch_percentage)
	yaw_percentage = math.max(0.0001, yaw_percentage)
	pitch_percentage = 1080 * math.tan(math.rad(pitch_percentage)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_arrow.size[1]/2
	yaw_percentage = 1080 * math.tan(math.rad(yaw_percentage)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_arrow.size[1]/2

	for i = 1, num_points, 1 do
		self:_set_widget_point_offset(self.crosshair_arrow, i, num_points, pitch_percentage, yaw_percentage, start_degrees, pitch_offset, yaw_offset)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_arrow)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)
end)

mod:hook_origin(CrosshairUI, "draw_shotgun_style_crosshair", function (self, ui_renderer, pitch_percentage, yaw_percentage)
	local camera_manager = Managers.state.camera
	local fieldOfView = (camera_manager:has_viewport("player_1") and camera_manager:fov("player_1")) or 1

	local num_points = 4
	local start_degrees = 45
	local pitch_offset = 0
	local yaw_offset = 0
	pitch_percentage = math.max(0.0001, pitch_percentage)
	yaw_percentage = math.max(0.0001, yaw_percentage)
	pitch_percentage = 1080 * math.tan(math.rad(pitch_percentage)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_shotgun.size[1]/2
	yaw_percentage = 1080 * math.tan(math.rad(yaw_percentage)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_shotgun.size[1]/2

	for i = 1, num_points, 1 do
		self:_set_widget_point_offset(self.crosshair_shotgun, i, num_points, pitch_percentage, yaw_percentage, start_degrees, pitch_offset, yaw_offset)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_shotgun)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)
end)

mod:hook_origin(CrosshairUI, "draw_projectile_style_crosshair", function (self, ui_renderer, pitch_percentage, yaw_percentage)
	local camera_manager = Managers.state.camera
	local fieldOfView = (camera_manager:has_viewport("player_1") and camera_manager:fov("player_1")) or 1

	local num_points = 2
	local start_degrees = 0
	local pitch_offset = 0
	local yaw_offset = 0
	pitch_percentage = math.max(0.0001, pitch_percentage)
	yaw_percentage = math.max(0.0001, yaw_percentage)
	pitch_percentage = 1080 * math.tan(math.rad(pitch_percentage)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_line.size[1]/2
	yaw_percentage = 1080 * math.tan(math.rad(yaw_percentage)/2)/math.tan(fieldOfView/2) + definitions.scenegraph_definition.crosshair_line.size[1]/2

	for i = 1, num_points, 1 do
		self:_set_widget_point_offset(self.crosshair_line, i, num_points, pitch_percentage, yaw_percentage, start_degrees, pitch_offset, yaw_offset)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_line)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)
	UIRenderer.draw_widget(ui_renderer, self.crosshair_projectile)
end)

mod:hook_origin(CrosshairUI, "_get_point_offset", function (self, point_index, max_points, pitch_percentage, yaw_percentage, start_degrees)
	local x = 0
	local y = 0
	local start_progress = ((start_degrees or 0) / 360) % 1
	local real_index = point_index - 1
	local fraction = real_index / max_points
	local rotation_progress = (start_progress + fraction) % 1
	local degress = rotation_progress * 360
	local angle = -((degress * math.pi) / 180)
	local pty = y + pitch_percentage * math.sin(angle)
	local ptx = x + yaw_percentage * math.cos(angle)

	return ptx, pty, angle
end)

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
