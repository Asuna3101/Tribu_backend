get '/profesores/:id/calificaciones' do
  profesor_id = params[:id].to_i

  begin
    # Consulta para obtener las calificaciones con los datos adicionales del usuario
    calificaciones = DB[:calificaciones]
                      .join(:usuarios, id: :usuario_id) # Unión con la tabla de usuarios
                      .join(:carreras, id: Sequel[:usuarios][:carrera_id]) # Unión con la tabla de carreras
                      .where(profesor_id: profesor_id) # Filtra por el ID del profesor
                      .select(
                        :resenia,
                        :estrella,
                        :fecha_subida,
                        Sequel[:usuarios][:nombre].as(:usuario_nombre), # Nombre del usuario
                        Sequel[:usuarios][:foto].as(:usuario_foto), # Foto del usuario
                        Sequel[:carreras][:nombre].as(:carrera_usuario) # Carrera del usuario
                      )
                      .order(Sequel.desc(:fecha_subida)) # Ordenar por la fecha más reciente
                      .all

    if calificaciones.any?
      # Respuesta con calificaciones en formato JSON
      status 200
      { calificaciones: calificaciones }.to_json
    else
      # Si no hay calificaciones para este profesor
      status 404
      { error: 'No se encontraron calificaciones para este profesor' }.to_json
    end
  rescue StandardError => e
    # Manejo de errores en el servidor
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end


##########################
get '/profesor/:id/promedio-calificaciones' do
    profesor_id = params[:id].to_i
  
    begin
      # Obtener todas las calificaciones del profesor
      calificaciones = Calificacion.where(profesor_id: profesor_id).all
  
      if calificaciones.any?
        # Calcular el promedio de estrellas
        promedio = calificaciones.map { |c| c[:estrella] }.sum.to_f / calificaciones.size
        status 200
        { promedio: promedio }.to_json
      else
        status 404
        { error: 'No se encontraron calificaciones para este profesor' }.to_json
      end
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
#############################
# Endpoint para realizar una calificación a un profesor
post '/profesor/:id/calificacion' do
    profesor_id = params[:id].to_i
    data = JSON.parse(request.body.read)
  
    # Parámetros esperados: id del usuario (usuario_id), estrella, y reseña
    usuario_id = data['usuario_id']
    estrella = data['estrella']
    resenia = data['resenia']
  
    # Validación de datos
    if usuario_id.nil? || estrella.nil? || resenia.nil?
      status 400
      return { error: 'Debe proporcionar usuario_id, estrella, y resenia' }.to_json
    end
  
    begin
      # Crear una nueva calificación
      calificacion = Calificacion.create(
        usuario_id: usuario_id,
        profesor_id: profesor_id,
        estrella: estrella,
        resenia: resenia,
        fecha_subida: Time.now
      )
  
      status 201
      { message: 'Calificación creada con éxito', calificacion: calificacion }.to_json
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
  
  