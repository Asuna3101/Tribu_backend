get '/profesor/:id/calificaciones' do
    profesor_id = params[:id].to_i
  
    begin
      # Obtener todas las calificaciones del profesor con el nombre del usuario
      calificaciones = DB[:calificaciones]
                         .join(:usuarios, id: :usuario_id)
                         .where(profesor_id: profesor_id)
                         .select(:resenia, :estrella, :fecha_subida, Sequel[:usuarios][:nombre].as(:usuario_nombre))
                         .all
  
      if calificaciones.any?
        status 200
        { calificaciones: calificaciones }.to_json
      else
        status 404
        { error: 'No se encontraron calificaciones para este profesor' }.to_json
      end
    rescue StandardError => e
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
  
  