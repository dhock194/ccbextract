require 'rubygems'
require 'pp'
require 'date'
require 'curl'
require 'csv'
require 'xmlsimple'
require "open-uri"
require 'fileutils'
##############################
username = '<username>'
password = '<password>'
ccb_url = "<url>"
##############################
ccb_service = "event_profiles"
ccb_search_parm = "modified_since"
ccb_search_parm2 = "2010-08-01"
ccb_array = []
ccb_array2 = []
datestamp = Time.now
recordcount = 0

ccbheader = "id,name,description,leader_notes,start_datetime,end_date,end_time,timezone,recurrence_description,recurrence_description,approval_status,group,organizer,phone,loc_name,loc_street,loc_city,loc_state,loc_zip,loc_line1,loc_line2,reg_limit,reg_event_type,reg_forms_id,reg_form_name,guest_list,resources,setup_start,setup_end,setup_notes,event_grouping,creator,modifier,listed,public_calendar_listed,image,created,modified"
ccb_array << ccbheader
ccbfile = "output/ccbevents_#{datestamp.strftime("%y%m%d%H%M")}.csv"

puts("==================================================================================================")
puts("CCB Batch Extraction Script - intended to export events detail info from CCB")
puts("==================================================================================================")
puts("")
puts("Extraction Mode:")
puts "******************************************************"
      puts "Beginning to extracting transactions... (This may take several minutes)"
        target_url = "#{ccb_url}" + "?srv=" + "#{ccb_service}" + "&" + "#{ccb_search_parm}" + "=" + "#{ccb_search_parm2}"
        get = Curl::Easy.new(target_url)
        get.http_auth_types = :basic
        get.username = username
        get.password = password
        get.perform
        hashdata = XmlSimple.xml_in get.body_str
        event = hashdata["response"][0]["events"][0]["event"]
        event.each do |e|
          id = e["id"]
          name = e["name"][0]
          name = name.gsub(/[\,]/ ,"")
          !e["description"][0].empty? ? description = e["description"][0] : description = ""
          description = description.gsub(/[\,]/ ,"")
          description = description.gsub(/]*>/, "")
          description.delete!("\n")
          description.delete!("\r")
          description.delete!(",")
          !e["leader_notes"][0].empty? ? leader_notes = e["leader_notes"][0] : leader_notes = ""
          start_datetime = e["start_datetime"][0]
          start_date = e["start_date"][0]
          start_date.delete!(",")
          start_time = e["start_time"][0]
          end_datetime = e["end_datetime"][0]
          end_date = e["end_date"][0]
          end_date.delete!(",")
          end_time = e["end_time"][0]
          timezone = e["timezone"][0]
          recurrence_description = e["recurrence_description"][0]
          recurrence_description.delete!(",")
          approval_status = e["approval_status"][0]["content"]
          #!e["exceptions"][0].empty? ? exceptions = e["exceptions"][0] : exceptions = ""
          group = e["group"][0]["content"]
          organizer = e["organizer"][0]["content"]
          !["phone"][0]["content"].nil? ? phone = e["phone"][0]["content"] : phone = ""
          if !e["location"][0].empty?
              !e["location"][0]["name"][0].empty? ? loc_name = e["location"][0]["name"][0] : loc_name = ""
              loc_name.delete!("\n")
              loc_name.delete!("\r")
              loc_name.delete!(",")
              !e["location"][0]["street_address"][0].empty? ? loc_street = e["location"][0]["street_address"][0] : loc_street = ""
              loc_street.delete!("\n")
              loc_street.delete!(",")
              !e["location"][0]["city"][0].empty? ? loc_city = e["location"][0]["city"][0] : loc_city = ""
              !e["location"][0]["state"][0].empty? ? loc_state = e["location"][0]["state"][0] : loc_state = ""
              !e["location"][0]["zip"][0].empty? ? loc_zip = e["location"][0]["zip"][0] : loc_zip = ""
              loc_zip.delete!("\n")
              !e["location"][0]["line_1"][0].empty? ? loc_line1 = e["location"][0]["line_1"][0] : loc_line1 = ""
              loc_line1.delete!("\n")
              loc_line1.delete!(",")
              !e["location"][0]["line_2"][0].empty? ? loc_line2 = e["location"][0]["line_2"][0] : loc_line2 = ""
              loc_line2.delete!("\n")
              loc_line2.delete!(",")
          else
              loc_name = ""
              loc_street = ""
              loc_city = ""
              loc_state = ""
              loc_zip = ""
              loc_line1 = ""
              loc_line2 = ""
          end

          if !e["registration"][0].empty?
            reg_limit = e["registration"][0]["limit"][0]
            reg_event_type = e["registration"][0]["event_type"][0]["content"]
            if !e["registration"][0]["forms"][0].empty?
              !e["registration"][0]["forms"][0]["registration_form"][0]["id"].empty? ? reg_forms_id = e["registration"][0]["forms"][0]["registration_form"][0]["id"] : reg_forms_id = ""
              if !e["registration"][0]["forms"][0]["registration_form"][0]["name"].empty? and !e["registration"][0]["forms"][0]["registration_form"][0]["name"].nil?
                reg_form_name = e["registration"][0]["forms"][0]["registration_form"][0]["name"][0]
              else
                reg_form_name = ""
              end
            else
              reg_forms_id = ""
              reg_form_name = ""
            end
          else
            reg_limit = ""
            reg_event_type = ""
            reg_forms_id = ""
            reg_form_name = ""
          end
          !e["guest_list"][0].empty? ? guest_list = e["guest_list"][0] : guest_list = ""
          resources = ""
          if !e["resources"][0].empty?
            e["resources"][0]["resource"].each do |r|
              resources = resources + " | " + r["name"][0]
            end
          end
          resources.delete!(",")
          setup_start = e["setup"][0]["start"][0]
          setup_end = e["setup"][0]["end"][0]
          !e["setup"][0]["notes"][0].empty? ? setup_notes = e["setup"][0]["notes"][0] : setup_notes = ""
          event_grouping = e["event_grouping"][0]["id"]
          creator = e["creator"][0]["content"]
          modifier = e["modifier"][0]["content"]
          listed = e["listed"][0]
          public_calendar_listed = e["public_calendar_listed"][0]
          !e["image"][0].empty? ? image = e["image"][0] : image = ""
          created = e["created"][0]
          modified = e["modified"][0]

          ccb_line =
          id + "," + name + "," + description + "," +
          leader_notes + "," +
          start_datetime + "," +
          end_date + "," +
          end_time + "," +
          timezone + "," +
          recurrence_description + "," +
          recurrence_description + "," +
          approval_status + "," +
          group + "," +
          organizer + "," +
          phone + "," +
          loc_name + "," +
          loc_street + "," +
          loc_city + "," +
          loc_state + "," +
          loc_zip + "," +
          loc_line1 + "," +
          loc_line2 + "," +
          reg_limit + "," +
          reg_event_type + "," +
          reg_forms_id + "," +
          reg_form_name + "," +
          guest_list + "," +
          resources + "," +
          setup_start + "," +
          setup_end + "," +
          setup_notes + "," +
          event_grouping + "," +
          creator + "," +
          modifier + "," +
          listed + "," +
          public_calendar_listed + "," +
          image + "," +
          created + "," +
          modified
          ccb_array << ccb_line
        end

    File.open(ccbfile, 'w') do |file|
    puts "******************************************************"
    puts "Outputting CCB export csv file..."
        ccb_array.each do |p|
          pp p
          file.write("#{p}\n")
          recordcount += 1
        end
    end

          puts "=============================="
          puts "Extraction Done"
          puts "Records written to csv: #{recordcount}"
