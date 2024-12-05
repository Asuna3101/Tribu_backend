#ENDPOINT PARA LISTAR A TODOS LOS PROFESORES
get '/profesores/lista' do
  begin
    # Consulta para obtener los datos de los profesores con JOIN entre las tablas
    profesores = DB[:profesores]
                 .join(:curso_profesor, profesor_id: :id)
                 .join(:cursos, id: Sequel[:curso_profesor][:curso_id])
                 .select(
                   Sequel[:profesores][:id].as(:profesor_id),
                   Sequel[:profesores][:nombre].as(:nombre),
                   Sequel[:profesores][:correo].as(:correo),
                   Sequel[:profesores][:biografia].as(:biografia),
                   Sequel[:profesores][:foto].as(:foto),
                   Sequel.lit('GROUP_CONCAT(cursos.nombre ) ').as(:cursos)
                 )
                 .group_by(Sequel[:profesores][:id])  # Agrupar por ID del profesor
                 .all

    if profesores.any?
      # Devolver los datos en formato JSON
      status 200
      profesores.to_json
    else
      # Si no hay profesores
      status 404
      { message: 'No hay profesores registrados o asociados a cursos.' }.to_json
    end
  rescue StandardError => e
    # Manejo de errores
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
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

# Endpoint para obtener el perfil básico de un profesor
get '/profesor/:id' do
  profesor_id = params[:id].to_i

  begin
    # Encontrar el profesor por su ID, incluyendo sus cursos
    profesor = Profesor.eager(:cursos).where(id: profesor_id).first

    if profesor
      # Formatear la respuesta con la información básica del profesor
      perfil = {
        id: profesor.id,
        nombre: profesor.nombre,
        correo: profesor.correo,
        biografia: profesor.biografia,
        cursos: profesor.cursos.map { |curso| curso.nombre }
      }

      status 200
      perfil.to_json
    else
      status 404
      { error: 'Profesor no encontrado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end


  
  