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
ccb_service = "batch_profiles_in_date_range"
ccb_search_parm = "date_start"
ccb_search_parm3 = "date_end"

sleepval = 30
ccb_array = []
ccb_array2 = []
batchcount = 0
transcount = 0
tdcount = 0
datestamp = Time.now
mainfolder = "./output"
start_year = 2010
target_year = Date.today.strftime("%Y").to_i
target_month = Date.today.strftime("%m").to_i
target_date = "#{target_year}-#{target_month+1}-01"
# enddate = 1000
year = start_year
bdate = "#{start_year.to_s}-01-01"

if !File.exists? mainfolder
   Dir.mkdir mainfolder
end

ccbfile = "#{mainfolder}/ccbabbrev_#{datestamp.strftime("%y%m%d%H%M")}.csv"
File.open(ccbfile,"a") do |csv|


    ccbheader = "batch_id,batch_campus,batch_post_date,batch_begin_date,batch_end_date,batch_in_accounting,batch_status,batch_source,trans_id,trans_campus,trans_individual_id,trans_individual,trans_date,trans_payment_type,trans_check_number,trans_creator,trans_modifier,trans_created,trans_modified,td_id,td_coa,td_amount,td_tax_deductible,td_note,td_creator"
    csv.puts "\r" + "#{ccbheader}"

      puts("==================================================================================================")
      puts("CCB Batch Extraction Script - intended to export batch/transaction/tranaction detail info from CCB")
      puts("Script iterates per month from January of your starting year through current month/year")
      puts("==================================================================================================")
      puts("")
      puts "What year should we begin the CCB Batch extraction from (4 digit, e.g. 2013)?: "
      start_year = gets.strip.to_i
      if start_year >= 2005

          puts("#{start_year} selected - Extraction mode beginning:")
          puts "******************************************************"
          puts "Beginning to extracting transactions... (This may take several minutes)...."
          puts "******************************************************"


          daterange = (Date.new(start_year, 01)..Date.new(target_year, 12)).select {|d| d.day == 1}

          daterange.each do |fom|
                iyear     = fom.strftime("%Y")
                imonth    = fom.strftime("%m")
                iday      = fom.strftime("%d")
                bdate = "#{iyear}-#{imonth}-#{iday}"
                if imonth == "12"
                  edate = "#{((iyear.to_i)+1).to_s}-01-#{iday}"
                else
                  edate = "#{iyear}-#{'%02d' % ((imonth.to_i)+1).to_s}-#{iday}"
                end
                break if  (imonth == (target_month+1).to_s) && (iyear == target_year.to_s)
                        target_url = "#{ccb_url}" + "?srv=" + "#{ccb_service}" + "&" + "#{ccb_search_parm}" + "=" + "#{bdate}" + "&" + "#{ccb_search_parm3}" + "=" + "#{edate}"

                        #########
                        get = Curl::Easy.new(target_url)
                        get.http_auth_types = :basic
                        get.username = username
                        get.password = password
                        get.timeout=(10000)
                        begin
                          get.perform
                          hashdata = XmlSimple.xml_in get.body_str
                        rescue
                          puts "==>API returned empty results... pausing #{sleepval} seconds and retrying..."
                          sleep(sleepval)
                          retry if get.body_str.empty?
                        end

                        # hashdata = Nokogiri::XML(get.body_str)
                        puts "Processing #{bdate} through #{edate} ..."
                        batches = hashdata["response"][0]["batches"][0]["batch"]
                        if !batches.nil?
                            batches.each do |b|

                                batchcount += 1
                                batch_id = b["id"]
                                batch_campus = b["campus"][0]["content"]
                                batch_post_date = b["post_date"][0]
                                batch_begin_date = b["begin_date"][0]
                                batch_end_date = b["end_date"][0]
                                batch_in_accounting = b["in_accounting_package"][0]
                                batch_status = b["status"][0]
                                batch_source = b["source"][0]
                                if !b["transactions"][0].empty?
                                  transactions = b["transactions"][0]["transaction"]
                                  transactions.each do |t|
                                      transcount += 1
                                      trans_id = t["id"]
                                      trans_campus = t["campus"][0]["content"]
                                      trans_individual_id = t["individual"][0]["id"]
                                      trans_individual = t["individual"][0]["content"]
                                      trans_individual = trans_individual.sub ',', ''
                                      trans_date = t["date"][0]
                                      trans_payment_type = t["payment_type"][0]
                                      !t["check_number"][0].empty? ? trans_check_number = t["check_number"][0] : trans_check_number = ""
                                      trans_creator = t["creator"][0]["content"]
                                      trans_modifier = t["modifier"][0]["content"]
                                      trans_created = t["created"][0]
                                      trans_modified = t["modified"][0]
                                      trans_details = t["transaction_details"][0]["transaction_detail"]
                                      trans_details.each do |td|
                                          tdcount += 1
                                          td_id = td["id"]
                                          td_coa = td["coa"][0]["content"]
                                          td_amount = td["amount"][0]
                                          td_tax_deductible = td["tax_deductible"][0]
                                          !td["note"][0].empty? ? td_note = td["note"][0] : td_note = ""
                                          td_creator = td["creator"][0]["content"]

                                          ccbheader = "trans_id,trans_individual_id,trans_individual,td_id,individual_concat"
                                          individual_concat = "#{trans_individual_id}:#{trans_individual}"
                                          batch_line =  batch_id + "," +
                                                        batch_campus + "," +
                                                        batch_post_date + "," +
                                                        batch_begin_date + "," +
                                                        batch_end_date + "," +
                                                        batch_in_accounting + "," +
                                                        batch_status + "," +
                                                        batch_source + "," +
                                                        trans_id + "," +
                                                        trans_campus + "," +
                                                        trans_individual_id + "," +
                                                        trans_individual + "," +
                                                        trans_date + "," +
                                                        trans_payment_type + "," +
                                                        trans_check_number + "," +
                                                        trans_creator + "," +
                                                        trans_modifier + "," +
                                                        trans_created + "," +
                                                        trans_modified + "," +
                                                        td_id + "," +
                                                        td_coa + "," +
                                                        td_amount + "," +
                                                        td_tax_deductible + "," +
                                                        td_note + "," +
                                                        td_creator
                                          # puts "Creating array entry - Batch: #{batch_id} Transaction: #{trans_id} TransactionDetail: #{td_id}"
                                          csv.puts "\r" + "#{batch_line}"

                                      end
                                  end
                                else
                                  transaction_id = "Nil Transactions"
                                end
                            end
                        end
                    sleep(5)
                  end

      else
          puts("======================================================================")
          puts "Start year is out of range -- please select a 4 digit year since 2010"
      end
end


puts "******************************************************"
puts "DONE!"
puts ""
puts "Batch count: #{batchcount}"
puts "Transaction count: #{transcount}"
puts "Transaction Detail count: #{tdcount}"
