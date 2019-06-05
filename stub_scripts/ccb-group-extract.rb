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
ccb_search_parm2 = "2010-08-01"
ccb_array = []
ccb_array2 = []
datestamp = Time.now
recordcount = 0

ccbheader = "id,name,description,leader_notes,start_datetime,end_date,end_time,timezone,recurrence_description,recurrence_description,approval_status,group,organizer,phone,loc_name,loc_street,loc_city,loc_state,loc_zip,loc_line1,loc_line2,reg_limit,reg_event_type,reg_forms_id,reg_form_name,guest_list,resources,setup_start,setup_end,setup_notes,event_grouping,creator,modifier,listed,public_calendar_listed,image,created,modified"
ccb_array << ccbheader

ccbfile = "output/ccbgroups_#{datestamp.strftime("%y%m%d%H%M")}.csv"


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
        pp hashdata
