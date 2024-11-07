#ENDPOINT PARA LISTAR A TODOS LOS PROFESORES
get '/profesores/lista' do
    status = 200
    begin
      profesores = Profesor.all # Realiza la consulta para obtener todos los profesores
      if profesores.any?
        resp = profesores.to_json
      else
        resp = { message: 'No hay profesores registrados.' }.to_json
        status = 404
      end
    rescue StandardError => e
      status = 500
      resp = { error: 'Ocurrió un error al listar los profesores', detalle: e.message }.to_json
    end
    # Respuesta
    status status
    resp
  end
  #ENDPOINT PARA BUSCAR POR NOMBRE DEL PROFESOR
  get '/profesores/buscar' do
    nombre = params[:nombre]
  
    if nombre.nil? || nombre.strip.empty?
      status 400
      return { error: 'Debe proporcionar un nombre para buscar' }.to_json
    end
  
    begin
      profesores = Profesor.where(Sequel.ilike(:nombre, "%#{nombre}%")).all # Busca coincidencias parciales sin importar mayúsculas/minúsculas
      if profesores.empty?
        status 404
        { error: 'No se encontraron profesores con ese nombre' }.to_json
      else
        status 200
        profesores.to_json
      end
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
#ENDPOINT PARA BUSCAR POR NOMBRE DE CURSO

get '/profesores/curso/:nombre_curso' do
  nombre_curso = params[:nombre_curso]

  begin
    # Buscar los cursos cuyo nombre coincida (total o parcialmente)
    cursos = Curso.where(Sequel.ilike(:nombre, "%#{nombre_curso}%")).all

    if cursos.any?
      # Obtener los ID de los cursos encontrados
      curso_ids = cursos.map(&:id)

      # Buscar los profesores asociados a esos cursos a través de la tabla intermedia curso_profesor
      profesor_ids = CursoProfesor.where(curso_id: curso_ids).map(:profesor_id)

      if profesor_ids.any?
        # Buscar los profesores por sus IDs y obtener solo los nombres
        profesores = Profesor.where(id: profesor_ids).select(:nombre).all

        if profesores.any?
          status 200
          profesores.to_json
        else
          status 404
          { error: 'No hay profesores asociados a este curso' }.to_json
        end
      else
        status 404
        { error: 'No hay profesores asociados a este curso' }.to_json
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


  
  