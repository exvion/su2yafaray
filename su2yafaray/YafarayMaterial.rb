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

class YafarayMaterial
	#@@dict="yafaray_materials"
	#@@type="shinydiffusemat"
	
	@@options=
	{
	'type'=>"shinydiffusemat",
	'IOR'=>"1.51",
	'diffuse_brdf'=>"lambert",
	'diffuse_reflect'=>"1",
	'emit'=>'0',
	'fresnel_effect'=>true,
	# #'mirror_color' =
	'sigma'=>'0.1',
	'specular_reflect'=>'0',
	'translucency'=>'0',
	'transmit_filter'=>'1',
	'transparency'=>'0',
	'absorption_dist'=>'1.00',
	'exponent'=>'500.00',
	'dispersion_power'=>'0.00',
	'glossy_reflect'=>'0'
	}
	
	
	attr_reader :mat
def initialize(su_material)
	@mat=su_material
	@model=Sketchup.active_model
	@view=@model.active_view
	@dict="yafaray_material"
	
	@@options.each do |key, value|
		YafarayMaterial.module_eval do
			define_method(key) {@mat.get_attribute(@dict,key,value) }
			define_method("#{key}=") { |new_value| @mat.set_attribute(@dict,key,new_value) }
		end
	end
end

def name
	return mat.display_name.gsub(/[<>]/, '*')  #replaces <> characters with *
end
 
end #end class YafarayMaterial