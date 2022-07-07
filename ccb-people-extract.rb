require 'rubygems'
require 'curl'
require 'curb'
require 'csv'
require 'xmlsimple'
require "openurl"
require "open-uri"
require 'fileutils'
require 'pp'

##############################
username = '<username>'
password = '<password>'
ccb_url = "<url>"
##############################
ccb_service = "individual_search"
ccb_search_parm = "last_name"
ccb_array = []
ccb_array2 = []
ccbheader = "fname,lname,mname,salutation,legal_fname,suffix,gender,martial_status,birthday,email,emails,allergy_string,noallergies,anniversary,baptized,family_id,family,family_position,emergency_contact,campus,campus_id,ccb_id,deceased,membership_type,membership_date,membership_end,receive_email_from_church,active,created_at,modified_at,mailing_street,mailing_city,mailing_state,mailing_zip,home_street,home_city,home_state,home_zip,work_street,work_city,work_state,work_zip,other_street,other_city,other_state,other_zip,contact_phone,home_phone,work_phone,mobile_phone,mobile_carrier,udf_text_1_label,udf_text_1_value,udf_text_2_label,udf_text_2_value,udf_text_3_label,udf_text_3_value,udf_text_4_label,udf_text_4_value,udf_text_5_label,udf_text_5_value,udf_text_6_label,udf_text_6_value,udf_text_7_label,udf_text_7_value,udf_text_8_label,udf_text_8_value,udf_text_9_label,udf_text_9_value,udf_text_10_label,udf_text_10_value,udf_text_11_label,udf_text_11_value,udf_text_12_label,udf_text_12_value,udf_text_13_label,udf_text_13_value,udf_text_14_label,udf_text_14_value,udf_text_15_label,udf_text_15_value,udf_text_16_label,udf_text_16_value,udf_text_17_label,udf_text_17_value,udf_text_18_label,udf_text_18_value,udf_text_19_label,udf_text_19_value,udf_text_20_label,udf_text_20_value,udf_date_1_label,udf_date_1_value,udf_date_2_label,udf_date_2_value,udf_date_3_label,udf_date_3_value,udf_date_4_label,udf_date_4_value,udf_date_5_label,udf_date_5_value,udf_date_6_label,udf_date_6_value,udf_pulldown_1_label,udf_pulldown_1_value,udf_pulldown_2_label,udf_pulldown_2_value,udf_pulldown_3_label,udf_pulldown_3_value,udf_pulldown_4_label,udf_pulldown_4_value,udf_pulldown_5_label,udf_pulldown_5_value,udf_pulldown_6_label,udf_pulldown_6_value,image,family_image"
ccb_array << ccbheader
pco_array = []
pco_array2 = []
pco_header =
"Name Prefix,remote_id,Given Name,First Name,Middle Name,Last Name,Name Suffix,Birthdate,Anniversary,Gender,Medical,Marital Status,Status,Membership,Home Address Street Line 1,Home Address City,Home Address State,Home Address Zip,Work Address Street Line 1,Work Address City,Work Address State,Work Address Zip,Other Address Street Line 1,Other Address City,Other Address State,Other Address Zip,Mobile Phone Number,Home Phone Number,Work Phone Number,Other Phone Number,Mobile Carrier,Home Email,Household ID,Household Primary Contact,Campus,pco_text_1_value,pco_text_2_label,pco_text_2_value,pco_text_3_label,pco_text_3_value,pco_text_4_label,pco_text_4_value,pco_text_5_label,pco_text_5_value,pco_text_6_label,pco_text_6_value,pco_text_7_label,pco_text_7_value,pco_text_8_label,pco_text_8_value,pco_text_9_label,pco_text_9_value,pco_text_10_label,pco_text_10_value,pco_text_11_label,pco_text_11_value,pco_text_12_label,pco_text_12_value,pco_text_13_label,pco_text_13_value,pco_text_14_label,pco_text_14_value,pco_text_15_label,pco_text_15_value,pco_text_16_label,pco_text_16_value,pco_text_17_label,pco_text_17_value,pco_text_18_label,pco_text_18_value,pco_text_19_label,pco_text_19_value,pco_date_1_label,pco_date_1_value,pco_date_2_label,pco_date_2_value,pco_date_3_label,pco_date_3_value,pco_date_4_label,pco_date_4_value,pco_date_5_label,pco_date_5_value,pco_date_6_label,pco_date_6_value,pco_pulldown_1_label,pco_pulldown_1_value,pco_pulldown_2_label,pco_pulldown_2_value,pco_pulldown_3_label,pco_pulldown_3_value,pco_pulldown_4_label,pco_pulldown_4_value,pco_pulldown_5_label,pco_pulldown_5_value,pco_pulldown_6_label,pco_pulldown_6_value"
pco_array << pco_header
mainfolder = "output"
imagefolder = "#{mainfolder}/ccbextract_images"
famimagefolder = "#{mainfolder}/ccbextract_family_images"
unless File.directory?(mainfolder)
  FileUtils.mkdir_p(mainfolder)
end
unless File.directory?(imagefolder)
  FileUtils.mkdir_p(imagefolder)
end
unless File.directory?(famimagefolder)
  FileUtils.mkdir_p(famimagefolder)
end
#Column numbers mapping
imagecol        = 95
familyimagecol  = 96
fnamecol        = 0
lnamecol        = 1
ccbidcol        = 21
famidcol        = 15
famnamecol      = 16
campus_array = []
campuscol       = 19
datestamp = Time.now.strftime("%Y%m%d_%H%M")
ccbfile = "#{mainfolder}/ccbextract_#{datestamp}.csv"
pcofile = "#{mainfolder}/pcoimport_#{datestamp}.csv"


if ARGV.count == 1 and ARGV.first == "test"
        puts("Test Mode:")
        # Initial test of connectivity and credentials
        ("A".."B").each do |letter|
              puts "Testing last names starting in #{letter}..."
              target_url = "#{ccb_url}" + "?srv=" + "#{ccb_service}" + "&" + "#{ccb_search_parm}" + "=" + "#{letter}"
              get = Curl::Easy.new(target_url)
              get.http_auth_types = :basic
              get.username = username
              get.password = password
              begin
                get.perform
              rescue Curl::Err::HostResolutionError => error
                puts "Test unsuccessful --> Error - #{error}. This is usually due to connectivity or DNS issues. Please correct and retry."
                break
              end
              hashdata = XmlSimple.xml_in get.body_str
              test = hashdata["response"][0]
              if !test["errors"].nil?
                puts "Test unsuccessful --> Error - #{test["errors"][0]["error"][0]["content"]}. Please correct and retry."
              elsif test["service"][0] == "individual_search"
                puts "Test successful -- correctly performed basic extract."
                break
              end
          end
else
  puts("Extraction Mode:")
  puts "******************************************************"
  puts("Beginning extraction process ....")
  # Extraction mode A - Z
  ("A".."Z").each do |letter|
        puts "Extracting last names starting in #{letter}..."
        target_url = "#{ccb_url}" + "?srv=" + "#{ccb_service}" + "&" + "#{ccb_search_parm}" + "=" + "#{letter}"
        get = Curl::Easy.new(target_url)
        get.http_auth_types = :basic
        get.username = username
        get.password = password
        get.perform
        hashdata = XmlSimple.xml_in get.body_str
        person = hashdata["response"][0]["individuals"][0]["individual"]
        person.each do |t|
          pp t

          @ccb_id = t["id"]
          @campus_id = t["campus"][0]["id"] #
          @campus = t["campus"][0]["content"] ##
          @family_id = t["family"][0]["id"]
          @family = t["family"][0]["content"]
          @family = @family.sub ',', ''
          @family_position = t["family_position"][0]
          @family_position = "Primary Contact" ? @household_primary_contact = "TRUE" : @household_primary_contact = ""
          family_image = t["family_image"][0] ##
          if ARGV.count == 1 and ARGV.first == "images" and !(family_image =~ /default(.*)/)
                  begin
                      targetfile =  famimagefolder + "/" + @fname + "_" + @lname + "_family_" + @family_id + ".jpg"
                      # targetfile = targetfile.str.downcase.tr(" ", "_")
                      targetfile = targetfile.gsub(/[ ]/ ,"_")
                      # puts targetfile
                      File.write targetfile, open(family_image).read
                      puts "Writing #{targetfile}..."
                  rescue Exception => error
                      puts "Error downloading family file -- skipping"
                      pp error
                  end
          end

          @fname =  t["first_name"][0]
          if @fname.class == Hash
            @fname = "X"
          end
          @fname = @fname.sub ',', ''
          # @fname = @fname.sub(/[!@#$%^&*()-=_+|;:",.<>?']/, '')
          @lname = t["last_name"][0]
          @lname = @lname.sub ',', ''
          # @lname = @lname.sub(/[!@#$%^&*()-=_+|;:",.<>?']/, '')
          # @lname = @lname.sub ',', ''
          # puts "#{@fname} #{@lname}"
          t["middle_name"][0].empty?        ? @mname         = "" : @mname          = t["middle_name"][0]
          t["legal_first_name"][0].empty?   ? @legal_fname   = "" : @legal_fname    = t["legal_first_name"][0]
          t["salutation"][0].empty?         ? @salutation    = "" :  @salutation    = t["salutation"][0]
          t["suffix"][0].empty?             ? @suffix        = "" :  @suffix        = t["suffix"][0]
          @image = t["image"][0] ##
          if ARGV.count == 1 and ARGV.first == "images" and !(@image =~ /default(.*)/)

              begin
                  targetfile =  imagefolder + "/" + @fname + "_" + @lname + "_" + @ccb_id + ".jpg"
                  # targetfile = targetfile.str.downcase.tr(" ", "_")
                  targetfile = targetfile.gsub(/[ ]/ ,"_")

                  # puts targetfile
                  File.write targetfile, open(@image).read
                  puts "Writing #{targetfile}..."
              rescue Exception => error
                  puts "Error downloading file -- skipping"
                  pp error
              end
          end

          @allergy_string = ""
          t["allergies"].each do |allergy|
            if allergy.empty?
              @allergy_string = ""
            else
              allergy = allergy.to_s.gsub(/[,]/ ,";")
              if @allergy_string == ""
                  @allergy_string = allergy
              else
                  @allergy_string = @allergy_string + ";" + allergy
              end
            end
          end
          # escape commas in allergy string
          @allergy_string = "\"" + @allergy_string + "\""
          @noallergies = t["confirmed_no_allergies"][0] ##
          t["emergency_contact_name"][0].empty?     ? @emergency_contact = "" : @emergency_contact = t["emergency_contact_name"][0]  ##
          t["anniversary"][0].empty?        ? @anniversary       = "" : @anniversary      = t["anniversary"][0]
          @baptized = t["baptized"][0]  #boolean
          t["deceased"][0].empty?           ? @deceased           = "" : @deceased          = t["deceased"][0]
          @membership_type = t["membership_type"][0]["content"]
          t["membership_date"][0].empty?    ? @membership_date   = "" : @membership_date  = t["membership_date"][0]
          t["membership_end"][0].empty?     ? @membership_end    = "" : @membership_end   = t["membership_end"][0]
          @receive_email_from_church = t["receive_email_from_church"][0]
          @active = t["active"][0] #boolean
          @created_at = t["created"][0]
          @modified_at = t["modified"][0]
          t["email"][0].empty?                 ? @email             = "" : @email           = t["email"][0]
          @emails = ""
          t["email"].each do |em|
            if em.empty?
              @emails = ""
            else
              if @emails == ""
                  @emails = em
              else
                  @emails = @emails + ";" + em
              end
            end
          end
           t["addresses"][0]["address"].each do |a|
               case a["type"]
                when "mailing"
                  a["street_address"][0].empty? ? @mailing_street = ""  : @mailing_street = a["street_address"][0].gsub(/[,]/ ,"")
                  @mailing_street.gsub!(/[\n]/ ," ")
                  @mailing_street.gsub!(/[\r]/ ," ")
                  a["city"][0].empty?           ? @mailing_city =  ""   : @mailing_city = a["city"][0]
                  a["state"][0].empty?          ? @mailing_state = ""   : @mailing_state = a["state"][0]
                  a["zip"][0].empty?            ? @mailing_zip = ""     : @mailing_zip = a["zip"][0]
                when "home"
                  a["street_address"][0].empty? ? @home_street = ""     : @home_street = a["street_address"][0].gsub(/[,]/ ," ")
                  @home_street.gsub!(/[\n]/ ," ")
                  @home_street.gsub!(/[\r]/ ," ")
                  a["city"][0].empty?           ? @home_city =  ""      : @home_city = a["city"][0]
                  a["state"][0].empty?          ? @home_state = ""      : @home_state = a["state"][0]
                  a["zip"][0].empty?            ? @home_zip = ""        : @home_zip = a["zip"][0]
                when "work"
                  a["street_address"][0].empty? ? @work_street = ""     : @work_street = a["street_address"][0].gsub(/[,]/ ," ")
                  @work_street.gsub!(/[\n]/ ," ")
                  @work_street.gsub!(/[\r]/ ," ")
                  a["city"][0].empty?           ? @work_city =  ""      : @work_city = a["city"][0]
                  a["state"][0].empty?          ? @work_state = ""      : @work_state = a["state"][0]
                  a["zip"][0].empty?            ? @work_zip = ""        : @work_zip = a["zip"][0]
                when "other"
                  a["street_address"][0].empty? ? @other_street = ""    : @other_street = a["street_address"][0].gsub(/[,]/ ," ")
                  @other_street.gsub!(/[\n]/ ," ")
                  @other_street.gsub!(/[\r]/ ," ")
                  a["city"][0].empty?           ? @other_city =  ""     : @other_city = a["city"][0]
                  a["state"][0].empty?          ? @other_state = ""     : @other_state = a["state"][0]
                  a["zip"][0].empty?            ? @other_zip = ""       : @other_zip = a["zip"][0]
                else
              end
           end
        t["phones"][0]["phone"].each do |p|
            case p["type"]
            when "contact"
                p["content"].nil? ? @contact_phone = ""     : @contact_phone = p["content"]
             when "home"
                p["content"].nil? ? @home_phone = ""        : @home_phone = p["content"]
             when "work"
                p["content"].nil? ? @work_phone = ""        : @work_phone = p["content"]
             when "mobile"
                p["content"].nil? ? @mobile_phone = ""      :  @mobile_phone = p["content"]
             when "emergency"
               p["content"].nil?  ? @emergency_phone = ""   : @emergency_phone = p["content"]
             else
           end
           t["mobile_carrier"][0]["content"].nil? ? @mobile_carrier = "" : @mobile_carrier = t["mobile_carrier"][0]["content"]
        end
          t["gender"][0].empty?    ? @gender   = "" : @gender  = t["gender"][0]
          t["marital_status"][0].empty?    ? @marital_status   = "" : @marital_status  = t["marital_status"][0]
          t["birthday"][0].empty?    ? @birthday   = "" : @birthday  = t["birthday"][0]

        #UDF Date Fields
        @udf_text_1_label,@udf_text_1_value,@udf_text_2_label,@udf_text_2_value,@udf_text_3_label,@udf_text_3_value,@udf_text_4_label,@udf_text_4_value,@udf_text_5_label,@udf_text_5_value,@udf_text_6_label,@udf_text_6_value,@udf_text_7_label,@udf_text_7_value,@udf_text_8_label,@udf_text_8_value,@udf_text_9_label,@udf_text_9_value,@udf_text_10_label,@udf_text_10_value,@udf_text_11_label,@udf_text_11_value,@udf_text_12_label,@udf_text_12_value,@udf_text_13_label,@udf_text_13_value,@udf_text_14_label,@udf_text_14_value,@udf_text_15_label,@udf_text_15_value,@udf_text_16_label,@udf_text_16_value,@udf_text_17_label,@udf_text_17_value,@udf_text_18_label,@udf_text_18_value,@udf_text_19_label,@udf_text_19_value,@udf_text_20_label,@udf_text_20_value = [""] * 40
            if !t["user_defined_text_fields"][0]["user_defined_text_field"].nil?
                t["user_defined_text_fields"][0]["user_defined_text_field"].each do |ctext|
                      case ctext["name"][0]
                          when "udf_text_1"
                            ctext["label"].nil?   ?   @udf_text_1_label = ""    : @udf_text_1_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_1_value = ""    : @udf_text_1_value = ctext["text"][0]
                          when "udf_text_2"
                            ctext["label"].nil?   ?   @udf_text_2_label = ""    : @udf_text_2_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_2_value = ""    : @udf_text_2_value = ctext["text"][0]
                          when "udf_text_3"
                            ctext["label"].nil?   ?   @udf_text_3_label = ""    : @udf_text_3_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_3_value = ""    : @udf_text_3_value = ctext["text"][0]
                          when "udf_text_4"
                            ctext["label"].nil?   ?   @udf_text_4_label = ""    : @udf_text_4_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_4_value = ""    : @udf_text_4_value = ctext["text"][0]
                          when "udf_text_5"
                            ctext["label"].nil?   ?   @udf_text_5_label = ""    : @udf_text_5_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_5_value = ""    : @udf_text_5_value = ctext["text"][0]
                          when "udf_text_6"
                            ctext["label"].nil?   ?   @udf_text_6_label = ""    : @udf_text_6_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_6_value = ""    : @udf_text_6_value = ctext["text"][0]
                          when "udf_text_7"
                            ctext["label"].nil?   ?   @udf_text_7_label = ""    : @udf_text_7_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_7_value = ""    : @udf_text_7_value = ctext["text"][0]
                          when "udf_text_8"
                            ctext["label"].nil?   ?   @udf_text_8_label = ""    : @udf_text_8_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_8_value = ""    : @udf_text_8_value = ctext["text"][0]
                          when "udf_text_9"
                            ctext["label"].nil?   ?   @udf_text_9_label = ""    : @udf_text_9_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_9_value = ""    : @udf_text_9_value = ctext["text"][0]
                          when "udf_text_10"
                            ctext["label"].nil?   ?   @udf_text_10_label = ""    : @udf_text_10_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_10_value = ""    : @udf_text_10_value = ctext["text"][0]
                          when "udf_text_11"
                            ctext["label"].nil?   ?   @udf_text_11_label = ""    : @udf_text_11_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_11_value = ""    : @udf_text_11_value = ctext["text"][0]
                          when "udf_text_12"
                            ctext["label"].nil?   ?   @udf_text_12_label = ""    : @udf_text_12_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_12_value = ""    : @udf_text_12_value = ctext["text"][0]
                          when "udf_text_13"
                            ctext["label"].nil?   ?   @udf_text_13_label = ""    : @udf_text_13_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_13_value = ""    : @udf_text_13_value = ctext["text"][0]
                          when "udf_text_14"
                            ctext["label"].nil?   ?   @udf_text_14_label = ""    : @udf_text_14_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_14_value = ""    : @udf_text_14_value = ctext["text"][0]
                          when "udf_text_15"
                            ctext["label"].nil?   ?   @udf_text_15_label = ""    : @udf_text_15_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_15_value = ""    : @udf_text_15_value = ctext["text"][0]
                          when "udf_text_16"
                            ctext["label"].nil?   ?   @udf_text_16_label = ""    : @udf_text_16_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_16_value = ""    : @udf_text_16_value = ctext["text"][0]
                          when "udf_text_17"
                            ctext["label"].nil?   ?   @udf_text_17_label = ""    : @udf_text_17_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_17_value = ""    : @udf_text_17_value = ctext["text"][0]
                          when "udf_text_18"
                            ctext["label"].nil?   ?   @udf_text_18_label = ""    : @udf_text_18_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_18_value = ""    : @udf_text_18_value = ctext["text"][0]
                          when "udf_text_19"
                            ctext["label"].nil?   ?   @udf_text_19_label = ""    : @udf_text_19_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_19_value = ""    : @udf_text_19_value = ctext["text"][0]
                          when "udf_text_20"
                            ctext["label"].nil?   ?   @udf_text_20_label = ""    : @udf_text_20_label = ctext["label"][0]
                            ctext["text"].nil?    ?   @udf_text_20_value = ""    : @udf_text_20_value = ctext["text"][0]
                          else
                      end
                end
          end
        #UDF Date Fields
        @udf_date_1_label,@udf_date_1_value,@udf_date_2_label,@udf_date_2_value,@udf_date_3_label,@udf_date_3_value,@udf_date_4_label,@udf_date_4_value,@udf_date_5_label,@udf_date_5_value,@udf_date_6_label,@udf_date_6_value = "","","","","","","","","","","",""
            if !t["user_defined_date_fields"][0]["user_defined_date_field"].nil?
                t["user_defined_date_fields"][0]["user_defined_date_field"].each do |cdate|
                      case cdate["name"][0]
                          when "udf_date_1"
                            cdate["label"].nil?   ?   @udf_date_1_label = ""    : @udf_date_1_label = cdate["label"][0]
                            cdate["date"].nil?    ?   @udf_date_1_value = ""    : @udf_date_1_value = cdate["date"][0]
                          when "udf_date_2"
                            cdate["label"].nil?   ?   @udf_date_2_label = ""    : @udf_date_2_label = cdate["label"][0]
                            cdate["date"].nil?    ?   @udf_date_2_value = ""    : @udf_date_2_value = cdate["date"][0]
                          when "udf_date_3"
                            cdate["label"].nil?   ?   @udf_date_3_label = ""    : @udf_date_3_label = cdate["label"][0]
                            cdate["date"].nil?    ?   @udf_date_3_value = ""    : @udf_date_3_value = cdate["date"][0]
                          when "udf_date_4"
                            cdate["label"].nil?   ?   @udf_date_4_label = ""    : @udf_date_4_label = cdate["label"][0]
                            cdate["date"].nil?    ?   @udf_date_4_value = ""    : @udf_date_4_value = cdate["date"][0]
                          when "udf_date_5"
                            cdate["label"].nil?   ?   @udf_date_5_label = ""    : @udf_date_5_label = cdate["label"][0]
                            cdate["date"].nil?    ?   @udf_date_5_value = ""    : @udf_date_5_value = cdate["date"][0]
                          when "udf_date_6"
                            cdate["label"].nil?   ?   @udf_date_6_label = ""    : @udf_date_6_label = cdate["label"][0]
                            cdate["date"].nil?    ?   @udf_date_6_value = ""    : @udf_date_6_value = cdate["date"][0]
                          else
                      end
                    end
              end
              #UDF Pulldown Fields
                @udf_pulldown_1_label,@udf_pulldown_1_value,@udf_pulldown_2_label,@udf_pulldown_2_value,@udf_pulldown_3_label,@udf_pulldown_3_value,@udf_pulldown_4_label,@udf_pulldown_4_value,@udf_pulldown_5_label,@udf_pulldown_5_value,@udf_pulldown_6_label,@udf_pulldown_6_value = "","","","","","","","","","","",""
                  if !t["user_defined_pulldown_fields"][0]["user_defined_pulldown_field"].nil?
                      t["user_defined_pulldown_fields"][0]["user_defined_pulldown_field"].each do |cpull|
                        case cpull["name"][0]
                            when "udf_pulldown_1"
                              cpull["label"].nil?   ?   @udf_pulldown_1_label = ""    : @udf_pulldown_1_label = cpull["label"][0]
                              cpull["selection"][0]["content"].nil?    ?   @udf_pulldown_1_value = ""    : @udf_pulldown_1_value = cpull["selection"][0]["content"]
                            when "udf_pulldown_2"
                              cpull["label"].nil?   ?   @udf_pulldown_2_label = ""    : @udf_pulldown_2_label = cpull["label"][0]
                              cpull["selection"][0]["content"].nil?    ?   @udf_pulldown_2_value = ""    : @udf_pulldown_2_value = cpull["selection"][0]["content"]
                            when "udf_pulldown_3"
                              cpull["label"].nil?   ?   @udf_pulldown_3_label = ""    : @udf_pulldown_3_label = cpull["label"][0]
                              cpull["selection"][0]["content"].nil?    ?   @udf_pulldown_3_value = ""    : @udf_pulldown_3_value = cpull["selection"][0]["content"]
                            when "udf_pulldown_4"
                              cpull["label"].nil?   ?   @udf_pulldown_4_label = ""    : @udf_pulldown_4_label = cpull["label"][0]
                              cpull["selection"][0]["content"].nil?    ?   @udf_pulldown_4_value = ""    : @udf_pulldown_4_value = cpull["selection"][0]["content"]
                            when "udf_pulldown_5"
                              cpull["label"].nil?   ?   @udf_pulldown_5_label = ""    : @udf_pulldown_5_label = cpull["label"][0]
                              cpull["selection"][0]["content"].nil?    ?   @udf_pulldown_5_value = ""    : @udf_pulldown_5_value = cpull["selection"][0]["content"]
                            when "udf_pulldown_6"
                              cpull["label"].nil?   ?   @udf_pulldown_6_label = ""    : @udf_pulldown_6_label = cpull["label"][0]
                              cpull["selection"][0]["content"].nil?    ?   @udf_pulldown_6_value = ""    : @udf_pulldown_6_value = cpull["selection"][0]["content"]
                            else
                        end
                      end
                    end
  ########### Create output CSV  #################

        ccb_line = @fname + "," +
                  @lname + "," +
                  @mname + "," +
                  @salutation + "," +
                  @legal_fname + "," +
                  @suffix + "," +
                  @gender + "," +
                  @marital_status + "," +
                  @birthday + "," +
                  @email + "," +
                  @emails + "," +
                  @allergy_string + "," +
                  @noallergies + "," +
                  @anniversary + "," +
                  @baptized + "," +
                  @family_id + "," +
                  @family + "," +
                  @family_position + "," +
                  @emergency_contact + "," +
                  @campus + "," +
                  @campus_id  + "," +
                  @ccb_id + "," +
                  @deceased + "," +
                  @membership_type + "," +
                  @membership_date + "," +
                  @membership_end + "," +
                  @receive_email_from_church + "," +
                  @active + "," +
                  @created_at + "," +
                  @modified_at + "," +
                  @mailing_street + "," +
                  @mailing_city + "," +
                  @mailing_state + "," +
                  @mailing_zip + "," +
                  @home_street + "," +
                  @home_city + "," +
                  @home_state + "," +
                  @home_zip + "," +
                  @work_street + "," +
                  @work_city + "," +
                  @work_state + "," +
                  @work_zip + "," +
                  @other_street + "," +
                  @other_city + "," +
                  @other_state + "," +
                  @other_zip + "," +
                  @contact_phone + "," +
                  @home_phone + "," +
                  @work_phone + "," +
                  @mobile_phone + "," +
                  @mobile_carrier + "," +
                  @udf_text_1_label + "," +
                  @udf_text_1_value + "," +
                  @udf_text_2_label + "," +
                  @udf_text_2_value + "," +
                  @udf_text_3_label + "," +
                  @udf_text_3_value + "," +
                  @udf_text_4_label + "," +
                  @udf_text_4_value + "," +
                  @udf_text_5_label + "," +
                  @udf_text_5_value + "," +
                  @udf_text_6_label + "," +
                  @udf_text_6_value + "," +
                  @udf_text_7_label + "," +
                  @udf_text_7_value + "," +
                  @udf_text_8_label + "," +
                  @udf_text_8_value + "," +
                  @udf_text_9_label + "," +
                  @udf_text_9_value + "," +
                  @udf_text_10_label + "," +
                  @udf_text_10_value + "," +
                  @udf_text_11_label + "," +
                  @udf_text_11_value + "," +
                  @udf_text_12_label + "," +
                  @udf_text_12_value + "," +
                  @udf_text_13_label + "," +
                  @udf_text_13_value + "," +
                  @udf_text_14_label + "," +
                  @udf_text_14_value + "," +
                  @udf_text_15_label + "," +
                  @udf_text_15_value + "," +
                  @udf_text_16_label + "," +
                  @udf_text_16_value + "," +
                  @udf_text_17_label + "," +
                  @udf_text_17_value + "," +
                  @udf_text_18_label + "," +
                  @udf_text_18_value + "," +
                  @udf_text_19_label + "," +
                  @udf_text_19_value + "," +
                  @udf_text_20_label + "," +
                  @udf_text_20_value + "," +
                  @udf_date_1_label + "," +
                  @udf_date_1_value + "," +
                  @udf_date_2_label + "," +
                  @udf_date_2_value + "," +
                  @udf_date_3_label + "," +
                  @udf_date_3_value + "," +
                  @udf_date_4_label + "," +
                  @udf_date_4_value + "," +
                  @udf_date_5_label + "," +
                  @udf_date_5_value + "," +
                  @udf_date_6_label + "," +
                  @udf_date_6_value + "," +
                  @udf_pulldown_1_label + "," +
                  @udf_pulldown_1_value + "," +
                  @udf_pulldown_2_label + "," +
                  @udf_pulldown_2_value + "," +
                  @udf_pulldown_3_label + "," +
                  @udf_pulldown_3_value + "," +
                  @udf_pulldown_4_label + "," +
                  @udf_pulldown_4_value + "," +
                  @udf_pulldown_5_label + "," +
                  @udf_pulldown_5_value + "," +
                  @udf_pulldown_6_label + "," +
                  @udf_pulldown_6_value + "," +
                  @image + "," +
                  family_image
       @active ? status = "Active" : status = "Inactive"
       case @gender
           when "M"
             pco_gender = "Male"
           when "F"
             pco_gender = "Female"
           else
             pco_gender = ""
       end
       @remote_id = @ccb_id
       pco_line =
                  @salutation + "," +
                  @remote_id + "," +
                  @legal_fname + "," +
                  @fname + "," +
                  @mname + "," +
                  @lname + "," +
                  @suffix + "," +
                  @birthday + "," +
                  @anniversary + "," +
                  pco_gender + "," +
                  @allergy_string  + "," +
                  @marital_status  + "," +
                  status  + "," +
                  @membership_type    + "," +
                  @mailing_street  + "," +
                  @mailing_city  + "," +
                  @mailing_state  + "," +
                  @mailing_zip  + "," +
                  @home_street  + "," +
                  @home_city  + "," +
                  @home_state  + "," +
                  @home_zip  + "," +
                  @work_street  + "," +
                  @work_city  + "," +
                  @work_state  + "," +
                  @work_zip  + "," +
                  @mobile_phone  + "," +
                  @home_phone  + "," +
                  @work_phone  + "," +
                  @mobile_phone  + "," +
                  @mobile_carrier  + "," +
                  @email  + "," +
                  @family_id  + "," +
                  @household_primary_contact + "," +
                  @campus  + "," +
                  @udf_text_1_label + "," +
                  @udf_text_1_value + "," +
                  @udf_text_2_label + "," +
                  @udf_text_2_value + "," +
                  @udf_text_3_label + "," +
                  @udf_text_3_value + "," +
                  @udf_text_4_label + "," +
                  @udf_text_4_value + "," +
                  @udf_text_5_label + "," +
                  @udf_text_5_value + "," +
                  @udf_text_6_label + "," +
                  @udf_text_6_value + "," +
                  @udf_text_7_label + "," +
                  @udf_text_7_value + "," +
                  @udf_text_8_label + "," +
                  @udf_text_8_value + "," +
                  @udf_text_9_label + "," +
                  @udf_text_9_value + "," +
                  @udf_text_10_label + "," +
                  @udf_text_10_value + "," +
                  @udf_text_11_label + "," +
                  @udf_text_11_value + "," +
                  @udf_text_12_label + "," +
                  @udf_text_12_value + "," +
                  @udf_text_13_label + "," +
                  @udf_text_13_value + "," +
                  @udf_text_14_label + "," +
                  @udf_text_14_value + "," +
                  @udf_text_15_label + "," +
                  @udf_text_15_value + "," +
                  @udf_text_16_label + "," +
                  @udf_text_16_value + "," +
                  @udf_text_17_label + "," +
                  @udf_text_17_value + "," +
                  @udf_text_18_label + "," +
                  @udf_text_18_value + "," +
                  @udf_text_19_label + "," +
                  @udf_text_19_value + "," +
                  @udf_text_20_label + "," +
                  @udf_text_20_value + "," +
                  @udf_date_1_label  + "," +
                  @udf_date_1_value  + "," +
                  @udf_date_2_label  + "," +
                  @udf_date_2_value  + "," +
                  @udf_date_3_label  + "," +
                  @udf_date_3_value  + "," +
                  @udf_date_4_label  + "," +
                  @udf_date_4_value  + "," +
                  @udf_date_5_label  + "," +
                  @udf_date_5_value  + "," +
                  @udf_date_6_label  + "," +
                  @udf_date_6_value  + "," +
                  @udf_pulldown_1_label  + "," +
                  @udf_pulldown_1_value  + "," +
                  @udf_pulldown_2_label  + "," +
                  @udf_pulldown_2_value  + "," +
                  @udf_pulldown_3_label  + "," +
                  @udf_pulldown_3_value  + "," +
                  @udf_pulldown_4_label  + "," +
                  @udf_pulldown_4_value  + "," +
                  @udf_pulldown_5_label  + "," +
                  @udf_pulldown_5_value  + "," +
                  @udf_pulldown_6_label  + "," +
                  @udf_pulldown_6_value

        ccb_array << ccb_line
        pco_array << pco_line
    end
  end
  puts "******************************************************"
  puts "Array Loading Complete... running dedup pass..."
  # run uniq pass to eliminate duplicates
  ccb_array2 = ccb_array.uniq
  puts "CCB Dedup found #{ccb_array.count - ccb_array2.count} duplicates.. removed from output csv file"
  pco_array2 = pco_array.uniq
  puts "PCO Dedup found #{pco_array.count - pco_array2.count} duplicates.. removed from output csv file"

  image_counter = 0
  family_image_counter = 0

  File.open(ccbfile, 'w') do |file|
  puts "Outputting ccbextract csv file ..."
      ccb_array2.each do |c|
        file.write("#{c}\n")
       end
      File.open(pcofile, 'w') do |file|
      puts "Outputting pcoimport csv file..."
          pco_array2.each do |p|
            file.write("#{p}\n")
          end
      campus_array = campus_array.uniq
  end
  puts "******************************************************"
  puts "DONE!"
  puts ""
  puts "Final record count: #{ccb_array2.count}"
end

    if !campus_array.empty?
        campus_count = campus_array.count
        puts "******************************************************"
        puts "Campus names extracted from CCB were:"
        i = 0
        campus_array.each do |campus|
          i += 1
          puts "Campus #{i}: #{campus[0]}"
        end
        puts ""
        puts "If you would like to modify these before PCO import, easiest method is to "
        puts "load the pcoimport csv into Excel or Google Sheets, and find/replace each "
        puts "campus name, then resave it as a csv, prior to importing into PCO"

        puts ""
        puts "All of the output from the script will be located in an /output subfolder"
        puts "within the folder you ran the script"

    done = FALSE
  end
end
