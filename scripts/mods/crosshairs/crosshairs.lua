local mod = get_mod("crosshairs")
local definitions = local_require("scripts/ui/views/crosshair_ui_definitions")

-- changed function to use raw pitch and yaw instead of x_percentage, which was just pitch/yaw divided by 15.
-- also removed an unused offset variable?
mod:hook_origin(CrosshairUI, "update_spread", function (self, dt, t, equipment)
	Profiler.start("update_spread")
	local wielded_item_data = equipment.wielded
	local item_template = BackendUtils.get_item_template( wielded_item_data )
	local pitch, yaw = 0, 0

	if item_template.default_spread_template then
		local weapon_unit = equipment.right_hand_wielded_unit or equipment.left_hand_wielded_unit

		if weapon_unit then
			if ScriptUnit.has_extension( weapon_unit, "spread_system" ) then
				local spread_extension = ScriptUnit.extension(weapon_unit, "spread_system")

				pitch, yaw = spread_extension:get_current_pitch_and_yaw()
			end
		end
	end

	Profiler.stop("update_spread")

	self:draw(dt, t, pitch, yaw)
end)

-- I removed all pitch/yaw_offsets as it's broken and I'm accounting for crosshair size using the crosshair_size variable instead.
-- I also moved "UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)" to draw last as that ensures it's on top of crosshairs instead of under them for 0 spread.
-- removed "x_percentage = math.max(0.0001, x_percentage)" since crosshairs are being offset by their length anyway. Will only break if Fatshark changes crosshairs to have a length of zero (which?? why??)
mod:hook_origin(CrosshairUI, "draw_default_style_crosshair", function (self, ui_renderer, pitch, yaw)
	local num_points = 4
	local start_degrees = 45
	local crosshair_size = definitions.scenegraph_definition.crosshair_line.size[1]-- used instead of pitch/yaw_offset.

	for i = 1, num_points do
		self:_set_widget_point_offset(self.crosshair_line, i, num_points, pitch, yaw, start_degrees, crosshair_size)-- changed to pass just crosshair_size instead of offsets
		UIRenderer.draw_widget(ui_renderer, self.crosshair_line)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)-- moved to the bottom from top of function so that dot is drawn on top of lines.
end)

mod:hook_origin(CrosshairUI, "draw_arrows_style_crosshair", function (self, ui_renderer, pitch, yaw)
	local num_points = 4
	local start_degrees = 45
	local crosshair_size = definitions.scenegraph_definition.crosshair_arrow.size[1]

	for i = 1, num_points do
		self:_set_widget_point_offset(self.crosshair_arrow, i, num_points, pitch, yaw, start_degrees, crosshair_size)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_arrow)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)
end)

mod:hook_origin(CrosshairUI, "draw_shotgun_style_crosshair", function (self, ui_renderer, pitch, yaw)
	local num_points = 4
	local start_degrees = 45
	local crosshair_size = definitions.scenegraph_definition.crosshair_shotgun.size[1]

	for i = 1, num_points do
		self:_set_widget_point_offset(self.crosshair_shotgun, i, num_points, pitch, yaw, start_degrees, crosshair_size)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_shotgun)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)
end)

mod:hook_origin(CrosshairUI, "draw_projectile_style_crosshair", function (self, ui_renderer, pitch, yaw)
	local num_points = 2
	local start_degrees = 0
	local crosshair_size = definitions.scenegraph_definition.crosshair_line.size[1]

	for i = 1, num_points do
		self:_set_widget_point_offset(self.crosshair_line, i, num_points, pitch, yaw, start_degrees, crosshair_size)
		UIRenderer.draw_widget(ui_renderer, self.crosshair_line)
	end
	UIRenderer.draw_widget(ui_renderer, self.crosshair_dot)
	UIRenderer.draw_widget(ui_renderer, self.crosshair_projectile)-- also moved to bottom just because
end)

-- updated for replacing of offsets with crosshair_size
mod:hook_origin(CrosshairUI, "_set_widget_point_offset", function (self, widget, point_index, max_points, pitch, yaw, start_degrees, crosshair_size)
	local ptx, pty, angle = self:_get_point_offset(point_index, max_points, pitch, yaw, start_degrees, crosshair_size)
	local widget_style = widget.style
	local offset = widget_style.offset
	local pivot = widget_style.pivot
	offset[1] = ptx
	offset[2] = pty
	widget_style.angle = -angle
end)

-- removed max_radius as it's just 228 (pixels), I use 1080 instead since that's vertical screen distance.
-- 
mod:hook_origin(CrosshairUI, "_get_point_offset", function (self, point_index, max_points, pitch, yaw, start_degrees, crosshair_size)
	local camera_manager = Managers.state.camera
	local viewport_name = Managers.player:local_player().viewport_name
	local fieldOfView = (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1-- needed to calculate crosshair spread based on current FOV.
	local pty = 1080 * math.tan(math.rad(pitch)/2)/math.tan(fieldOfView/2) + crosshair_size/2.0-- 1 is equal to 1 pixel on a 1080p monitor and gets scaled for resolution, e.g. a 2160p (4k) monitor would have 2 pixels per 1 radius.
	local ptx = 1080 * math.tan(math.rad(yaw)/2)/math.tan(fieldOfView/2) + crosshair_size/2.0-- 1080 * tan(spread/2)/tan(vertical fov/2) + half crosshair length. This makes the crosshairs scale with the tangent of spread instead of linearly. Plus halved crosshair_size since crosshair coordinates set their center.
	local hud_scale = RESOLUTION_LOOKUP.scale * 1080 / RESOLUTION_LOOKUP.res_h
	pty = pty / hud_scale
	ptx = ptx / hud_scale
	local start_progress = ((start_degrees or 0) / 360) % 1
	local real_index = point_index - 1
	local fraction = real_index / max_points
	local rotation_progress = (start_progress + fraction) % 1
	local degress = rotation_progress * 360
	local angle = -((degress * math.pi) / 180)
	pty = pty * math.sin(angle)
	ptx = ptx * math.cos(angle)

	return ptx, pty, angle
end)

--
--Unable to make the circle crosshair scale since it's just a static image with no input variables (that I know of)
--