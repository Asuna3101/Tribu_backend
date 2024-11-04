require 'sinatra'

get '/body_part/list' do
  member_id = params[:member_id]
  if member_id == nil then
    BodyPart.all.to_json
  else
    query = <<-STRING
        SELECT BP.id, BP.name FROM exercises_members EM 
        INNER JOIN exercises E ON E.id = EM.exercise_id 
        INNER JOIN body_parts BP ON BP.id = E.body_part_id 
        WHERE member_id = #{member_id}
        GROUP BY BP.id;
      STRING
    DB[query].all.to_json
  end
end
