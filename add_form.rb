# Example program to insert data into details and quotes tables

require 'pg'
load "./local_env.rb" if File.exists?("./local_env.rb")

def add_form(form_hash)
  begin

    form_hash = Hash[ form_hash.map{ |a, b| [ a,
                            begin
                              Integer b
                            rescue ArgumentError
                              b
                            end ] } ]

    form_hash.each do |form, value|
      form_hash[form] = 0 if value == ""
    end

    print form_hash

# aggregate user data into multi-dimensional array for iteration
  ind_forms = []
  ind_forms.push(form_hash)

  # connect to the database
  # db_params = {  # AWS db
  #       host: ENV['host'],
  #       port:ENV['port'],
  #       dbname:ENV['dbname'],
  #       user:ENV['dbuser'],
  #       password:ENV['dbpassword']
  #     }
  db_params = {  # AWS db
        host: ENV['host'],
        port:ENV['port'],
        dbname:ENV['dbname'],
        user:ENV['dbuser'],
        password:ENV['dbpassword']
      }
  # db_params = {  # local db
  #       dbname:ENV['dbname'],
  #       user:ENV['dbuser'],
  #       password:ENV['dbpassword']
  #     }
  conn = PG::Connection.new(db_params)

  # local database connection
  # db_params = {
  #   dbname:ENV['dbname'],
  #   user:ENV['dbuser'],
  #   password:ENV['dbpassword']
  # }
  # conn = PG.connect(dbname: ENV['dbname'], user: ENV['dbuser'], password: ENV['dbpassword'])

  # determine current max index (id) in details table
  max_id = conn.exec("select max(id) from common")[0]

  # set index variable based on current max index value
  max_id["max"] == nil ? v_id = 1 : v_id = max_id["max"].to_i + 1

  # iterate through multi-dimensional users array for data
  ind_forms.each do |form|

    # initialize variables for SQL insert statements
    v_county = form["county"]
    v_municipality_name = form["municipality_name"]
    v_name = form["name"]
    v_street_address = form["street_address"]
    v_city = form["city"]
    v_zip_code = form["zip_code"]
    v_municipality_code = form["municipality_code"]
    v_date_damaged = form["date_damaged"]
    v_longitude = form["longitude"]
    v_latitude = form["latitude"]
    v_location_notes = form["location_notes"]
    v_primary_home = form["primary_home"]
    v_renter = form["renter"]
    v_foundation_home = form["foundation_home"]
    v_floor_frame_home = form["floor_frame_home"]
    v_exterior_walls_home = form["exterior_walls_home"]
    v_roof_home = form["roof_home"]
    v_interior_walls_home = form["interior_walls_home"]
    v_plumbing_home = form["plumbing_home"]
    v_heating_ac_home = form["heating_ac_home"]
    v_electrical_home = form["electrical_home"]
    v_floor_frame_mobile = form["floor_frame_mobile"]
    v_exterior_walls_mobile = form["exterior_walls_mobile"]
    v_roof_mobile = form["roof_mobile"]
    v_interior_walls_mobile = form["interior_walls_mobile"]
    v_destroyed_home = form["destroyed_home"]
    v_major_home = form["major_home"]
    v_minor_home = form["minor_home"]
    v_affected_home = form["affected_home"]
    v_inaccessible_home = form["inaccessible_home"]
    v_destroyed_mobile = form["destroyed_mobile"]
    v_major_mobile = form["major_mobile"]
    v_minor_mobile = form["minor_mobile"]
    v_affected_mobile = form["affected_mobile"]
    v_inaccessible_mobile = form["inaccessible_mobile"]
    v_comments = form["comments"]
    v_flood_insurance = form["flood_insurance"]
    v_basement_water = form["basement_water"]
    v_first_floor_water = form["first_floor_water"]
    v_height_water = form["height_water"]
    v_add_comments = form["add_comments"]
    v_assessor_name = form["assessor_name"]
    v_date_assessed = form["date_assessed"]

    # prepare SQL statement to insert common individual form fields into common table
    conn.prepare('q_statement',
                 "insert into common
                   (id, county, municipality_name)
                  values($1, $2, $3)")  # bind parameters

    # execute prepared SQL statement
    conn.exec_prepared('q_statement', [v_id, v_county, v_municipality_name])

    # deallocate prepared statement variable (avoid error "prepared statement already exists")
    conn.exec("deallocate q_statement")

    # prepare SQL statement to insert unique individual form fields into ind table
    conn.prepare('q_statement',
                 "insert into ind (id, common_id, name, street_address, city,
                    zip_code, municipality_code, date_damaged, longitude, latitude,
                    location_notes, primary_home, renter, foundation_home,
                    floor_frame_home, exterior_walls_home, roof_home,
                    interior_walls_home, plumbing_home, heating_ac_home,
                    electrical_home, floor_frame_mobile, exterior_walls_mobile,
                    roof_mobile, interior_walls_mobile, destroyed_home, major_home,
                    minor_home, affected_home, inaccessible_home, destroyed_mobile,
                    major_mobile, minor_mobile, affected_mobile, inaccessible_mobile,
                    comments, flood_insurance, basement_water, first_floor_water,
                    height_water, add_comments, assessor_name, date_assessed)
                  values($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14,
                    $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27,
                    $28, $29, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $40,
                    $41, $42, $43)")

    # execute prepared SQL statement
    conn.exec_prepared('q_statement', [v_id, v_id, v_name, v_street_address, v_city,
                    v_zip_code, v_municipality_code, v_date_damaged, v_longitude, v_latitude,
                    v_location_notes, v_primary_home, v_renter, v_foundation_home,
                    v_floor_frame_home, v_exterior_walls_home, v_roof_home,
                    v_interior_walls_home, v_plumbing_home, v_heating_ac_home,
                    v_electrical_home, v_floor_frame_mobile, v_exterior_walls_mobile,
                    v_roof_mobile, v_interior_walls_mobile, v_destroyed_home, v_major_home,
                    v_minor_home, v_affected_home, v_inaccessible_home, v_destroyed_mobile,
                    v_major_mobile, v_minor_mobile, v_affected_mobile, v_inaccessible_mobile,
                    v_comments, v_flood_insurance, v_basement_water, v_first_floor_water,
                    v_height_water, v_add_comments, v_assessor_name, v_date_assessed])

    # deallocate prepared statement variable (avoid error "prepared statement already exists")
    conn.exec("deallocate q_statement")

    # increment index value for next iteration
    v_id += 1

  end

rescue PG::Error => e

  puts 'Exception occurred'
  puts e.message

ensure

  conn.close if conn

end
end