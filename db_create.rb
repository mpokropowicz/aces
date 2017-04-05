
require 'pg'
load "./local_env.rb" if File.exists?("./local_env.rb")

begin

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

  # drop common table if it exists
  conn.exec "drop table if exists common"

  # create the common table
  conn.exec "create table common (
             id int primary key,
             county varchar(60),
             municipality_name varchar(60))"

  # drop ind table if it exists
  conn.exec "drop table if exists ind"

  # create the ind table with an implied foreign key (common_id)
  conn.exec "create table ind (
             id int primary key,
             common_id int,
             name varchar(50),
             street_address varchar(60),
             city varchar(45),
             zip_code smallint,
             municipality_code int,
             date_damaged date,
             longitude varchar(35),
             latitude varchar(35),
             location_notes text,
             primary_home varchar(3),
             renter varchar(3),
             foundation_home smallint,
             floor_frame_home smallint,
             exterior_walls_home smallint,
             roof_home smallint,
             interior_walls_home smallint,
             plumbing_home smallint,
             heating_ac_home smallint,
             electrical_home smallint,
             floor_frame_mobile smallint,
             exterior_walls_mobile smallint,
             roof_mobile smallint,
             interior_walls_mobile smallint,
             destroyed_home smallint,
             major_home smallint,
             minor_home smallint,
             affected_home smallint,
             inaccessible_home smallint,
             destroyed_mobile smallint,
             major_mobile smallint,
             minor_mobile smallint,
             affected_mobile smallint,
             inaccessible_mobile smallint,
             comments text,
             flood_insurance varchar(3),
             basement_water varchar(3),
             first_floor_water varchar(3),
             height_water smallint,
             add_comments text,
             assessor_name varchar(50),
             date_assessed date)"

  # drop ind_pda table if it exists
  conn.exec "drop table if exists ind_pda"

  # create the ind_pda table with an implied foreign key (common_id)
  conn.exec "create table ind_pda (
             id int primary key,
             common_id int,
             pda_date date,
             incident_type varchar(50),
             page smallint,
             total_pages smallint,
             pda_team_fema varchar(50),
             pda_team_state varchar(50),
             pda_team_sba varchar(50),
             pda_team_hlo varchar(50),
             af_own_single smallint,
             af_own_multi smallint,
             af_own_mob smallint,
             af_own_total_surv smallint,
             af_p_own smallint,
             af_own_p_fl_ins smallint,
             af_own_p_ho_ins smallint,
             af_own_p_lo_inc smallint,
             af_own_num_inac smallint,
             af_rent_single smallint,
             af_rent_multi smallint,
             af_rent_mob smallint,
             af_rent_total_surv smallint,
             af_rent_p_fl_ins smallint,
             af_rent_p_ho_ins smallint,
             af_rent_p_lo_inc smallint,
             af_rent_num_inac smallint,
             af_sec_single smallint,
             af_sec_multi smallint,
             af_sec_mob smallint,
             af_sec_total_surv smallint,
             af_sec_p_own smallint,
             af_sec_p_fl_ins smallint,
             af_sec_p_ho_ins smallint,
             af_sec_p_lo_inc smallint,
             af_sec_num_inac smallint,
             mn_own_single smallint,
             mn_own_multi smallint,
             mn_own_mob smallint,
             mn_own_total_surv smallint,
             mn_p_own smallint,
             mn_own_p_fl_ins smallint,
             mn_own_p_ho_ins smallint,
             mn_own_p_lo_inc smallint,
             mn_own_num_inac smallint,
             mn_rent_single smallint,
             mn_rent_multi smallint,
             mn_rent_mob smallint,
             mn_rent_total_surv smallint,
             mn_rent_p_fl_ins smallint,
             mn_rent_p_ho_ins smallint,
             mn_rent_p_lo_inc smallint,
             mn_rent_num_inac smallint,
             mn_sec_single smallint,
             mn_sec_multi smallint,
             mn_sec_mob smallint,
             mn_sec_total_surv smallint,
             mn_sec_p_own smallint,
             mn_sec_p_fl_ins smallint,
             mn_sec_p_ho_ins smallint,
             mn_sec_p_lo_inc smallint,
             mn_sec_num_inac smallint,
             mj_own_single smallint,
             mj_own_multi smallint,
             mj_own_mob smallint,
             mj_own_total_surv smallint,
             mj_p_own smallint,
             mj_own_p_fl_ins smallint,
             mj_own_p_ho_ins smallint,
             mj_own_p_lo_inc smallint,
             mj_own_num_inac smallint,
             mj_rent_single smallint,
             mj_rent_multi smallint,
             mj_rent_mob smallint,
             mj_rent_total_surv smallint,
             mj_rent_p_fl_ins smallint,
             mj_rent_p_ho_ins smallint,
             mj_rent_p_lo_inc smallint,
             mj_rent_num_inac smallint,
             mj_sec_single smallint,
             mj_sec_multi smallint,
             mj_sec_mob smallint,
             mj_sec_total_surv smallint,
             mj_sec_p_own smallint,
             m_sec_p_fl_ins smallint,
             m_sec_p_ho_ins smallint,
             mj_sec_p_lo_inc smallint,
             mj_sec_num_inac smallint,
             d_own_single smallint,
             d_own_multi smallint,
             d_own_mob smallint,
             d_own_total_surv smallint,
             d_p_own smallint,
             d_own_p_fl_ins smallint,
             d_own_p_ho_ins smallint,
             d_own_p_lo_inc smallint,
             d_own_num_inac smallint,
             d_rent_single smallint,
             d_rent_multi smallint,
             d_rent_mob smallint,
             d_rent_total_surv smallint,
             d_rent_p_fl_ins smallint,
             d_rent_p_ho_ins smallint,
             d_rent_p_lo_inc smallint,
             d_rent_num_inac smallint,
             d_sec_single smallint,
             d_sec_multi smallint,
             d_sec_mob smallint,
             d_sec_total_surv smallint,
             d_sec_p_own smallint,
             d_sec_p_fl_ins smallint,
             d_sec_p_ho_ins smallint,
             d_sec_p_lo_inc smallint,
             d_sec_num_inac smallint,
             roads_bridges_damaged smallint,
             households_impacted smallint,
             households_no_utilities smallint,
             est_date_utility_restore smallint,
             comments text)"

rescue PG::Error => e

  puts 'Exception occurred'
  puts e.message

ensure

  conn.close if conn

end