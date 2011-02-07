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
# Name         : su2yafaray.rb
# Description  : Model exporter and material editor for Yafaray http://www.yafaray.org
# Menu Item    : Plugins\Luxrender Exporter
# Authors      : Alexander Smirnov (aka Exvion)  e-mail: exvion@gmail.com http://exvion.ru
#					Initialy based on SU exporters:
#					SU2LUX by Alexander Smirnov, Mimmo Briganti
#					SU2KT by Tomasz Marek, Stefan Jaensch, Tim Crandall, 
#					SU2POV by Didier Bur and OGRE exporter by Kojack
# Usage        : Copy script to PLUGINS folder in SketchUp folder, run SU, go to Plugins\Yafaray exporter
# Date         : 2010-06-29
# Type         : Exporter
# Version      : 0.1 alpha

module SU2YAFARAY

######test if user is on a mac platform
def SU2YAFARAY.on_mac?

return (Object::RUBY_PLATFORM =~ /mswin/i) ? false : ((Object::RUBY_PLATFORM =~ /darwin/i) ? true : :other)

end

#######gets the yafaray path from the windows registry
def SU2YAFARAY.get_yafaray_path_from_registry

begin
	Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\YafRay Team\YafaRay for Sketchup') do |reg|
	#Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\YafRay Team\YafaRay') do |reg|
		reg_typ, reg_val = reg.read('InstallDir')
	    return reg_val
	end
rescue
	raise
	#return nil
end
	
end

end
 
$:.push(File.join(File.dirname(__FILE__)))  #add the su2yafaray folder to the ruby library search list
$:.push(File.join(File.dirname(__FILE__),'bin'))
require 'sketchup.rb'
unless SU2YAFARAY.on_mac?
	require 'Win32API'
	require 'registry'
end

#path=SU2YAFARAY.get_yafaray_path_from_registry
path=File.join(File.dirname(__FILE__),'bin')

LoadLibrary = Win32API.new("kernel32","LoadLibrary",["P"],"I")
 
 mingw=false
 if not mingw
 #abc
 dllname=path+'/zlib1.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/Half.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/iconv.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+'/Iex.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/IlmImf.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+'/IlmThread.dll'
 LoadLibrary.call(dllname)
 
 #dllname=path+'/jpeg62.dll'
 #LoadLibrary.call(dllname)
 
  dllname=path+'/libfreetype-6.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/libpng3.dll'
 LoadLibrary.call(dllname) 
 
 dllname=path+ '/libtiff3.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+ '/libxml2.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/pthreadVC2.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+'/QtCore4.dll'
 LoadLibrary.call(dllname)
 dllname=path+'/QtGui4.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+'/yafaraycore.dll'
 LoadLibrary.call(dllname)
 dllname=path+'/yafarayplugin.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+'/yafarayqt.dll'
 LoadLibrary.call(dllname)   
 
 else
  # dllname=path+'/zlib1.dll'
 # LoadLibrary.call(dllname)
 
 dllname=path+'/mingwm10.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/Half.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/iconv.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+'/Iex.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/IlmImf.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+'/IlmThread.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/jpeg62.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/libfreetype-6.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/libpng3.dll'
 LoadLibrary.call(dllname) 
 
 dllname=path+ '/libtiff-3.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+ '/libxml2.dll'
 LoadLibrary.call(dllname)
 
  dllname=path+'/pthreadVC2.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+'/QtCore4.dll'
 LoadLibrary.call(dllname)
 dllname=path+'/QtGui4.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+'/libyafaraycore.dll'
 LoadLibrary.call(dllname)
 dllname=path+'/libyafarayplugin.dll'
 LoadLibrary.call(dllname)
 
 dllname=path+'/libyafarayqt.dll'
 LoadLibrary.call(dllname)   
 end
 
 require 'yafqt'
 require 'yafrayinterface'

module SU2YAFARAY

FRONTF = "SU2YAFARAY Front Face"
SCENE_NAME='default.xml'

	def SU2YAFARAY.reset_variables
	@n_pointlights=0
	@n_spotlights=0
	@n_cameras=0
	@face=0
	@scale = 0.0254
	@copy_textures = true
	@export_materials = true
	@export_meshes = true
	@export_lights = true
	@instanced=true
	@model_name=""
	@textures_prefix = "TX_"
	@texturewriter=Sketchup.create_texture_writer
	@model_textures={}
	@count_tri = 0
	@count_faces = 0
	@lights = []
	@materials = {}
	@fm_materials = {}
	@components = {}
	@selected=false
	@exp_distorted = false
	@exp_default_uvs = false
	@clay=false
	@animation=false
	@export_full_frame=false
	@frame=0
	@parent_mat=[]
	@fm_comp=[]
	@status_prefix = ""   # Identifies which scene is being processed in status bar
	@scene_export = false # True when exporting a model for each scene
	@status_prefix=""
	@used_materials = []
	#@materialMap={}
	@textureMap={}
	@mesh_lights={}
	@os_separator = "\\"
	end
	
	def SU2YAFARAY.find_default_folder
	folder = ENV["USERPROFILE"]
	folder = "C:\Program Files(x86)\Yafaray for Sketchup"
	folder = File.expand_path("~") if on_mac?
	return folder
	end
	


def SU2YAFARAY.render(useXML)
	start_time=Time.new
	#Sketchup.send_action "showRubyPanel:"
	# @ys=YafaraySettings.new
	# SU2YAFARAY.reset_variables
	if useXML
		export_file_path=SU2YAFARAY.get_export_file_path
		# #check whether user has pressed cancel
		if export_file_path
			#if export_file_path=nil  
			#export_file_path="C:\yafaray.xml"
			yi=Yafrayinterface::XmlInterface_t.new
			co=Yafrayinterface::ImageOutput_t.new
			yi.setOutfile(export_file_path)
			
			SU2YAFARAY.set_params(yi)
			
			yi.render(co)
			yi.clearAll()
		end
	else
		yi=Yafrayinterface::YafrayInterface_t.new
		SU2YAFARAY.set_params(yi)
		result=SU2YAFARAY.report_window(start_time,"Time")
		if result==6
			Yafqt.initGui
			settings=Yafqt::Settings.new
			settings.autoSave=false
			settings.closeAfterFinish=false
			Yafqt.createRenderWidget(yi,Integer(@ys.width),Integer(@ys.height),0,0,settings)
			yi.clearAll();
		else
			yi.clearAll();
		end
	end
end


def SU2YAFARAY.report_window(start_time,stext)

	end_time=Time.new
	elapsed=end_time-start_time
	time=" exported in "
		(time=time+"#{(elapsed/3600).floor}h ";elapsed-=(elapsed/3600).floor*3600) if (elapsed/3600).floor>0
		(time=time+"#{(elapsed/60).floor}m ";elapsed-=(elapsed/60).floor*60) if (elapsed/60).floor>0
		time=time+"#{elapsed.round}s. "

	Sketchup.set_status_text(stext+time+" Triangles = #{@count_tri}")
	export_text="Export done. Start render?\n"
	#export_text="Selection saved in file:\n" if @selected==true
	result=UI.messagebox export_text ,MB_YESNO

end



def SU2YAFARAY.get_export_file_path
	model = Sketchup.active_model
		model_filename = File.basename(model.path)
		if model_filename.empty?
			export_filename = SCENE_NAME
		else
			dot_position = model_filename.rindex(".")
			export_filename = model_filename.slice(0..(dot_position - 1))
			export_filename += ".xml"
		end
		p export_filename
		export_folder=SU2YAFARAY.find_default_folder	
		export_file_path=UI.savepanel "Save xml file", export_folder, export_filename	
		if export_file_path
			if export_file_path == export_file_path.chomp(".xml")
				export_file_path += ".xml"
			end
		end
		return export_file_path
end

def SU2YAFARAY.set_params(yi)
	@ys=YafaraySettings.new
	ye=YafarayExport.new(yi)
	ye.reset
	p 'start collect faces'
	ye.collect_faces	
	ye.write_textures
	ye.export_materials(yi)
	
	ye.export_mesh(yi)
	#ye.export_lights(yi)
	ye.export_background(yi)
	ye.export_camera(yi)
	ye.export_integrator(yi)
	ye.export_volumeintegrator(yi)
	#SU2YAFARAY.export_textures(yi)
	ye.export_render_params(yi)
	@count_tri=ye.count_tri
end



def SU2YAFARAY.show_settings_editor

	if not @settings_editor
		@settings_editor=YafaraySettingsEditor.new
	end
	@settings_editor.show
end

def SU2YAFARAY.show_material_editor

	if not @material_editor
		@material_editor=YafarayMaterialEditor.new
	end
	@material_editor.show
 end

def SU2YAFARAY.get_editor(type)
	case type
		when "settings"
			editor = @settings_editor
		when "material"
			editor = @material_editor
	end
	return editor
end

#####################################################################
#####################################################################
def SU2YAFARAY.about
	UI.messagebox("SU2Yafaray version 0.1 alpha 29th June 2010
SketchUp Exporter to Yafaray
Author: Alexander Smirnov (aka Exvion)
E-mail: exvion@gmail.com
http://exvion.ru
For further information please visit
Yafaray Website & Forum - www.yafaray.org" , MB_MULTILINE , "SU2Yafaray - Sketchup Exporter to Yafaray")
end
end

class SU2YAFARAY_app_observer < Sketchup::AppObserver
	def onNewModel(model)
		model.materials.add_observer(SU2YAFARAY_material_observer.new)
	end

	def onOpenModel(model)
		model.materials.add_observer(SU2YAFARAY_material_observer.new)
	end
end


class SU2YAFARAY_material_observer < Sketchup::MaterialsObserver
	def onMaterialSetCurrent(materials, material)
		material_editor = SU2YAFARAY.get_editor("material")
		p "material_editor"
		if (material_editor)
		p "setCurrent material"
		material_editor.yafmat=YafarayMaterial.new(material)
		material_editor.setValue("material_name",material.name)
		material_editor.SendDataFromSketchup()	
		end
	end
end




if( not file_loaded?(__FILE__) )
	main_menu = UI.menu("Plugins").add_submenu("Yafaray")
	main_menu.add_item("Render") { ( SU2YAFARAY.render(false))}
	main_menu.add_item("Export") { ( SU2YAFARAY.render(true))}
	main_menu.add_item("Settings") { (SU2YAFARAY.show_settings_editor)}
	main_menu.add_item("Material Editor") {(SU2YAFARAY.show_material_editor)}
	main_menu.add_item("About") {(SU2YAFARAY.about)}
	toolbar = UI::Toolbar.new("Yafaray")
	cmd_render = UI::Command.new("Render"){(SU2YAFARAY.render(false))}
	cmd_render.small_icon = "yafray.png"
	cmd_render.large_icon = "yafray.png"
	cmd_render.tooltip = "Render with Yafaray"
	cmd_render.menu_text = "Render"
	cmd_render.status_bar_text = "Render with Yafaray"
	toolbar = toolbar.add_item(cmd_render)
	toolbar.show
	
	load File.join("su2yafaray","YafaraySettings.rb")
	load File.join("su2yafaray","YafaraySettingsEditor.rb")
	load File.join("su2yafaray","YafarayMaterial.rb")
	load File.join("su2yafaray","YafarayMaterialEditor.rb")
	load File.join("su2yafaray","MeshCollector.rb")
	load File.join("su2yafaray","YafarayExport.rb")
	
	#observers
	Sketchup.add_observer(SU2YAFARAY_app_observer.new)
	Sketchup.active_model.materials.add_observer(SU2YAFARAY_material_observer.new)
end

file_loaded(__FILE__)