# Endpoint para obtener todas las reacciones de un post específico
get '/post/:post_id/likes' do
    post_id = params[:post_id].to_i
  
    begin
      reacciones = Reaccion.where(post_id: post_id).all
  
      if reacciones.any?
        formatted_reacciones = reacciones.map do |reaccion|
          {
            id: reaccion.id,
            usuario: {
              id: reaccion.usuario.id,
              nombre: reaccion.usuario.nombre
            },
            fecha: reaccion.fecha
          }
        end
  
        status 200
        { total_likes: reacciones.count, usuarios: formatted_reacciones }.to_json
      else
        status 404
        { error: 'No hay likes para este post' }.to_json
      end
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end

######################################
# Endpoint para obtener todos los likes de un usuario específico
get '/usuario/:usuario_id/likes' do
    usuario_id = params[:usuario_id].to_i
  
    begin
      reacciones = Reaccion.where(usuario_id: usuario_id).all
  
      if reacciones.any?
        formatted_reacciones = reacciones.map do |reaccion|
          {
            post_id: reaccion.post_id,
            fecha: reaccion.fecha
          }
        end
  
        status 200
        formatted_reacciones.to_json
      else
        status 404
        { error: 'Este usuario no ha dado likes' }.to_json
      end
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
#######################################
# Endpoint para dar o quitar "like" a un post
post '/post/:post_id/like' do
    post_id = params[:post_id].to_i
    data = JSON.parse(request.body.read) rescue {}
    usuario_id = data['usuario_id']
  
    begin
      # Buscar si ya existe una reacción de este usuario en el post
      reaccion = Reaccion.find(post_id: post_id, usuario_id: usuario_id)
  
      if reaccion
        # Si ya existe, quitar el like
        reaccion.delete
        status 200
        { message: 'Like removido' }.to_json
      else
        # Si no existe, crear una nueva reacción (like)
        Reaccion.create(
          post_id: post_id,
          usuario_id: usuario_id,
          fecha: Time.now
        )
        status 201
        { message: 'Like agregado' }.to_json
      end
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
    
  