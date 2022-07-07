# insert conditional value for campus, if not multi-campus!
# check harlanpester -- why multi records, and not aligned from ccb?
require 'rubygems'
require 'pp'
require 'date'
require 'curl'
require 'csv'
#require 'dotenv'
#require 'dotenv-rails'
require 'xmlsimple'
require "open-uri"
require 'fileutils'
##############################
username = '<username>'
password = '<password>'
ccb_url = "<url>"
##############################
ccb_service = "group_profiles"
ccb_search_parm = "modified_since"
ccb_search_parm2 = "2019-01-01"
ccb_array = []
ccb_array2 = []
group_members = []
group_leaders = []

datestamp = Time.now
recordcount = 0

ccbfile = "output/ccbgroups_#{datestamp.strftime("%y%m%d%H%M")}.csv"
leaderfile = "output/ccb-groupleader-#{datestamp.strftime("%y%m%d%H%M")}.csv"
memberfile = "output/ccb-groupmember-#{datestamp.strftime("%y%m%d%H%M")}.csv"

puts("==================================================================================================")
puts("CCB Group Extraction Script - intended to export group profile detail info from CCB")
puts("==================================================================================================")
puts("")
puts("Extraction Mode:")
puts "******************************************************"
      puts "Beginning to extracting groups... (This may take several minutes)"
        target_url = "#{ccb_url}" + "?srv=" + "#{ccb_service}" + "&" + "#{ccb_search_parm}" + "=" + "#{ccb_search_parm2}"
        get = Curl::Easy.new(target_url)
        get.http_auth_types = :basic
        get.username = username
        get.password = password
        get.perform
        hashdata = XmlSimple.xml_in get.body_str
        # puts hashdata["response"][0]["groups"][0]["group"].class
        hashdata["response"][0]["groups"][0]["group"].each do |group|
          @group_id                         =group["id"]
          @group_name                       =group["name"][0]
          group_description                 =group["description"][0]
          group_image                       =group["image"][0]
          group_campus_name                 =group["campus"][0]["content"]
          group_campus_id                   =group["campus"][0]["id"]

          group_main_leader_id              =group["main_leader"][0]["id"]
          group_main_leader_name            =group["main_leader"][0]["full_name"][0]

          group_leaders_array               =group["leaders"]   #array
          group_members_array               =group["participants"]   #array
          # pp group_leaders_array[0]["leader"]
          if !group_leaders_array[0]["leader"].nil?
            group_leaders_array[0]["leader"].each do |gl|
              group_leaders << {
                :group_id       => @group_id,
                :group_name     => @group_name,
                :person_id      => gl["id"],
                :first_name     => gl["first_name"][0],
                :last_name      => gl["last_name"][0],
                :full_name      => gl["full_name"][0],
                :email          => gl["email"][0]
              }
            end
          end

          if !group_members_array[0]["participant"].nil?
            group_members_array[0]["participant"].each do |gm|
              group_members << {
                :group_id       => @group_id,
                :group_name     => @group_name,
                :person_id      => gm["id"],
                :first_name     => gm["first_name"][0],
                :last_name      => gm["last_name"][0],
                :full_name      => gm["full_name"][0],
                :email          => gm["email"][0],
                :status         => gm["status"][0]
                # p_phone_numbers            # array
              }
            end
          end
  # puts "#{@group_id},#{@group_name},#{group_description},#{group_image},#{group_campus_name},#{group_campus_id},#{group_main_leader_id},#{group_main_leader_name}"

        end

puts "GroupMembers CSV Export..."
File.open(memberfile,"a+") do |gm|
  gm.puts "group_id,group_name,person_id,first_name,last_name,full_name,email,status"
  group_members.each do |mbr|
      gm.puts "#{mbr[:group_id]},#{mbr[:group_name]},#{mbr[:person_id]},#{mbr[:first_name]},#{mbr[:last_name]},#{mbr[:full_name]},#{mbr[:email]},#{mbr[:status]}"
  end
end

puts "GroupLeaders CSV Export..."
File.open(leaderfile,"a+") do |gl|
  gl.puts "group_id,group_name,person_id,first_name,last_name,full_name"
  group_leaders.each do |ldr|
      gl.puts "#{ldr[:group_id]},#{ldr[:group_name]},#{ldr[:person_id]},#{ldr[:first_name]},#{ldr[:last_name]},#{ldr[:full_name]}"
  end
end

puts "Done!"
