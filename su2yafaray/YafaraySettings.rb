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

class YafaraySettings


@@settings=
{
	#'name_option'=>'default_value'
	'width'=>640,
	'height'=>480,
	'aa_passes'=>'1',
	'aa_samples'=>'1',
	'aa_pixelwidth'=>'1.5',
	'filter_type'=>'box',
	'aa_inc_samples'=>'1',
	'aa_threshold'=>'0.05',
	
	'raydepth'=>'2',
	'z_channel'=>false,
	'transpShad'=>false,
	'clayrender'=>false,
	'shadowDepth'=>'64',
	'auto_threads'=>true,
	'threads'=>'1',
	'gamma'=>'1.8',
	'gamma_input'=>'1.8',
	'clamp_rgb'=>false,
	'premult'=>false,
	
	#method of lighting
	'light_type'=>"directlighting",
	#debug
	'debugType'=>6,
	'showPN'=>false,
	#pathtracing
	'bounces'=>'8',
	'caustic_depth'=>'10',
	'caustic_mix'=>'100',
	'caustic_radius'=>'0.1',
	'caustic_type'=>"none",
	'no_recursive'=>false,
	'path_samples'=>'37',
	'photons'=>"500000",
	#photon mapping
	'finalGather'=>true,
	'fg_bounces'=>'3',
	'fg_samples'=>'16',
	'show_map'=>false,
	'pm_bounces'=>'5',
	'pm_photons'=>'500000',
	'cPhotons'=>'500000',
	'diffuseRadius'=>'1.000',
	'causticRadius'=>'1.000',
	'search'=>'100',
	'pm_caustic_mix'=>'100',
	
	#direct light
	'caustics'=>false,
	'do_AO'=>false,
	#camera
	'camera_type'=>'perspective',
	
	#background
	'background_type'=>'sunsky'
	
}

def initialize
	singleton_class = (class << self; self; end)
	@model=Sketchup.active_model
	@view=@model.active_view
	@dict="Yafaray_settings"
	
	@@settings.each do |key, value|
		singleton_class.module_eval do
			define_method(key) { @model.get_attribute(@dict,key,value) }
			define_method("#{key}=") { |new_value| @model.set_attribute(@dict,key,new_value) }
		end
	end
end

end #end class YafaraySettings