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

class YafarayMaterialEditor

def initialize
	pref_key="YafarayMaterialEditor"
	@material_dialog=UI::WebDialog.new("YafaRay Material Editor", false,pref_key,300,500, 10,10,true)
	@material_dialog.max_width = 1000
	material_html_path = Sketchup.find_support_file "material.html" ,"Plugins/su2yafaray"
	@material_dialog.set_file(material_html_path)
	@material_dialog.add_action_callback("param_generate") {|dialog, params|
			pair=params.split("=")
			id=pair[0]		   
			value=pair[1]
			p "#{id} changed to #{value}" 
			case id
				when "material_type"
					yafmat.type=value
				when "diffuse_reflect"
					yafmat.diffuse_reflect=value
				when "specular_reflect"
					yafmat.specular_reflect=value
				when "transparency"
					yafmat.transparency=value
				when "translucency"
					yafmat.translucency=value
				when "transmit_filter"
					yafmat.transmit_filter=value
				when "emit"
					yafmat.emit=value
				when "IOR"
					yafmat.IOR=value
				when "diffuse_brdf"
					yafmat.diffuse_brdf=value
				when "sigma"
					yafmat.sigma=value
				when "absorption_dist"
					yafmat.absorption_dist=value
				when "exponent"
					yafmat.exponent=value
				when "dispersion_power"
					yafmat.dispersion_power=value
				when "glossy_reflect"
					yafmat.glossy_reflect=value
			end
	}
end

	# def onMaterialSetCurrent(materials, material)
		# p "onMaterialSetCurrent"
		# material_editor = SU2YAFARAY.get_editor("material")

		# if (material_editor)
		# p "setCurrent material"
		# material_editor.setValue("material_name",material.name)
		# end
	# end


def show
	p "show"
	current = Sketchup.active_model.materials.current
	
	if (current)
	@yafmat=YafarayMaterial.new(current)
	@material_dialog.show{setValue("material_name",current.name);SendDataFromSketchup()}
	else
	@material_dialog.show{}
	end
	#p current.name
	#@material_dialog.show{}
end

def yafmat
	@yafmat
end

def yafmat=(new_mat)
	p "newly selected material is #{new_mat.name}"
	@yafmat=new_mat
end 

def SendDataFromSketchup()
	setValue("material_type",yafmat.type);
	setValue("diffuse_reflect",yafmat.diffuse_reflect);
	setValue("specular_reflect",yafmat.specular_reflect);
	setValue("transparency",yafmat.transparency);
	setValue("translucency",yafmat.translucency);
	setValue("transmit_filter",yafmat.transmit_filter);
	setValue("emit",yafmat.emit);
	setValue("IOR",yafmat.IOR);
	setValue("diffuse_brdf",yafmat.diffuse_brdf);
	setValue("sigma",yafmat.sigma);
	
	setValue("absorption_dist",yafmat.absorption_dist);
	setValue("exponent",yafmat.exponent);
	setValue("dispersion_power",yafmat.dispersion_power);
	setValue("glossy_reflect",yafmat.glossy_reflect);
	
end

def setValue(id,value)
	new_value=value.to_s
	#cmd="$('##{id}').val('#{new_value}'); $('##{id}').next('div').text($('##{id}').prev('label').text()+$('##{id}').val());" #after set value need update input field
	cmd="$('##{id}').val('#{new_value}'); $('##{id}').change();"
	p cmd
	@material_dialog.execute_script(cmd)
end


end #end class YafarayMaterialEditor