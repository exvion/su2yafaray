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
 
$:.push(File.join(File.dirname(__FILE__),"su2yafaray"))  #add the su2yafaray folder to the ruby library search list
require 'sketchup.rb'
unless SU2YAFARAY.on_mac?
	require 'Win32API'
	require 'registry'
end

 path=SU2YAFARAY.get_yafaray_path_from_registry

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
 
  dllname=path+'/jpeg62.dll'
 LoadLibrary.call(dllname)
 
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
	@materialMap={}
	@mesh_lights={}
	end
	
	def SU2YAFARAY.find_default_folder
	folder = ENV["USERPROFILE"]
	folder = "C:\Program Files(x86)\Yafaray for Sketchup"
	folder = File.expand_path("~") if on_mac?
	return folder
	end
	
def SU2YAFARAY.export_camera(yi)
	#camera
	yi.paramsClearAll()
	view=Sketchup.active_model.active_view
	user_camera=view.camera
	user_eye=user_camera.eye
	user_target=user_camera.target
	user_up=user_camera.up

	p 'eye'+user_eye.inspect
	p 'target'+user_target.inspect
	p 'up'+user_up.inspect
	@resx=view.vpwidth
	@resy=view.vpheight
	cam=view.camera
	focal_length=cam.focal_length
	#aspect_ratio=cam.aspect_ratio
	aspect_ratio=1
	
	yi.paramsSetString("type", "perspective")
	yi.paramsSetFloat("aperture",0)
	yi.paramsSetFloat("aspect_ratio",1)
	# f_aspect = 1.0;
				# if renderData.sizeX * renderData.aspectX <= renderData.sizeY * renderData.aspectY:
					# f_aspect = (renderData.sizeX * renderData.aspectX) / (renderData.sizeY * renderData.aspectY)

				# #print "f_aspect: ", f_aspect
				# yi.paramsSetFloat("focal", camera.lens/(f_aspect*32.0))
	yi.paramsSetFloat("focal",focal_length/(aspect_ratio*32.0))

	yi.paramsSetPoint("from", user_eye.x.to_m.to_f,user_eye.y.to_m.to_f,user_eye.z.to_m.to_f)
	out_user_eye= "%12.6f" %(user_eye.x.to_m.to_f) + " " + "%12.6f" %(user_eye.y.to_m.to_f) + " " + "%12.6f" %(user_eye.z.to_m.to_f)
	up_x=user_up.x+user_eye.x.to_m
	up_y=user_up.y+user_eye.y.to_m
	up_z=user_up.z+user_eye.z.to_m
	yi.paramsSetPoint("up", up_x.to_f,up_y.to_f, up_z.to_f)
	
	#yi.paramsSetPoint("to", (user_target.x.to_m.to_f*10).round/10.0,(user_target.y.to_m.to_f*10).round/10.0,(user_target.z.to_m.to_f*10).round/10.0)
	yi.paramsSetPoint("to", user_target.x.to_m, user_target.y.to_m, user_target.z.to_m)
	yi.paramsSetInt("resx", Integer(@ys.width))
	yi.paramsSetInt("resy", Integer(@ys.height))
	yi.createCamera("cam")
end


def SU2YAFARAY.export_background(yi)
	yi.paramsClearAll()
	sun_direction = Sketchup.active_model.shadow_info['SunDirection']
	
	if (@ys.background_type=="constant")
		yi.paramsSetColor("color",0,0,0)
		# yi.paramsSetBool("ibl", worldProp["ibl"])
		# yi.paramsSetInt("ibl_samples", worldProp["ibl_samples"])
		# yi.paramsSetFloat("power", worldProp["power"])
		yi.paramsSetString("type", "constant")
	elsif (@ys.background_type=="gradientback")
		p "gradientback"
	elsif (@ys.background_type=="sunsky")
		yi.paramsSetFloat("a_var",Float(@ys.a_var))
		yi.paramsSetBool("add_sun",true)
		yi.paramsSetFloat("b_var",Float(@ys.b_var))
		yi.paramsSetBool("background_light",true)
		yi.paramsSetFloat("c_var",Float(@ys.c_var))
		yi.paramsSetFloat("d_var",Float(@ys.d_var))
		yi.paramsSetFloat("e_var",Float(@ys.e_var))
		yi.paramsSetPoint("from",sun_direction.x,sun_direction.y,sun_direction.z)
		yi.paramsSetInt("light_samples",16)
		yi.paramsSetFloat("power",0.75)
		yi.paramsSetFloat("sun_power",1)
		yi.paramsSetFloat("turbidity",Float(@ys.turbidity))
		yi.paramsSetString("type", "sunsky")
	elsif (@ys.background_type=="darksky")
		p "darksky"
		yi.paramsSetPoint("from",sun_direction.x,sun_direction.y,sun_direction.z)
		yi.paramsSetFloat("turbidity",Float(@ys.turbidity))
		yi.paramsSetFloat("altitude",Float(@ys.altitude))
		yi.paramsSetFloat("a_var",Float(@ys.a_var))
		yi.paramsSetFloat("b_var",Float(@ys.b_var))
		yi.paramsSetFloat("c_var",Float(@ys.c_var))
		yi.paramsSetFloat("d_var",Float(@ys.d_var))
		yi.paramsSetFloat("e_var",Float(@ys.e_var))
		yi.paramsSetBool("clamp_rgb", false)
		yi.paramsSetBool("add_sun", true)
		yi.paramsSetFloat("sun_power", 1)
		yi.paramsSetBool("background_light",true)
		yi.paramsSetBool("with_caustic", false)
		yi.paramsSetBool("with_diffuse", false)
		yi.paramsSetInt("light_samples",16)
		yi.paramsSetFloat("power",0.75)
		yi.paramsSetFloat("bright", 1)
		yi.paramsSetBool("night", false)
		yi.paramsSetFloat("exposure", 1)
		yi.paramsSetBool("gamma_enc", true)
		yi.paramsSetString("color_space", "CIE (E)")
		yi.paramsSetString("type", "darksky")		
	end
	#yi.paramsSetPoint("from", 100, 100, 100)
	#yi.paramsSetFloat("turbidity", 3)
	 yi.createBackground("world_background")
end

def SU2YAFARAY.export_volumeintegrator(yi)
	#volintegrator
	yi.paramsClearAll()
	yi.paramsSetString("type", "none")
	yi.createIntegrator("volintegr")
end

def SU2YAFARAY.paramsSetColorHex(yi,option_name,value)
			rgb=value
			r = rgb[0..1].to_i(16)
			g = rgb[2..3].to_i(16)
			b = rgb[4..5].to_i(16)
			yi.paramsSetColor(option_name,r/255.0, g/255.0, b/255.0)
end

def SU2YAFARAY.export_integrator(yi)
	#integrators
	yi.paramsClearAll()
	
	yi.paramsSetInt("raydepth", Integer(@ys.raydepth))
	yi.paramsSetInt("shadowDepth", Integer(@ys.shadowDepth))
	yi.paramsSetBool("transpShad", @ys.transpShad)
	
	if (@ys.light_type=="directlighting")
		yi.paramsSetString("type", "directlighting")
		#yi.paramsSetBool("caustics",@ys.caustics)
		if @ys.caustics
			p "use caustics"
			yi.paramsSetBool("caustics",@ys.caustics)
			yi.paramsSetInt("photons", 500000)
			yi.paramsSetInt("caustic_mix", 100)
			yi.paramsSetInt("caustic_depth", 10)
			yi.paramsSetFloat("caustic_radius", 0.1)
		end
		yi.paramsSetBool("do_AO", @ys.do_AO)
		if @ys.do_AO
			yi.paramsSetInt("AO_samples",Integer(@ys.AO_samples))
			yi.paramsSetFloat("AO_distance", Float(@ys.AO_distance))
			SU2YAFARAY.paramsSetColorHex(yi,"AO_color",@ys.AO_color)
		end
	elsif (@ys.light_type=="photonmapping")
		yi.paramsSetString("type", "photonmapping")
		yi.paramsSetInt("fg_samples", Integer(@ys.fg_samples))
		yi.paramsSetInt("photons", Integer(@ys.pm_photons))
		yi.paramsSetInt("cPhotons", Integer(@ys.cPhotons))
		yi.paramsSetFloat("diffuseRadius", Float(@ys.diffuseRadius))
		yi.paramsSetFloat("causticRadius", Float(@ys.causticRadius))
		yi.paramsSetInt("search", Integer(@ys.search))
		yi.paramsSetBool("show_map", @ys.show_map)
		yi.paramsSetInt("fg_bounces", Integer(@ys.fg_bounces))
		yi.paramsSetInt("caustic_mix", Integer(@ys.pm_caustic_mix))
		yi.paramsSetBool("finalGather", @ys.finalGather)
		yi.paramsSetInt("bounces", Integer(@ys.pm_bounces))
	elsif (@ys.light_type=="pathtracing")
			yi.paramsSetString("type", "pathtracing")
			yi.paramsSetInt("path_samples", Integer(@ys.path_samples))
			yi.paramsSetInt("bounces", Integer(@ys.bounces))
			yi.paramsSetBool("no_recursive", @ys.no_recursive)

			yi.paramsSetString("caustic_type",@ys.caustic_type)
			if @ys.caustic_type=="photon" || @ys.caustic_type=="both"
				yi.paramsSetInt("photons", Integer(@ys.photons))
				yi.paramsSetInt("caustic_mix", Integer(@ys.caustic_mix))
				yi.paramsSetInt("caustic_depth", Integer(@ys.caustic_depth))
				yi.paramsSetFloat("caustic_radius", Float(@ys.caustic_radius))
			end
	#elsif (@ys.light_type=="bidirectional")
	#	yi.paramsSetString("type", "bidirectional")
	elsif (@ys.light_type=="DebugIntegrator")
		yi.paramsSetString("type", "DebugIntegrator")
		yi.paramsSetInt("debugType",Integer(@ys.debugType))
		yi.paramsSetBool("showPN",@ys.showPN);
	end

	yi.createIntegrator("default")

end

def SU2YAFARAY.export_lights(yi)
	p "export lights"
	# TODO: export mesh lights
	@mesh_lights.each{|mat,objectId|
		if mat.respond_to?(:name)
			matname = mat.display_name.gsub(/[<>]/,'*')
		else
			matname = "Default"
		end
		yi.paramsClearAll()
		yi.paramsSetString("type", "meshlight")	
		yi.paramsSetBool("double_sided", false)
		yi.paramsSetColor("color", 1, 1, 1)	
		yi.paramsSetFloat("power", 3)
		yi.paramsSetInt("samples", 16)
		yi.paramsSetInt("object", objectId)
		yi.createLight(matname + String(objectId)) #fix matname > <
	}
end

def SU2YAFARAY.export_materials(yi)
	materials=Sketchup.active_model.materials
	materials.each {|mat|
	p 'mat '+mat.display_name
	SU2YAFARAY.export_mat(mat,yi)
	}
end

def SU2YAFARAY.export_mat(mat,yi)
	yi.paramsClearAll()
	yafmat=YafarayMaterial.new(mat)
	matname=yafmat.name
	yi.paramsSetString("type",yafmat.type)
	if (yafmat.type=="shinydiffusemat")
		yi.paramsSetColor("color", mat.color.red.to_f/255, mat.color.green.to_f/255, mat.color.blue.to_f/255 )
		#yi.paramsSetFloat("transparency", )
		yi.paramsSetFloat("translucency",Float(yafmat.translucency))
		yi.paramsSetFloat("diffuse_reflect",Float(yafmat.diffuse_reflect))
		yi.paramsSetFloat("emit", Float(yafmat.emit))
		yi.paramsSetFloat("transmit_filter", Float(yafmat.transmit_filter))
		yi.paramsSetFloat("specular_reflect", Float(yafmat.specular_reflect))
		# yi.paramsSetColor("mirror_color", mirCol[0], mirCol[1], mirCol[2])
		yi.paramsSetBool("fresnel_effect", yafmat.fresnel_effect)
		yi.paramsSetFloat("IOR", Float(yafmat.IOR))

		# if props["brdfType"] == "Oren-Nayar":
			# yi.paramsSetString("diffuse_brdf", "oren_nayar")
			# yi.paramsSetFloat("sigma", props["sigma"])
	end
	if (yafmat.type=="glossy" or yafmat.type=="coated_glossy")
				p "glossy"
				# yi.paramsSetColor("diffuse_color", diffuse_color[0], diffuse_color[1], diffuse_color[2])
				# yi.paramsSetColor("color", color[0],color[1], color[2])
				# yi.paramsSetFloat("glossy_reflect", props["glossy_reflect"])
				# yi.paramsSetFloat("exponent", props["exponent"])
				# yi.paramsSetFloat("diffuse_reflect", props["diffuse_reflect"])
				# yi.paramsSetBool("as_diffuse", props["as_diffuse"])
				# yi.paramsSetBool("anisotropic", props["anisotropic"])
				# yi.paramsSetFloat("exp_u", props["exp_u"])
				# yi.paramsSetFloat("exp_v", props["exp_v"])
	end
	if (yafmat.type=="glass" or yafmat.type=="rought_glass")
				p yafmat.type
				if (yafmat.type=="rought_glass")
					yi.paramsSetFloat("exponent",Float(yafmat.exponent))
				end
				yi.paramsSetFloat("IOR",Float(yafmat.IOR))
				yi.paramsSetColor("filter_color", 0.5, 0.5, 0.5)
				yi.paramsSetColor("mirror_color", 0.5, 0.5, 0.5)
				yi.paramsSetFloat("transmit_filter",Float(yafmat.transmit_filter))
				yi.paramsSetColor("absorption", 0.5, 0.5,0.5)
				yi.paramsSetFloat("absorption_dist", Float(yafmat.absorption_dist))
				yi.paramsSetFloat("dispersion_power", Float(yafmat.dispersion_power))
				yi.paramsSetBool("fake_shadows", false)
	end
	if (yafmat.type=="light_mat")
				yi.paramsSetString("type", "light_mat");
				yi.paramsSetBool("double_sided", false)
				yi.paramsSetColor("color", 1, 1, 1)
				yi.paramsSetFloat("power",3)
	end
	yafaraymat=yi.createMaterial(matname)  
	@materialMap[matname]=yafaraymat
end


def SU2YAFARAY.render(useXML)
	#Sketchup.send_action "showRubyPanel:"
	@ys=YafaraySettings.new
	SU2YAFARAY.reset_variables
	if useXML
		export_file_path=SU2YAFARAY.get_export_file_path
		#check whether user has pressed cancel
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
		Yafqt.initGui
		yi=Yafrayinterface::YafrayInterface_t.new
		SU2YAFARAY.set_params(yi)
		settings=Yafqt::Settings.new
		settings.autoSave=false
		settings.closeAfterFinish=false
		Yafqt.createRenderWidget(yi,Integer(@ys.width),Integer(@ys.height),0,0,settings)
		yi.clearAll();
	end
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
	yi.loadPlugins('')
	p 'starting scene'
	
	yi.startScene(0)
	yi.setInputGamma(1, true)
	
	SU2YAFARAY.collect_faces(Sketchup.active_model.entities, Geom::Transformation.new)
	SU2YAFARAY.export_materials(yi)
	p @materialMap.inspect
		
	SU2YAFARAY.export_mesh(yi)
	SU2YAFARAY.export_lights(yi)
	SU2YAFARAY.export_background(yi)
	SU2YAFARAY.export_camera(yi)
	SU2YAFARAY.export_integrator(yi)

	SU2YAFARAY.export_volumeintegrator(yi)

	#render
	yi.paramsClearAll()
	yi.paramsSetString("camera_name", "cam")
	yi.paramsSetString("integrator_name", "default")
	yi.paramsSetString("volintegrator_name", "volintegr")
	yi.paramsSetString("background_name","world_background");
	yi.paramsSetFloat("gamma", Float(@ys.gamma))
	yi.paramsSetBool("clamp_rgb",@ys.clamp_rgb)
	yi.paramsSetInt("AA_passes", Integer(@ys.aa_passes))
	if (Integer(@ys.aa_passes)>1)
		yi.paramsSetFloat("AA_threshold", Float(@ys.aa_threshold))
		yi.paramsSetInt("AA_inc_samples", Integer(@ys.aa_inc_samples))
	end		
	yi.paramsSetInt("AA_minsamples", Integer(@ys.aa_samples))
	yi.paramsSetFloat("AA_pixelwidth", Float(@ys.aa_pixelwidth))
	yi.paramsSetString("filter_type", @ys.filter_type)
	
	if (@ys.auto_threads==true)
		yi.paramsSetInt("threads", -1)
	else
		yi.paramsSetInt("threads",Integer(@ys.threads))
	end
	
	imageMem = Yafrayinterface.new_floatArray(Integer(@ys.width) * Integer(@ys.height) * 4)
	#co = yafrayinterface.memoryIO_t(400, 400, imageMem)
	yi.paramsSetInt("width", Integer(@ys.width))
	yi.paramsSetInt("height", Integer(@ys.height))

	yi.paramsSetBool("z_channel", @ys.z_channel)
	yi.setDrawParams(false)
end

def SU2YAFARAY.export_mesh(yi)
	yi.startGeometry()
	@current_mat_step = 1
	SU2YAFARAY.export_faces(yi)
	SU2YAFARAY.export_fm_faces(yi)
	if not yi.endGeometry() 
		p "error on endGeometry"
	end
end

def SU2YAFARAY.status_bar(stat_text)
	
	statbar = Sketchup.set_status_text stat_text
	
end

#####################################################################
###### - collect entities to an array -						 		######
#####################################################################
def SU2YAFARAY.collect_faces(object, trans)

	if object.class == Sketchup::ComponentInstance
		entity_list=object.definition.entities
	elsif object.class == Sketchup::Group
		entity_list=object.entities
	else
		entity_list=object
	end

	#p "entity count="+entity_list.count.to_s

	text=""
	text="Component: " + object.definition.name if object.class == Sketchup::ComponentInstance
	text="Group" if object.class == Sketchup::Group
	
	SU2YAFARAY.status_bar("Collecting Faces - Level #{@parent_mat.size} - #{text}")

	for e in entity_list
	  
		if (e.class == Sketchup::Group and e.layer.visible?)
			SU2YAFARAY.get_inside(e,trans,false) #e,trans,false - not FM component
		end
		if (e.class == Sketchup::ComponentInstance and e.layer.visible? and e.visible?)
			SU2YAFARAY.get_inside(e,trans,e.definition.behavior.always_face_camera?) # e,trans, fm_component?
		end
		if (e.class == Sketchup::Face and e.layer.visible? and e.visible?)
			
			face_properties=SU2YAFARAY.find_face_material(e)
			mat=face_properties[0]
			uvHelp=face_properties[1]
			mat_dir=face_properties[2]

			if @fm_comp.last==true
				(@fm_materials[mat] ||= []) << [e,trans,uvHelp,mat_dir]
			else
				(@materials[mat] ||= []) << [e,trans,uvHelp,mat_dir] if (@animation==false or (@animation and @export_full_frame))
			end
			@count_faces+=1
		end
	end  
end

#####################################################################
#####################################################################
def SU2YAFARAY.find_face_material(e)
	mat = Sketchup.active_model.materials[FRONTF]
	mat = Sketchup.active_model.materials.add FRONTF if mat.nil?
	front_color = Sketchup.active_model.rendering_options["FaceFrontColor"]
	scale = 0.8 / 255.0
	mat.color = Sketchup::Color.new(front_color.red * scale, front_color.green * scale, front_color.blue * scale)
	uvHelp=nil
	mat_dir=true
	if e.material!=nil
		mat=e.material
	else
		if e.back_material!=nil
			mat=e.back_material
			mat_dir=false
		else
			mat=@parent_mat.last if @parent_mat.last!=nil
		end
	end

	# if (mat.respond_to?(:texture) and mat.texture !=nil)
		# ret=SU2KT.store_textured_entities(e,mat,mat_dir)
		# mat=ret[0]
		# uvHelp=ret[1]
	# end

	return [mat,uvHelp,mat_dir]
end

#####################################################################
#####################################################################
def SU2YAFARAY.get_inside(e,trans,face_me)
	@fm_comp.push(face_me)
	if e.material != nil
		mat = e.material
		@parent_mat.push(e.material)
		#SU2KT.store_textured_entities(e,mat,true) if (mat.respond_to?(:texture) and mat.texture!=nil)
	else
		@parent_mat.push(@parent_mat.last)
	end
	SU2YAFARAY.collect_faces(e, trans*e.transformation)
	@parent_mat.pop
	@fm_comp.pop
end
  

#####################################################################
#####################################################################
def SU2YAFARAY.export_faces(yi)
	@materials.each{|mat,value|
		if (value!=nil and value!=[])
			SU2YAFARAY.export_face(yi,mat,false)
			@materials[mat]=nil
		end}
	@materials={}
end

#####################################################################
#####################################################################
def SU2YAFARAY.export_fm_faces(yi)
	@fm_materials.each{|mat,value|
		if (value!=nil and value!=[])
			SU2YAFARAY.export_face(yi,mat,true)
			@fm_materials[mat]=nil
		end}
	@fm_materials={}
end


#####################################################################
#####################################################################
def SU2YAFARAY.point_to_vector(p)
	Geom::Vector3d.new(p.x,p.y,p.z)
end

#####################################################################
#####################################################################
def SU2YAFARAY.export_face(yi,mat,fm_mat)
	#p 'export face'
	#p mat.name
	meshes = []
	polycount = 0
	pointcount = 0
	mirrored=[]
	mat_dir=[]
	default_mat=[]
	distorted_uv=[]

	
	if fm_mat
		export=@fm_materials[mat]
	else
		export=@materials[mat]
	end
	
	#puts export
	
	has_texture = false
	if mat.respond_to?(:name)
		matname = mat.display_name.gsub(/[<>]/,'*')
		#matname = mat.display_name
		
		# has_texture = true if mat.texture!=nil
	else
		matname = "Default"
		# has_texture=true if matname!=FRONTF
	 end
	
	#matname="FM_"+matname if fm_mat
	p 'matname '+matname
	yafaraymat=@materialMap[matname]
	#if mat
	 #  matname = mat.display_name
	  # p "matname="+matname
	  # matname=matname.gsub(/[<>]/, '*')
	  # if mat.texture
		# has_texture = true
	  # end
	 #else
	  # matname = "Default"
	 #end
	
	#matname="FM_"+matname if fm_mat
		
	#Introduced by SJ
	total_mat = @materials.length + @fm_materials.length
	mat_step = " [" + @current_mat_step.to_s + "/" + total_mat.to_s + "]"
	@current_mat_step += 1

	total_step = 4
	if (has_texture and @clay==false) or @exp_default_uvs==true
		total_step += 1
	end
	current_step = 1
	rest = export.length*total_step
	SU2YAFARAY.status_bar("Converting Faces to Meshes: " + matname + mat_step + "...[" + current_step.to_s + "/" + total_step.to_s + "]" + " #{rest}")
	#####
	
	 for ft in export
		 
		 
		 SU2YAFARAY.status_bar("Converting Faces to Meshes: " + matname + mat_step + "...[" + current_step.to_s + "/" + total_step.to_s + "]" + " #{rest}") if (rest%500==0)
		 rest-=1
		
	  	polymesh=(ft[3]==true) ? ft[0].mesh(5) : ft[0].mesh(6)
		trans = ft[1]
		trans_inverse = trans.inverse
		default_mat.push (ft[0].material==nil)
		distorted_uv.push ft[2]
		mat_dir.push ft[3]

		polymesh.transform! trans
	  
	 
		xa = SU2YAFARAY.point_to_vector(ft[1].xaxis)
		ya = SU2YAFARAY.point_to_vector(ft[1].yaxis)
		za = SU2YAFARAY.point_to_vector(ft[1].zaxis)
		xy = xa.cross(ya)
		xz = xa.cross(za)
		yz = ya.cross(za)
		mirrored_tmp = true
	  
		if xy.dot(za) < 0
			mirrored_tmp = !mirrored_tmp
		end
		if xz.dot(ya) < 0
			mirrored_tmp = !mirrored_tmp
		end
		if yz.dot(xa) < 0
			mirrored_tmp = !mirrored_tmp
		end
		mirrored << mirrored_tmp

		meshes << polymesh
		@count_faces-=1
		
		polycount=polycount + polymesh.count_polygons
		pointcount=pointcount + polymesh.count_points
	 end
	
	#p 'polycount'+polycount.to_s
	#p 'pointcount'+pointcount.to_s
	 #id=Yafrayinterface::new_uintp()
	 id=yi.getNextFreeID()
	 yafmat=YafarayMaterial.new(mat)
	 if (yafmat.type=="light_mat")
	 @mesh_lights[mat]=id;
	 end
	 p "id "
	 p id;
	 pl=yi.startTriMesh(id, pointcount, polycount, false,false,0)
	 if not pl 
	 p 'error create trimesh'
	 end
	 startindex = 0
	
	# # Exporting vertices
	# #has_texture = false
	 current_step += 1
	
	
	# # out.puts 'AttributeBegin'
	 i=0
	
	# # luxrender_mat=LuxrenderMaterial.new(mat)
	# # #Exporting faces indices
	# # #light
	# # # LightGroup "default"
	# # # AreaLightSource "area" "texture L" ["material_name:light:L"]
   # # # "float power" [100.000000]
   # # # "float efficacy" [17.000000]
   # # # "float gain" [1.000000]
	# # case luxrender_mat.type
		# # when "matte", "glass"
			# # out.puts "NamedMaterial \""+luxrender_mat.name+"\""
		# # when "light"
			# # out.puts "LightGroup \"default\""
			# # out.puts "AreaLightSource \"area\" \"texture L\" [\""+luxrender_mat.name+":light:L\"]"
			# # out.puts '"float power" [100.000000]
			# # "float efficacy" [17.000000]
			# # "float gain" [1.000000]'
	# # end

		# #Exporting verticies  points
	
	 for mesh in meshes
		for p in (1..mesh.count_points)
			pos = mesh.point_at(p).to_a
			#p "#{"%.6f" %(pos[0]*@scale)} #{"%.6f" %(pos[1]*@scale)} #{"%.6f" %(pos[2]*@scale)}\n"
			# out.print "#{"%.6f" %(pos[0]*@scale)} #{"%.6f" %(pos[1]*@scale)} #{"%.6f" %(pos[2]*@scale)}\n"
			#p pos[0]*@scale
			#sprintf("%.6f", float_integer).to_f
			yi.addVertex(pos[0]*@scale,pos[1]*@scale,pos[2]*@scale)
			
			
		end
	end
	

	
	# #out.puts 'Shape "trianglemesh" "integer indices" ['
	 for mesh in meshes
	  	mirrored_tmp = mirrored[i]
		mat_dir_tmp = mat_dir[i]
		for poly in mesh.polygons
			v1 = (poly[0]>=0?poly[0]:-poly[0])+startindex
			v2 = (poly[1]>=0?poly[1]:-poly[1])+startindex
			v3 = (poly[2]>=0?poly[2]:-poly[2])+startindex
			#p "#{v1-1} #{v2-1} #{v3-1}\n"
			if !mirrored_tmp
				if mat_dir_tmp==true
					#p "#{v1-1} #{v2-1} #{v3-1}\n"
					yi.addTriangle(v1-1,v2-1,v3-1, yafaraymat)
				else
					#p "#{v1-1} #{v3-1} #{v2-1}\n"
					yi.addTriangle(v1-1,v3-1,v2-1, yafaraymat)
				end
			else
				if mat_dir_tmp==true
					#p "#{v2-1} #{v1-1} #{v3-1}\n"
					yi.addTriangle(v2-1,v1-1,v3-1, yafaraymat)
				else
					#p "#{v2-1} #{v3-1} #{v1-1}\n"
					yi.addTriangle(v2-1,v3-1,v1-1, yafaraymat)
				end
			end		
		
		@count_tri = @count_tri + 1
	  end
	  startindex = startindex + mesh.count_points
	  i+=1
	end
	
	# i=0
	# #Exporting normals
	
	# for mesh in meshes
		# Sketchup.set_status_text("Material being exported: " + matname + mat_step + "...[" + current_step.to_s + "/" + total_step.to_s + "]" + " - Normals " + " #{rest}") if rest%500==0
		# rest -= 1
		# mat_dir_tmp = mat_dir[i]
		# for p in (1..mesh.count_points)
			# norm = mesh.normal_at(p)
			# norm.reverse! if mat_dir_tmp==false
				# out.print " #{"%.4f" %(norm.x)} #{"%.4f" %(norm.y)} #{"%.4f" %(norm.z)}\n"
		# end
		# i += 1
	# end
	yi.endTriMesh()
	yi.smoothMesh(0, 181)
	
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
	cmd_render.small_icon = "su2yafaray\\yafray.png"
	cmd_render.large_icon = "su2yafaray\\yafray.png"
	cmd_render.tooltip = "Render with Yafaray"
	cmd_render.menu_text = "Render"
	cmd_render.status_bar_text = "Render with Yafaray"
	toolbar = toolbar.add_item(cmd_render)
	toolbar.show
	
	load File.join("su2yafaray","YafaraySettings.rb")
	load File.join("su2yafaray","YafaraySettingsEditor.rb")
	load File.join("su2yafaray","YafarayMaterial.rb")
	load File.join("su2yafaray","YafarayMaterialEditor.rb")
	
	#observers
	Sketchup.add_observer(SU2YAFARAY_app_observer.new)
	Sketchup.active_model.materials.add_observer(SU2YAFARAY_material_observer.new)
end

file_loaded(__FILE__)