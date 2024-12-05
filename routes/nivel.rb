get '/nivel/listar' do
  status = 200
  begin
    rs = Nivel.select(:id, :nombre).all  # Solo seleccionamos los campos que necesitamos
    if rs.any?
      resp = rs.to_json  # Convertimos el resultado a JSON
    else
      resp = { message: 'No hay niveles disponibles' }.to_json
      status = 404  # No se encontraron niveles
    end
  rescue StandardError => e
    status = 500
    resp = { error: 'Ocurrió un error inesperado al listar niveles', details: e.message }.to_json
    puts e.message
  end

  content_type :json  # Establecemos el tipo de contenido a JSON
  status status
  resp
end
