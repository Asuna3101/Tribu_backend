# Endpoint para obtener todos los posts, ordenados del más reciente al más antiguo
get '/posts/lista' do
    begin
      # Recuperar todos los posts y ordenarlos por fecha de subida (más reciente primero)
      posts = Post.order(Sequel.desc(:fecha_subida_post)).all
  
      if posts.any?
        # Convertir a JSON y devolver el resultado
        status 200
        posts.to_json
      else
        # Si no hay posts, retornar un mensaje indicando la ausencia
        status 404
        { message: 'No hay publicaciones registradas.' }.to_json
      end
    rescue StandardError => e
      # Manejo de errores
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
  ##############################################################################################