get '/carrera/listar' do
  status = 200

  begin
    rs = Carrera.all
    if rs
      resp = rs.to_json
    else
      resp = 'No hay carreras'
      status = 404
    end
  rescue StandardError => e
    status = 500
    resp = 'Ocurrió un error no esperado al listar carreras'
    puts e.message
  end
  # response
  status status
  resp
end
