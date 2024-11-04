get '/seccion/alumno' do
  status = 200
  alumno_id = params['alumno_id']
  begin
    query = <<-STRING
      SELECT 
        D.id AS docente_id,
        D.apellidos || ', ' || D.nombres AS docente_nombre,
        C.id AS curso_id,
        C.codigo AS curso_codigo,
        C.nombre AS curso_nombre,
        C.descripcion AS curso_descripcion,
        C.imagen AS curso_imagen,
        S.id AS seccion_id, 
        S.codigo AS seccion_codigo,
        S.fecha_inicio,
        S.fecha_fin,
        S.diploma
      FROM secciones S 
      INNER JOIN cursos C ON S.curso_id = C.id
      INNER JOIN docentes D ON D.id = S.docente_id
      INNER JOIN secciones_alumnos SA ON SA.seccion_id = S.id
      WHERE alumno_id = #{alumno_id};
    STRING
    rs = DB[query].all
    if rs
      resp = rs.to_json
    else
      resp = 'Alumno no tiene matriculas activas'
      status = 404
    end
  rescue StandardError => e
    status = 500
    resp = 'Ocurrió un error no esperado al buscar las secciones del alumno'
    puts e.message
  end
  # response
  status status
  resp
end
