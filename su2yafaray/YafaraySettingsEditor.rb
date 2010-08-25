# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place - Suite 330, Boston, MA 02111-1307, USA, or go to
# http://www.gnu.org/copyleft/lesser.txt.
#-----------------------------------------------------------------------------
# This file is part of su2yafaray
#
# Authors, see su2yafaray.rb

class YafaraySettingsEditor

def initialize

	pref_key="YafaraySettingsEditor"
	@settings_dialog=UI::WebDialog.new("YafaRay Render Settings", false,pref_key,300,500, 10,10,true)
	@settings_dialog.max_width = 1000
	setting_html_path = Sketchup.find_support_file "settings.html" ,"Plugins/su2yafaray"
	@settings_dialog.set_file(setting_html_path)
	@ys=YafaraySettings.new
	@settings_dialog.add_action_callback("param_generate") {|dialog, params|
			p params
			pair=params.split("=")
			id=pair[0]		   
			value=pair[1]
			case id
				when "width"
					@ys.width=value
					change_aspect_ratio(@ys.width.to_f / @ys.height.to_f)
				when "height"
					@ys.height=value
					change_aspect_ratio(@ys.width.to_f / @ys.height.to_f)
				#aa_settings	
				when "aa_passes"
					@ys.aa_passes=value
				when "aa_samples"
					@ys.aa_samples=value
				when "aa_pixelwidth"
					@ys.aa_pixelwidth=value
				when "filter_type"
					@ys.filter_type=value
				when "aa_threshold"
					@ys.aa_threshold=value
				when "aa_inc_samples"
					@ys.aa_inc_samples=value
				#general settings
				when "raydepth"
					@ys.raydepth=value
				when "clayrender"
					@ys.clayrender=true if value=="true"
					@ys.clayrender=false if value=="false"
				when "z_channel"
					@ys.z_channel=true if value=="true"
					@ys.z_channel=false if value=="false"
				when "transpShad"
					@ys.transpShad=true if value=="true"
					@ys.transpShad=false if value=="false"	
				when "shadowDepth"
					@ys.shadowDepth=value
				when "transpShad"
					@ys.transpShad=true if value=="true"
					@ys.transpShad=false if value=="false"
				when "auto_threads"
					@ys.auto_threads=true if value=="true"
					@ys.auto_threads=false if value=="false"
					setValue("threads",@ys.threads)
				when "threads"
					@ys.threads=value
				#output settings
				when "gamma"
					@ys.gamma=value
				when "gamma_input"
					@ys.gamma_input=value
				when "premult"
					@ys.premult=true if value=="true"
					@ys.premult=false if value=="false"
				when "clamp_rgb"
					@ys.clamp_rgb=true if value=="true"
					@ys.clamp_rgb=false if value=="false"
				
				### method of lighting
				when "light_type"
					@ys.light_type=value
				#debug	
				when "debugType"
					@ys.debugType=value
				when "showPN"
					@ys.showPN=true if value=="true"
					@ys.showPN=false if value=="false"
				#pathtracing
				when "bounces"
					@ys.bounces=value
				when "caustic_depth"
					@ys.caustic_depth=value
				when "caustic_mix"
					@ys.caustic_mix=value
				when "caustic_radius"
					@ys.caustic_radius=value
				when "caustic_type"
					@ys.caustic_type=value
				when "no_recursive"
					@ys.no_recursive=true if value=="true"
					@ys.no_recursive=false if value=="false"	
				when "path_samples"
					@ys.path_samples=value	
				when "photons"
					@ys.photons=value
				#photon mapping
				when "finalGather"
					@ys.finalGather=true if value=="true"
					@ys.finalGather=false if value=="false"
				when "fg_bounces"
					@ys.fg_bounces=value
				when "fg_samples"
					@ys.fg_samples=value
				when "show_map"
					@ys.show_map=true if value=="true"
					@ys.show_map=false if value=="false"
				when 'pm_bounces'
					@ys.pm_bounces=value
				when 'pm_photons'
					@ys.pm_photons=value
				when 'cPhotons'
					@ys.cPhotons=value
				when 'diffuseRadius'
					@ys.diffuseRadius=value
				when 'causticRadius'
					@ys.causticRadius=value
				when 'search'
					@ys.search=value
				when 'pm_caustic_mix'
					@ys.pm_caustic_mix=value
				#direct lighting
				when "caustics"
					@ys.caustics=true if value=="true"
					@ys.caustics=false if value=="false"
				when "do_AO"
					@ys.do_AO=true if value=="true"
					@ys.do_AO=false if value="false"
				#camera
				when "camera_type"
					@ys.camera_type=value
				#background
				when "background_type"
					@ys.background_type=value
				when "turbidity"
					@ys.turbidity=value
				when "a_var"
					@ys.a_var=value
				when "b_var"
					@ys.b_var=value
				when "c_var"
					@ys.c_var=value
				when "d_var"
					@ys.d_var=value
				when "e_var"
					@ys.e_var=value
			end	
	} #end action callback param_generatate
	


	#import and export settings from/to file
	# # Callback to load a file into the editor
        # add_action_callback("load") do |dlg, params|
          # p @snip_dir
          # file = UI.openpanel("Open File", @snip_dir, "*.rb")
          # return unless file
          # name = File.basename(file)
          # @file = file
          # dlg.execute_script("$('#save_name').text('#{name}')")
          # dlg.execute_script("$('#save_filename').val('#{name}')")
          # if params != "true"
            # dlg.execute_script(%/document.getElementById('console').value=""/)
          # end
          # f = File.new(file,"r")
          # text = f.readlines.join
          # text.gsub!(/\n/, "\\n")
          # text.gsub!(/\r/, "\\r")
          # text.gsub!(/'/, "\\\\'")
          # dlg.execute_script("document.getElementById('console').value = '#{text}'")
        # end # callback


        # # Callback to save a file (and create a backup)
        # add_action_callback("save") do |dlg, params|
          # filename = dlg.get_element_value("save_filename")
          # file = UI.savepanel("Save File", @snip_dir, filename)
          # return if file.nil?
          # name = File.basename(file)
          # str=dlg.get_element_value("console")
          # str.gsub!(/\r\n/, "\n")
          # # Save backup as well if file exists
          # if File.exist?(file) and params == 'true'
            # f = File.new(file,"r")
            # oldfile = f.readlines
            # File.open(file+".bak", "w") { |f| f.puts oldfile }
          # end
          # File.open(file, "w") { |f| f.puts str }
          # dlg.execute_script("$('#save_name').text('#{name}')")
          # dlg.execute_script("$('#save_filename').val('#{name}')")
          # dlg.execute_script("c = false;")
        # end # callback
	
	
	
	
	
	
	# @setting_dialog.add_action_callback("refresh") {|dialog,params|
	# p 'refresh'
	# SendDataFromSketchup()
	# }
	
	# @settings_dialog.add_action_callback("get_view_size") { |dialog, params|
		# width = (Sketchup.active_model.active_view.vpwidth)
		# height = (Sketchup.active_model.active_view.vpheight)
		# setValue("xresolution", width)
		# setValue("yresolution", height)
		# @lrs.xresolution = width
		# @lrs.yresolution = height
		# change_aspect_ratio(0.0)
	# }

	# @settings_dialog.add_action_callback("set_image_size") { |dialog, params|
		# values = params.split('x')
		# width = values[0].to_i
		# height = values[1].to_i
		# setValue("xresolution", width)
		# setValue("yresolution", height)
		# @lrs.xresolution = width
		# @lrs.yresolution= height
		# change_aspect_ratio(width.to_f / height.to_f)
	# }
	
	# @settings_dialog.add_action_callback("scale_view") { |dialog, params|
		# values = params.split('x')
		# width = values[0].to_i
		# height = values[1].to_i
		# setValue("xresolution", width)
		# setValue("yresolution", height)
		# @lrs.xresolution = width
		# @lrs.yresolution = height
	# }
	
	
	# @settings_dialog.add_action_callback("open_dialog") {|dialog, params|
  # case params.to_s
		# when "new_export_file_path"
			# SU2LUX.new_export_file_path
	# end #end case
	# } #end action callback open_dialog
end


def show
	@settings_dialog.show{SendDataFromSketchup()}
end

#set parameters in inputs of settings.html
def SendDataFromSketchup()
	p 'send data from su'
	setValue("width",@ys.width)
	setValue("height",@ys.height)
	setValue("aa_passes",@ys.aa_passes)
	setValue("aa_threshold",@ys.aa_threshold)
	setValue("aa_inc_samples",@ys.aa_inc_samples)
	setValue("aa_samples",@ys.aa_samples)
	setValue("aa_pixelwidth",@ys.aa_pixelwidth)
	setValue("filter_type",@ys.filter_type)
	setValue("raydepth",@ys.raydepth)
	setValue("shadowDepth",@ys.shadowDepth)
	setCheckbox("clayrender",@ys.clayrender)
	setCheckbox("z_channel",@ys.z_channel)
	setCheckbox("transpShad",@ys.transpShad)
	p @ys.auto_threads
	setCheckbox("auto_threads",@ys.auto_threads)
	
	setValue("gamma",@ys.gamma)
	setValue("gamma_input",@ys.gamma_input)
	setCheckbox("clamp_rgb",@ys.clamp_rgb)
	setCheckbox("premult",@ys.premult)
	
	setValue("light_type",@ys.light_type)
	#debug
	setValue("debugType",@ys.debugType)
	setCheckbox("showPN",@ys.showPN)
	#pathtracing
	setValue("caustic_type",@ys.caustic_type)
	setValue("photons",@ys.photons)
	setValue("caustic_mix",@ys.caustic_mix)
	setValue("caustic_depth",@ys.caustic_depth)
	setValue("caustic_radius",@ys.caustic_radius)
	setValue("bounces",@ys.bounces)
	setValue("path_samples",@ys.path_samples)
	setCheckbox("no_recursive",@ys.no_recursive)
	#photon_mapping
	setCheckbox("finalGather",@ys.finalGather)
	setValue("fg_bounces",@ys.fg_bounces)
	setValue("fg_samples",@ys.fg_samples)
	setCheckbox("show_map",@ys.show_map)
	setValue("pm_bounces",@ys.pm_bounces)
	setValue("pm_photons",@ys.pm_photons)
	setValue("cPhotons",@ys.cPhotons)
	setValue("diffuseRadius",@ys.diffuseRadius)
	setValue("causticRadius",@ys.causticRadius)
	setValue("search",@ys.search)
	setValue("pm_caustic_mix",@ys.pm_caustic_mix)
	#direct_lighting
	setCheckbox("do_AO",@ys.do_AO)
	setCheckbox("caustics",@ys.caustics)
	#camera
	setValue("camera_type",@ys.camera_type)
	setValue("background_type",@ys.background_type)
	
	##########background
	#sunsky
	setValue("a_var",@ys.a_var)
	setValue("b_var",@ys.a_var)
	setValue("c_var",@ys.a_var)
	setValue("d_var",@ys.a_var)
	setValue("e_var",@ys.a_var)
	setValue("turbidity",@ys.turbidity)
end 

def setValue(id,value)
	new_value=value.to_s
	#cmd="$('##{id}').val('#{new_value}'); $('##{id}').next('div').text($('##{id}').prev('label').text()+$('##{id}').val());" #after set value need update input field
	cmd="$('##{id}').val('#{new_value}'); $('##{id}').change();"
	p cmd
	@settings_dialog.execute_script(cmd)
end

def change_aspect_ratio(aspect_ratio)
	current_camera = Sketchup.active_model.active_view.camera
	current_ratio = current_camera.aspect_ratio
	current_ratio = 1.0 if current_ratio == 0.0
	
	new_ratio = aspect_ratio
	
	if(current_ratio != new_ratio)
		current_camera.aspect_ratio = new_ratio
		new_ratio = 1.0 if new_ratio == 0.0
		scale = current_ratio / new_ratio.to_f
		fov = current_camera.fov
		current_camera.focal_length = current_camera.focal_length * scale
	end
end

def setCheckbox(id,value)
	
	if value
		cmd="$('##{id}').attr('checked', 'checked'); $('##{id}').change();"
	else
		cmd="$('##{id}').removeAttr('checked'); $('##{id}').change();"
	end
	p cmd
	@settings_dialog.execute_script(cmd)
end

def change_aspect_ratio(aspect_ratio)
	current_camera = Sketchup.active_model.active_view.camera
	current_ratio = current_camera.aspect_ratio
	current_ratio = 1.0 if current_ratio == 0.0
	
	new_ratio = aspect_ratio
	
	if(current_ratio != new_ratio)
		current_camera.aspect_ratio = new_ratio
		new_ratio = 1.0 if new_ratio == 0.0
		scale = current_ratio / new_ratio.to_f
		if current_camera.perspective?
			fov = current_camera.fov
			current_camera.focal_length = current_camera.focal_length * scale
		end
	end
end


end #end class YafaraySettingsEditor	