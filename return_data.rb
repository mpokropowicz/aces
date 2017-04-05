# Example program to return all data from details and quotes tables

require 'pg'
load "./local_env.rb" if File.exists?("./local_env.rb")

def open_db()
  begin
    # connect to the database
   # db_params = {  # local test
   #      dbname:ENV['dbname'],
   #      user:ENV['dbuser'],
   #      password:ENV['dbpassword']
   #    }
   db_params = {  # AWS db
        host: ENV['host'],
        port:ENV['port'],
        dbname:ENV['dbname'],
        user:ENV['dbuser'],
        password:ENV['dbpassword']
      }
    conn = PG::Connection.new(db_params)
  rescue PG::Error => e
    puts 'Exception occurred'
    puts e.message
  end
end

def update_values(columns)
  begin
    id = columns["id"]  # determine the id for the current record
    conn = open_db() # open database for updating
    columns.each do |column, value|  # iterate through columns hash for each column/value pair
      unless column == "id"  # we do NOT want to update the id
        table = match_table(column)  # determine which table contains the specified column
        # workaround for table name being quoted and column name used as bind parameter
        query = "update " + table + " set " + column + " = $2 where id = $1"
        conn.prepare('q_statement', query)
        rs = conn.exec_prepared('q_statement', [id, value])
        conn.exec("deallocate q_statement")
      end
    end
  rescue PG::Error => e
    puts 'Exception occurred'
    puts e.message
  ensure
    conn.close if conn
  end
end

def get_data(user_name)
  begin
    conn = open_db()
    conn.prepare('q_statement',
                 "select *
                  from common
                  join ind on common.id = ind.common_id
                  where ind.id = '#{user_name}'")
    user_hash = conn.exec_prepared('q_statement')
    conn.exec("deallocate q_statement")
    return user_hash[0]
  rescue PG::Error => e
    puts 'Exception occurred'
    puts e.message
  ensure
    conn.close if conn
  end
end

def match_column(value)
  begin
    columns = ["municipality_name", "name", "street_address"]
    target = ""
    conn = open_db() # open database for updating
    columns.each do |column|  # determine which column contains the specified value
     query = "select " + column +
             " from common
              join ind on common.id = ind.common_id"
      conn.prepare('q_statement', query)
      rs = conn.exec_prepared('q_statement')
      conn.exec("deallocate q_statement")
      results = rs.values.flatten
      (results.include? value) ? (return column) : (target = "")
    end
    return target
  rescue PG::Error => e
    puts 'Exception occurred'
    puts e.message
  ensure
    conn.close if conn
  end
end

def match_table(column)
  begin
    tables = ["common", "ind"]
    target = ""
    conn = open_db() # open database for updating
    tables.each do |table|  # determine which table contains the specified column
      conn.prepare('q_statement',
                   "select column_name
                    from information_schema.columns
                    where table_name = $1")  # bind parameter
      rs = conn.exec_prepared('q_statement', [table])
      conn.exec("deallocate q_statement")
      columns = rs.values.flatten
      target = table if columns.include? column
    end
    return target
  rescue PG::Error => e
    puts 'Exception occurred'
    puts e.message
  ensure
    conn.close if conn
  end
end

def pull_records(value)
  begin
    column = match_column(value)  # determine which column contains the specified value
    unless column == ""
      results = []  # array to hold all matching hashes
      conn = open_db()
      query = "select *
              from common
              join ind on common.id = ind.common_id
              where " + column + " = $1"  # bind parameter
      conn.prepare('q_statement', query)
      rs = conn.exec_prepared('q_statement', [value])
      conn.exec("deallocate q_statement")
      rs.each { |result| results.push(result) }
      return results
    else
      return [{"quote" => "No matching record - please try again."}]
    end
  rescue PG::Error => e
    puts 'Exception occurred'
    puts e.message
  ensure
    conn.close if conn
  end
end
# def pull_records(fname, faddress)
#   begin
#     results = []  # array to hold all matching hashes
#     db_params = {  # AWS db
#         host: ENV['host'],
#         port:ENV['port'],
#         dbname:ENV['dbname'],
#         user:ENV['dbuser'],
#         password:ENV['dbpassword']
#       }
#   # db_params = {  # local db
#   #       dbname:ENV['dbname'],
#   #       user:ENV['dbuser'],
#   #       password:ENV['dbpassword']
#   #     }
#   conn = PG::Connection.new(db_params)
#     query = "select name, street_address
#              from ind
#              where upper(name) like upper('%#{fname}%')
#              and upper(street_address) like upper('%#{faddress}%')"
#     conn.prepare('q_statement', query)
#     rs = conn.exec_prepared('q_statement')
#     conn.exec("deallocate q_statement")
#     rs.each { |result| results.push(result) }
#     return results
#   rescue PG::Error => e
#     puts 'Exception occurred'
#     puts e.message
#   ensure
#     conn.close if conn
#   end
# end


# Sandbox testing


# Example output
# {"id"=>"1", "county"=>"Allegheny", "municipality_name"=>nil, "common_id"=>"1", "name"=>nil, "street_address"=>nil, "city"=>nil, "zip_code"=>nil, "municipality_code"=>nil, "date_damaged"=>nil, "longitude"=>nil, "latitude"=>nil, "location_notes"=>nil, "primary_home"=>nil, "renter"=>nil, "foundation_home"=>nil, "floor_frame_home"=>nil, "exterior_walls_home"=>nil, "roof_home"=>nil, "interior_walls_home"=>nil, "plumbing_home"=>nil, "heating_ac_home"=>nil, "electrical_home"=>nil, "floor_frame_mobile"=>nil, "exterior_walls_mobile"=>nil, "roof_mobile"=>nil, "interior_walls_mobile"=>nil, "destroyed_home"=>nil, "major_home"=>nil, "minor_home"=>nil, "affected_home"=>nil, "inaccessible_home"=>nil, "destroyed_mobile"=>nil,"major_mobile"=>nil, "minor_mobile"=>nil, "affected_mobile"=>nil, "inaccessible_mobile"=>nil, "comments"=>nil, "flood_insurance"=>nil, "basement_water"=>nil, "first_floor_water"=>nil, "height_water"=>nil, "add_comments"=>nil, "assessor_name"=>nil, "date_assessed"=>"2016-04-04"}
# {"id"=>"2", "county"=>"Allegheny", "municipality_name"=>"Ohara Township", "common_id"=>"2", "name"=>"John Doe", "street_address"=>"123 Main Street", "city"=>"Pittsburgh", "zip_code"=>"15215", "municipality_code"=>"700102", "date_damaged"=>"2017-01-26", "longitude"=>"40.502422", "latitude"=>"-79.919777", "location_notes"=>nil, "primary_home"=>"yes", "renter"=>"no", "foundation_home"=>nil, "floor_frame_home"=>nil, "exterior_walls_home"=>nil, "roof_home"=>nil, "interior_walls_home"=>nil, "plumbing_home"=>nil, "heating_ac_home"=>nil, "electrical_home"=>nil, "floor_frame_mobile"=>nil, "exterior_walls_mobile"=>nil, "roof_mobile"=>nil, "interior_walls_mobile"=>nil, "destroyed_home"=>nil, "major_home"=>nil, "minor_home"=>nil, "affected_home"=>nil, "inaccessible_home"=>nil, "destroyed_mobile"=>nil, "major_mobile"=>nil, "minor_mobile"=>nil, "affected_mobile"=>nil, "inaccessible_mobile"=>nil, "comments"=>"Initial contact established, will assess on 4/18/2017.", "flood_insurance"=>nil, "basement_water"=>nil, "first_floor_water"=>nil, "height_water"=>nil, "add_comments"=>nil,"assessor_name"=>nil, "date_assessed"=>"2016-02-01"}