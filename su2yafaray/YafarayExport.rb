class YafarayExport

	FRONTF = "SU2YAFARAY Front Face"
	attr_reader :count_tri
def reset
	@materials = {}
	@fm_materials = {}
	@count_faces = 0
	@clay=false
	@exp_default_uvs = false
	@scale = 0.0254
	@count_tri = 0
	@model_textures={}
	@textures_prefix = "TX_"
	@ys=YafaraySettings.new
	@materialMap={}
	@os_separator = "\\"
end


def initialize(yi)
	plugins_path=File.join(File.dirname(__FILE__),'bin','plugins')
	p plugins_path
	yi.loadPlugins(plugins_path)
	yi.startScene(0)
	yi.setInputGamma(1, true)
end	

def export_render_params(yi)
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

def collect_faces
	mc=MeshCollector.new(@model_name,@os_separator)
	mc.collect_faces(Sketchup.active_model.entities, Geom::Transformation.new)
	@materials=mc.materials
	p ">>>@materials"
	p @materials.inspect
	@fm_materials=mc.fm_materials
	@model_textures=mc.model_textures
	@texturewriter=mc.texturewriter
	@count_faces=mc.count_faces
end	

def export_camera(yi)
	#camera
	yi.paramsClearAll()
	view=Sketchup.active_model.active_view
	user_camera=view.camera
	user_eye=user_camera.eye
	user_target=user_camera.target
	user_up=user_camera.up
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


def export_background(yi)
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

def export_volumeintegrator(yi)
	#volintegrator
	yi.paramsClearAll()
	yi.paramsSetString("type", "none")
	yi.createIntegrator("volintegr")
end

def paramsSetColorHex(yi,option_name,value)
			rgb=value
			r = rgb[0..1].to_i(16)
			g = rgb[2..3].to_i(16)
			b = rgb[4..5].to_i(16)
			yi.paramsSetColor(option_name,r/255.0, g/255.0, b/255.0)
end

def export_integrator(yi)
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

# def export_lights(yi)
	# p "export lights"
	# # TODO: export mesh lights
	# @mesh_lights.each{|mat,objectId|
		# if mat.respond_to?(:name)
			# matname = mat.display_name.gsub(/[<>]/,'*')
		# else
			# matname = "Default"
		# end
		# yi.paramsClearAll()
		# yi.paramsSetString("type", "meshlight")	
		# yi.paramsSetBool("double_sided", false)
		# yi.paramsSetColor("color", 1, 1, 1)	
		# yi.paramsSetFloat("power", 3)
		# yi.paramsSetInt("samples", 16)
		# yi.paramsSetInt("object", objectId)
		# yi.createLight(matname + String(objectId)) #fix matname > <
	# }
# end

# def SU2YAFARAY.export_textures(yi)
	# @model_textures.each { |key,value|
	# SU2YAFARAY.export_texture(key,value[4],yi)
	# }
# end

# def SU2YAFARAY.export_texture(texture_name,texture_path,yi)
	# p 'export_texture'
	# p 'texture_______name '+texture_name
	# p @path_textures+@os_separator+texture_path
	# yi.paramsClearAll() 
	# yi.paramsSetString("type", "image")
	# yi.paramsSetString("filename", @path_textures+@os_separator+texture_path)
	# yi.paramsSetFloat("gamma", 2.2)
	# yi.createTexture(texture_name)
# end

def write_textures
	@path_textures=ENV["TMP"]
	@copy_textures=true #TODO add in settings export
	
	if (@copy_textures == true and @model_textures!={})

		if FileTest.exist? (@path_textures+@os_separator+@textures_prefix)
		else
			Dir.mkdir(@path_textures+@os_separator+@textures_prefix)
		end

		tw=@texturewriter
		p '>>>@model_textures.inspect'
		p @model_textures.inspect
		number=@model_textures.length
		count=1
		@model_textures.each do |key, value|
			Sketchup.set_status_text("Exporting texture "+count.to_s+"/"+number.to_s)
			if value[1].class== Sketchup::Face
				p value[1]
				return_val = tw.write value[1], value[2], (@path_textures+@os_separator+value[4])
				p 'path: '+@path_textures+@os_separator+value[4]
				p return_val
				p 'write texture1'
			else
				tw.write value[1], (@path_textures+@os_separator+value[4])
				p 'write texture2'
			end
			count+=1
		end

		status='ok' #TODO

		if status
		stext = "SU2LUX: " + (count-1).to_s + " textures and model"
		else
			stext = "An error occured when exporting textures. Model"
		end
	else
		stext = "Model"
	end

	return stext

end


def export_materials(yi)
	# mat = Sketchup.active_model.materials[FRONTF]
	# mat = Sketchup.active_model.materials.add FRONTF if mat.nil?
	# front_color = Sketchup.active_model.rendering_options["FaceFrontColor"]
	# scale = 0.8 / 255.0
	# mat.color = Sketchup::Color.new(front_color.red * scale, front_color.green * scale, front_color.blue * scale)
	
	materials=Sketchup.active_model.materials
	materials.each {|mat|
	export_mat(mat,yi)
	}
	#@texturewriter=nil
	#@model_textures=nil
end

def writeTexLayer(yi,name)
		yi.paramsPushList()
		yi.paramsSetString("element", "shader_node")
		yi.paramsSetString("type", "layer")
		yi.paramsSetString("name", name)
		yi.paramsSetString("input", "map0")
		yi.paramsSetInt("mode", 0)
		yi.paramsSetBool("stencil", false)
		yi.paramsSetBool("negative", false)
		yi.paramsSetBool("noRGB", false)
		
		yi.paramsSetColor("def_col", 1, 0, 1)
		yi.paramsSetFloat("def_val", 1)
		yi.paramsSetFloat("colfac", 1)
		yi.paramsSetFloat("valfac", 1)
		yi.paramsSetBool("color_input", true)
		yi.paramsSetBool("use_alpha", true)
		yi.paramsSetColor("upper_color", 1,1,1)
		yi.paramsSetFloat("upper_value", 0)
		
		yi.paramsSetBool("do_color", true)
		yi.paramsSetBool("do_scalar", false)
end

def writeMappingNode(yi,tex_name)
	yi.paramsPushList()
	yi.paramsSetString("element", "shader_node")
	yi.paramsSetString("type", "texture_mapper")
	yi.paramsSetString("name", "map0")
	yi.paramsSetString("texture", tex_name)
	yi.paramsSetString("texco", "uv")
	yi.paramsSetInt("proj_x", 1)
	yi.paramsSetInt("proj_y", 2)
	yi.paramsSetInt("proj_z", 3)
	yi.paramsSetString("mapping", "plain")
	yi.paramsSetPoint("offset", 0, 0,0)
	yi.paramsSetPoint("scale", 1, 1, 1)
end

def export_mat(mat,yi)
	
	@path_textures=ENV["TMP"]
	yafmat=YafarayMaterial.new(mat)
	matname=yafmat.name
	if @model_textures[matname]!=nil
			yi.paramsClearAll()
			yi.paramsSetString("type", "image")
			yi.paramsSetString("filename",@path_textures+@os_separator+@model_textures[matname][4])
			yi.paramsSetFloat("gamma", 2.2)
			yi.createTexture(matname)
	end
	
	yi.paramsClearAll()
	
	# has_texture = false
	# p 'INFO INFO'
	# p mat
	# if mat.respond_to?(:name)
		# matname = mat.display_name.gsub(/[<>]/,'*')
		# has_texture = true if mat.texture!=nil
	# else
		# matname = "Default"
		# has_texture=true if matname!=FRONTF
	 # end
	
	# p matname
	# p 'has texture'
	# p has_texture

	# if @model_textures[matname]!=nil
		# main_mat = @model_textures[matname][5]
	# else
		# main_mat = mat
	# end
			
		# yi.paramsClearAll()
	
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
	# if (yafmat.type=="glossy" or yafmat.type=="coated_glossy")
				# p "glossy"
				# # yi.paramsSetColor("diffuse_color", diffuse_color[0], diffuse_color[1], diffuse_color[2])
				# # yi.paramsSetColor("color", color[0],color[1], color[2])
				# # yi.paramsSetFloat("glossy_reflect", props["glossy_reflect"])
				# # yi.paramsSetFloat("exponent", props["exponent"])
				# # yi.paramsSetFloat("diffuse_reflect", props["diffuse_reflect"])
				# # yi.paramsSetBool("as_diffuse", props["as_diffuse"])
				# # yi.paramsSetBool("anisotropic", props["anisotropic"])
				# # yi.paramsSetFloat("exp_u", props["exp_u"])
				# # yi.paramsSetFloat("exp_v", props["exp_v"])
	# end
	# if (yafmat.type=="glass" or yafmat.type=="rought_glass")
				# p yafmat.type
				# if (yafmat.type=="rought_glass")
					# yi.paramsSetFloat("exponent",Float(yafmat.exponent))
				# end
				# yi.paramsSetFloat("IOR",Float(yafmat.IOR))
				# yi.paramsSetColor("filter_color", 0.5, 0.5, 0.5)
				# yi.paramsSetColor("mirror_color", 0.5, 0.5, 0.5)
				# yi.paramsSetFloat("transmit_filter",Float(yafmat.transmit_filter))
				# yi.paramsSetColor("absorption", 0.5, 0.5,0.5)
				# yi.paramsSetFloat("absorption_dist", Float(yafmat.absorption_dist))
				# yi.paramsSetFloat("dispersion_power", Float(yafmat.dispersion_power))
				# yi.paramsSetBool("fake_shadows", false)
	# end
	# if (yafmat.type=="light_mat")
				# yi.paramsSetString("type", "light_mat");
				# yi.paramsSetBool("double_sided", false)
				# yi.paramsSetColor("color", 1, 1, 1)
				# yi.paramsSetFloat("power",3)
	# end
	if @model_textures[matname]!=nil
			yi.paramsSetString("diffuse_shader", "diff_layer0")
			writeTexLayer(yi,"diff_layer0")
			writeMappingNode(yi,matname)
			yi.paramsEndList()
	end
	yafaraymat=yi.createMaterial(matname)  

	@materialMap[matname]=yafaraymat
end

def export_mesh(yi)
	@current_mat_step = 1
	yi.startGeometry()
	export_faces(yi)
	export_fm_faces(yi)
	if not yi.endGeometry() 
		p "error on endGeometry"
	end
end

def status_bar(stat_text)
	
	statbar = Sketchup.set_status_text stat_text
end

# #####################################################################
# #####################################################################
def export_faces(yi)
	@materials.each{|mat,value|
		if (value!=nil and value!=[])
			export_face(yi,mat,false)
			@materials[mat]=nil
		end}
	@materials={}
	@texturewriter=nil
	@model_textures=nil
end

# #####################################################################
# #####################################################################
def export_fm_faces(yi)
	@fm_materials.each{|mat,value|
		if (value!=nil and value!=[])
			export_face(yi,mat,true)
			@fm_materials[mat]=nil
		end}
	@fm_materials={}
end


# #####################################################################
# #####################################################################
def point_to_vector(p)
	Geom::Vector3d.new(p.x,p.y,p.z)
end


def export_face(yi,mat,fm_mat)
	meshes = []
	polycount = 0
	pointcount = 0
	mirrored=[]
	mat_dir=[]
	default_mat=[]
	distorted_uv=[]
	p '>>>mat'
	p mat
	
	if fm_mat		
		export=@fm_materials[mat]
	else
		
		export=@materials[mat]
	end
	
	has_texture = false
	
	if mat.class!=String
		yafmat=YafarayMaterial.new(mat)
		matname=yafmat.name
		has_texture = true if mat.texture!=nil
	else
		matname = mat
		has_texture=true if matname!=FRONTF
	end
	
	
	# if mat.respond_to?(:name)
		# yafmat=YafarayMaterial.new(mat)
		# matname=yafmat.name
		# p '>>>matname=yafmat.name'
		# p matname
		# matname = mat.display_name.gsub(/[<>]/,'*')
		# has_texture = true if mat.texture!=nil
	# else
		# matname = mat
		# has_texture=true if matname!=FRONTF
	# end

	#matname="FM_"+matname if fm_mat
		
	yafaraymat=@materialMap[matname]
  
		
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
	#status_bar("Converting Faces to Meshes: " + matname + mat_step + "...[" + current_step.to_s + "/" + total_step.to_s + "]" + " #{rest}")
	#####
	
	for face_data in export
		 
		 
		status_bar("Converting Faces to Meshes: " + matname + mat_step + "...[" + current_step.to_s + "/" + total_step.to_s + "]" + " #{rest}") if (rest%500==0)
		rest-=1
		
		face, trans, uvHelp, face_mat_dir = face_data
		
	  	polymesh=((face_mat_dir==true) ? face.mesh(5) : face.mesh(6))
		trans_inverse = trans.inverse
		default_mat.push(face_mat_dir ? face.material==nil:face.back_material==nil)
		distorted_uv.push(uvHelp)
		mat_dir.push(face_mat_dir)

		polymesh.transform! trans
	  
	 
		xa = point_to_vector(trans.xaxis)
		ya = point_to_vector(trans.yaxis)
		za = point_to_vector(trans.zaxis)
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
	
	# p 'matname '+matname
	# if @model_textures[matname]!=nil
		# main_mat = @model_textures[matname][5]
	# else
		# main_mat = mat
	# end
	
	
	
	 # #id=Yafrayinterface::new_uintp()
	 id=yi.getNextFreeID()
	 # yafmat=YafarayMaterial.new(main_mat)
	 if yafmat
		if (yafmat.type=="light_mat")
			@mesh_lights[mat]=id;
		end
	 end
	 pl=yi.startTriMesh(id, pointcount, polycount, false,has_texture,0)
	 if not pl 
	 p 'error create trimesh'
	 end
	 startindex = 0
	
	current_step += 1
	
	

	# # #Exporting verticies  points
	i=0
	for mesh in meshes
		mat_dir_tmp = mat_dir[i]
		for p in (1..mesh.count_points)
			pos = mesh.point_at(p).to_a
			yi.addVertex(pos[0]*@scale,pos[1]*@scale,pos[2]*@scale)
			norm = mesh.normal_at(p)
			norm.reverse! if mat_dir_tmp==false
			yi.addNormal(norm.x,norm.y,norm.z)
		end
	i+=1
	end
	
	
	#Export UV
	@exp_default_uvs=false
	no_texture_uvs=(!has_texture and @exp_default_uvs==true)
	if has_texture 
		current_step += 1
		i = 0

		for mesh in meshes
			
			rest -= 1

			side=(no_texture_uvs) ? true : mat_dir[i]

			for p in (1 .. mesh.count_points)
				if (default_mat[i] and @model_textures[matname]!=nil)
					inherited_texture=(@model_textures[matname][5]).texture
					texsize = Geom::Point3d.new(inherited_texture.width, inherited_texture.height, 1)
				else
					texsize = Geom::Point3d.new(1,1,1)
				end

				if distorted_uv[i]!=nil
					uvHelper=(export[i][0]).get_UVHelper(side, !side, @texturewriter)
					point_pos=mesh.point_at(p).transform!(trans.inverse)
					uvs_original=(side ? uvHelper.get_front_UVQ(point_pos) : uvHelper.get_back_UVQ(point_pos))
				else
					uvs_original=mesh.uv_at(p,side)
				end
				uv = [uvs_original.x/texsize.x, uvs_original.y/texsize.y, uvs_original.z/texsize.z]

				#out.print "#{"%.4f" %(uv.x)} #{"%.4f" %(-uv.y+1)}\n"
				yi.addUV(uv.x,uv.y)
			end
			i += 1
		end
		
	end
	
	
	

	i=0
	# #out.puts 'Shape "trianglemesh" "integer indices" ['
	 for mesh in meshes
	  	mirrored_tmp = mirrored[i]
		mat_dir_tmp = mat_dir[i]
		for poly in mesh.polygons
			v1 = (poly[0]>=0 ? poly[0] : -poly[0])+startindex
			v2 = (poly[1]>=0 ? poly[1] : -poly[1])+startindex
			v3 = (poly[2]>=0 ? poly[2] : -poly[2])+startindex
			#p "#{v1-1} #{v2-1} #{v3-1}\n"
			if !mirrored_tmp
				if mat_dir_tmp==true
					if has_texture
						yi.addTriangle(v1-1,v2-1,v3-1,v1-1,v2-1,v3-1,yafaraymat)
					else
						yi.addTriangle(v1-1,v2-1,v3-1, yafaraymat)
					end
				else
					#p "#{v1-1} #{v3-1} #{v2-1}\n"
					#yi.addTriangle(v1-1,v3-1,v2-1, yafaraymat)
					if has_texture
						yi.addTriangle(v1-1,v3-1,v2-1,v1-1,v3-1,v2-1, yafaraymat)
					else
						yi.addTriangle(v1-1,v3-1,v2-1, yafaraymat)
					end
				end
			else
				if mat_dir_tmp==true
					#p "#{v2-1} #{v1-1} #{v3-1}\n"
					#yi.addTriangle(v2-1,v1-1,v3-1, yafaraymat)
					if has_texture
						yi.addTriangle(v2-1,v1-1,v3-1,v2-1,v1-1,v3-1, yafaraymat)
					else
						yi.addTriangle(v2-1,v1-1,v3-1, yafaraymat)
					end
				else
					#p "#{v2-1} #{v3-1} #{v1-1}\n"
					#yi.addTriangle(v2-1,v3-1,v1-1, yafaraymat)
					if has_texture
						yi.addTriangle(v2-1,v3-1,v1-1,v2-1,v3-1,v1-1, yafaraymat)
					else
						yi.addTriangle(v2-1,v3-1,v1-1, yafaraymat)
					end
				end
			end		
		
		@count_tri = @count_tri + 1
	  end
	  startindex = startindex + mesh.count_points
	  i+=1
	end
	
	# # i=0
	# # #Exporting normals
	
	# # for mesh in meshes
		# # Sketchup.set_status_text("Material being exported: " + matname + mat_step + "...[" + current_step.to_s + "/" + total_step.to_s + "]" + " - Normals " + " #{rest}") if rest%500==0
		# # rest -= 1
		# # mat_dir_tmp = mat_dir[i]
		# # for p in (1..mesh.count_points)
			# # norm = mesh.normal_at(p)
			# # norm.reverse! if mat_dir_tmp==false
				# # out.print " #{"%.4f" %(norm.x)} #{"%.4f" %(norm.y)} #{"%.4f" %(norm.z)}\n"
		# # end
		# # i += 1
	# # end
	yi.endTriMesh()
	yi.smoothMesh(0, 181)
	
end



end