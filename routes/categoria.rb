get '/categoria/listar' do
    status = 200
    begin
        rs = Categoria.all # SELECT * FROM categorias;
        if rs
            resp = rs.to_json
        else
            resp = 'No hay categorías registradas.'
            status = 404
        end
    rescue StandardError => e
        status = 500
        resp = 'Ocurrió un error no esperado al listar todas las categorías'
        puts e.message
    end
    # response
    status status
    resp
end

get '/categoria/listar2' do
    Categoria.all.to_json
end