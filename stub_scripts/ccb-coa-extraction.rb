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
ccb_service = "transaction_detail_type_list"
ccb_search_parm = "modified_since"
ccb_search_parm2 = "2010-10-18"
ccb_array = []
ccb_array2 = []
datestamp = Time.now

ccbheader = ""
ccb_array << ccbheader

puts("==================================================================================================")
puts("CCB COA Extraction Script - intended to export chart of account detail info from CCB")
puts("==================================================================================================")
puts("")
puts("Extraction Mode:")
puts "******************************************************"
      puts "Beginning to extracting attendance... (This may take several minutes)"
        target_url = "#{ccb_url}" + "?srv=" + "#{ccb_service}"
        get = Curl::Easy.new(target_url)
        get.http_auth_types = :basic
        get.username = username
        get.password = password
        get.perform
        hashdata = XmlSimple.xml_in get.body_str
        pp hashdata
