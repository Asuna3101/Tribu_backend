require 'sinatra'

get '/exercise/list' do
  body_part_id = params['body_part_id']
  member_id = params['member_id']
  if member_id == nil then # listado de ejercicios
    if body_part_id == nil then
      resp = Exercise.all.to_json
    else
      resp = Exercise.where(body_part_id: body_part_id).all.to_json
    end
  else # listado de ejercicios del miembro
    if member_id != nil then
      query = <<-STRING
        SELECT E.id, E.name, E.image_url, E.video_url, E.description, E.body_part_id 
        FROM exercises_members EM 
        INNER JOIN exercises E ON E.id = EM.exercise_id 
        INNER JOIN body_parts BP ON BP.id = E.body_part_id
        WHERE EM.member_id = #{member_id};
      STRING
      resp = DB[query].all.to_json
    else
      query = <<-STRING
        SELECT E.id, E.name, E.image_url, E.video_url, E.description, E.body_part_id 
        FROM exercises_members EM 
        INNER JOIN exercises E ON E.id = EM.exercise_id 
        INNER JOIN body_parts BP ON BP.id = E.body_part_id
        WHERE EM.member_id = #{member_id} AND E.body_part_id = #{body_part_id};
      STRING
      resp = DB[query].all.to_json
    end
  end
  resp
end
