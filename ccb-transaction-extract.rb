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
username = 'community_ccb_user'
password = 'dGUQRWq19N8'
##############################
ccb_url = "https://cc.ccbchurch.com/api.php"
ccb_service = "transaction_detail_type_detail"
ccb_search_parm = "transaction_detail_type_id"
ccb_search_parm2 = "1"
ccb_array = []
ccb_array2 = []
datestamp = Time.now


ccbheader = ""
ccb_array << ccbheader

ccbfile = "output/ccbtransactions_#{datestamp.strftime("%y%m%d%H%M")}.csv"


  puts("Extraction Mode:")
  puts "******************************************************"
  puts("Beginning extraction process ....")
  # Extraction mode A - Z
        puts "Extracting transactions..."
        target_url = "#{ccb_url}" + "?srv=" + "#{ccb_service}" + "&" + "#{ccb_search_parm}" + "=" + "#{ccb_search_parm2}"
        get = Curl::Easy.new(target_url)
        get.http_auth_types = :basic
        get.username = username
        get.password = password
        get.perform
        hashdata = XmlSimple.xml_in get.body_str
        pp hashdata
        # person = hashdata["response"][0]["individuals"][0]["individual"]
        # person.each do |t|
        #
        # #ccb_array << ccb_line
        # end

      # File.open(pcofile, 'w') do |file|
      # puts "******************************************************"
      # puts "Outputting pcoimport csv file..."
      #     pco_array.each do |p|
      #       file.write("#{p}\n")
      #     end
