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
ccb_service = "batch_profiles"
ccb_search_parm = "modified_since"
ccb_search_parm2 = "2007-01-01"
ccb_array = []
ccb_array2 = []
batchcount = 0
transcount = 0
tdcount = 0
datestamp = Time.now
mainfolder = "./output"
if !File.exists? mainfolder
   Dir.mkdir mainfolder
end

ccbheader = ""
ccb_array << ccbheader

ccbfile = "#{mainfolder}/ccbtransactions_#{datestamp.strftime("%y%m%d%H%M")}.csv"

  puts("==================================================================================================")
  puts("CCB Batch Extraction Script - intended to export batch/transaction/tranaction detail info from CCB")
  puts("==================================================================================================")
  puts("")
  puts("Extraction Mode:")
  puts "******************************************************"
        puts "Beginning to extracting transactions... (This may take several minutes)"
        target_url = "#{ccb_url}" + "?srv=" + "#{ccb_service}"
        get = Curl::Easy.new(target_url)
        get.http_auth_types = :basic
        get.username = username
        get.password = password
        get.perform
        hashdata = XmlSimple.xml_in get.body_str
         batches = hashdata["response"][0]["batches"][0]["batch"]
        #pp batches.count
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
                  trans_individual = t["individual"][0]["content"]
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
                      puts "Creating array entry - Batch: #{batch_id} Transaction: #{trans_id} TransactionDetail: #{td_id}"
                      ccb_array << batch_line
                  end
              end
            else
              transaction_id = "Nil Transactions"
            end
        end

      File.open(ccbfile, 'w') do |file|
      puts "******************************************************"
      puts "Outputting ccbbatch csv file..."
          ccb_array.each do |p|
            file.write("#{p}\n")
          end
      end
      puts "******************************************************"
      puts "DONE!"
      puts ""
      puts "Batch count: #{batchcount}"
      puts "Transaction count: #{transcount}"
      puts "Transaction Detail count: #{tdcount}"
