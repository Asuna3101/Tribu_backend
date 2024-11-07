# Endpoint para listar todos los materiales con detalles completos
get '/material/lista' do
    materials = Material.all
    if materials
      status 200
      materials.to_json
    else
      status 404
      { error: 'No hay materiales registrados' }.to_json
    end
  end
  
# Endpoint para listar solo los nombres de los materiales
get '/material/lista-nombres' do
    material_names = Material.select(:nombre).map(:nombre)
    if material_names.any?
      status 200
      { nombres: material_names }.to_json
    else
      status 404
      { error: 'No hay materiales registrados' }.to_json
    end
  end

################################################################################
get '/material/curso/:nombre_curso' do
    nombre_curso = params[:nombre_curso]
  
    begin
      # Buscar los cursos cuyo nombre coincida (total o parcialmente)
      cursos = Curso.where(Sequel.ilike(:nombre, "%#{nombre_curso}%")).all
  
      if cursos.any?
        # Obtener los IDs de los cursos encontrados
        curso_ids = cursos.map(&:id)
  
        # Buscar los posts asociados a esos cursos a través de la tabla intermedia `post_curso`
        post_ids = PostCurso.where(curso_id: curso_ids).map(:post_id)
  
        if post_ids.any?
          # Buscar los materiales asociados a esos posts y seleccionar solo el nombre del material
          materiales = Material.where(post_id: post_ids).select(:nombre).all
  
          if materiales.any?
            status 200
            materiales.to_json
          else
            status 404
            { error: 'No hay materiales asociados a este curso' }.to_json
          end
        else
          status 404
          { error: 'No hay publicaciones asociadas a este curso' }.to_json
        end
      else
        status 404
        { error: 'Curso no encontrado' }.to_json
      end
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
  
    
  
  
  
  