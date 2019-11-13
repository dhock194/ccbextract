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
ccb_service = "form_responses"
ccb_search_parm = "individual_id"
ccb_array = []
ccb_array2 = []
datestamp = Time.now
recordcount = 0
sleepval = 10
input_file = "./input/target_id.csv"
output_file = "./output/ccb-form-responses-#{datestamp.strftime("%y%m%d%H%M")}.csv"

# ccbfile = "output/ccbformresponse_#{datestamp.strftime("%y%m%d%H%M")}.csv"

puts("==================================================================================================")
puts("CCB Form Response Extraction Script - intended to export form detail info from CCB")
puts("==================================================================================================")
puts("")
puts("Extraction Mode:")
puts "******************************************************"

      puts "Beginning to extracting form responses... (This may take several minutes)"

File.open(output_file,"a+") do |plog|

    plog.puts "response_id,form_id,profile_id,created,modified,name,title,answer"
    rownum = 0.0
    CSV.foreach(input_file, headers: true,force_quotes: false) do |row|
                profile_id = row["ccb_id"]
                target_url = "#{ccb_url}" + "?srv=" + "#{ccb_service}" + "&" + "#{ccb_search_parm}" + "=" + "#{profile_id}"
                get = Curl::Easy.new(target_url)
                get.http_auth_types = :basic
                get.username = username
                get.password = password
                begin
                  get.perform
                  hashdata = XmlSimple.xml_in get.body_str
                rescue
                  if get.body_str.empty?
                      puts "==>API returned empty results... pausing #{sleepval} seconds and retrying..."
                      sleep(sleepval)
                      retry
                  else
                    pp get.body_str
                  end
                end

                  if hashdata.nil?
                    puts "Non breaking error.........."
                    pp hashdata
                  else
                    responses = hashdata["response"][0]["form_responses"][0]["form_response"]
                    if !responses.nil?
                        puts "Outputting form responses for #{profile_id}"
                        responses.each do |resp|
                          # puts "========="
                          id             = resp["id"]
                          form           = resp["form"][0]["id"]
                          profile_id     = resp["individual"][0]["id"]
                          name           = resp["individual"][0]["content"]
                          created        = resp["created"][0]
                          modified       = resp["modified"][0]

                          output_array = []
                          output_array_index = 0
                          resp["answers"].each do |ans|
                            if !ans.empty?
                              ans["title"].each do |a|

                                answer_value = ans["answer_value"][output_array_index]
                                if answer_value.class != Hash
                                  a = a.gsub(/[\s,]/ ," ")
                                  answer_value = answer_value.gsub(/[\s,]/ ," ")
                                  output_array << [a,answer_value]
                                  output_array_index += 1
                                end
                              end
                            # pp output_array
                            output_array.each do |arr|
                              title = arr[0]
                              answer = arr[1]
                              plog.puts "#{id},#{form},#{profile_id},#{created},#{modified},#{name},#{title},\"#{answer}\""
                            end
                          end
                          # ans["answer_value"].each do |av|
                          #   output_array << [a,""]
                          # end

                          # if !ans.empty?
                          #   title = ans["title"][1]
                          #   answer = ans["answer_value"][1]
                          #   # puts "#{ans["answer_value"][0]}, #{ans["answer_value"][1]}"
                          #   plog.puts "\"#{id}, #{form}, #{profile_id}, #{created}, #{modified}, #{name}, #{title}, #{answer}\""
                          # end
                        end
                        end
                    end
                end
    sleep(1)
    end
end
