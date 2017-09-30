# CCBextract

The following scripts were created to simplify migration of data off of Community Church Building (CCB) to Planning Center Online (PCO People).

First a bit of history…When we migrated from CCB to PCO in the Fall of 2016, the process of extracting information out of CCB was [quite painful](http://www.bottomshelvz.com/2017/04/why-we-migrated-from-ccb-to-pco/), while the import process into PCO was simple and quick. Even though our migration is complete, I thought it might be of value to the PCO Community to write a script or two to simplify this CCB export process, and possibly do a little bit of prep for PCO import as well.

## Why Ruby Scripts?
The method to export the information out of CCB to could taken several different forms. I chose to use simple composite Ruby scripts for a couple of reasons:
1) A lot of the PCO community, and even some of the PCO team themselves, seem to like Ruby

2) Ruby is pretty much available on any platform and is simple to install. If you are on Mac OS (like a lot of the church community seems to be these days), then you already have Ruby natively installed and ready to go. If you are are Windows, its simple to install Ruby (links are below).

3) This was created as a downloadable script, rather than a web service or hosted app, mainly to eliminate risk to your data. The app requires a CCB API Key to be generated and used that will allow access to all of *your* data. If I had done this on a hosted platform, no matter how much we promised or precautions we took, there's always a perceived risk that somehow we might be keeping or not securing your API keys, putting your data in CCB at risk. Running this as a local script on your machine, where you never share the keys with us, mitigates this risk.

## Any other risks?
Running these scripts should be low risk, as we have ONLY used **read** api calls, which should never change or delete any information.

## Getting Ready
There are a few steps to complete to get ready to run the script(s)
1. **CCB API Info**
    1. Logon to CCB using an admin level account, click on the preferences gear in the upper right corner, and then click on API. If you cannot access this menu or the API option, your are likely not logging in with an admin account.

    2. Copy Your API URL, saving it for insertion into the script. This will be specific to your account, and needs to be set properly.

    3. Next, if you dont already have an API User created, click on Add a new API User on the right. Enter the name/username/password fields, using a service account username like ccb_api_user or similar.. the Org contact info boxes should be optional. Click Save to save this API user info, and save it with the API URL you captured in the step above.
2. **Checking / Installing Ruby**
    1. If you are running on Mac OS, simply open a terminal window — click on the Magnifying Glass on the task bar, type terminal, then return. You will be greeted with a plain old command line interface, which should be in your user folder (/users/<Your Username>). In the terminal window, type
```ruby -v```
then enter. You should get some info about the Ruby version installed, indicating things are working.
    2. If you are running on Windows, go to https://rubyinstaller.org/, download and install Ruby. Once installed you should be able to do the same test from within a Command window (cmd), verifying that Ruby is properly installed.
3. **Checking / Installing Ruby Gems**
    1. Your system likely has the basic set of Ruby gems installed, so we will need to add a few. Dont worry -- they are small and out of the way! You can check which Gems are installed, and check that the Gem package manager is running, by running the following command on a terminal window:

            gem list

    You should get a list of Gems already installed. If you get an error, you will want to check how to install the Gem package manager for Ruby (more details in the future)
    2. On some older MacOS versions, you may need to use xcode to align gem path locations. Run the following command in the
      terminal window:

            xcode-select --install

    When this is run, it will likely pop up a dialog box, letting you know progress of the install.
    2. To ensure that the proper Gems are installed, run the following command in a terminal window:

             gem install curl xml-simple openurl file-utils curb eat

    You should get  from feedback about the gems being installed, with a final message indicating that "X gems were installed", indicating success.

## ccb-people-extraction.rb
The first script that you're going to want to run is the CCB people extraction script (ccb-people-extraction.rb), which will extract all of the people data out of CCB and provide you with several outputs:
* A CCB Export CSV file, containing all available information that came out of CCB, generally unfiltered or untranslated.
* A PCO import CSV, which is much of the same data, but formatted to align with the prescribed headers for PCO import. This file should be (essentially) ready for PCO import, and most of the headers will be recognized by the PCO import tool, and automatically
* CCB supports images per person and per family and during the extraction each person record might have an image field (as a URL), so the script downloads of each of these files, if available, and places them in one of two image folders (person and family)

### How to use
1. **The first thing** you're going to want to do is some field mappings. CCB and PCO have some minor differences in certain field values, such as membership status, marital status, name suffixes, etc. For the most part, we've left these values alone. But, you will want to make sure that any of these values you are using in CCB is also in PCO. This is more true is your church has modified the CCB customizable field values.
    1. Log into CCB, Preferences (gear on the upper right), and select Customizable Fields
    2. Click on Member Type to get the list of Member Types available in CCB.
    3. Now log into PCO People, click on the People Tab, then preferences (gear on the upper right), and then click Customize Fields
    4. By default you should be on the Personal tab, and you should be Membership Status as one of the fields listed. If not, click on the other tabs to find Membership Status.
    5. Click on the Dropdown under Membership Status, and review the available values. If you need to add a value to match up to CCB values, click on the Pencil to the right of Membership Status to add or edit these values.
    6. You will want to review and update PCO for all of the following fields:
        1. Marital Status
        2. Name Prefix
        3. Name Suffix
    7. If your CCB instance was setup for multicampus, you will want to create a field in PCO to place this value to be imported. This can be anything you like. For example, we created a Tab called Campus, then a field called Campus to hold this info.  
2. **Download the script** (from Github) and open a terminal/command window in the same folder as the script. For example, if you downloaded the script into your Downloads folder, you will want to cd /users/<username>/Downloads.
3. **Edit the script**
   1. Open the script with a text editor of your choice
   2. Edit the username, password and ccb_url fields with the values you created and captured in the CCB API Info section above. *These values are strings, and will need to be double quoted*. For example:

        `ccb_url = "https://churchname.ccbchurch.com/api.php" `

   Save the file, and close the text editor
4. **Test the Script**
    1. Using the same command or terminal window, enter the following command  

        `ruby ccb-people-extract.rb test`   

        This will execute a simple test to ensure that the keys are accepted by CCB and connectivity is working correctly.
    2. If everything is working correctly, you should get a message indicating “Test successful”
5. **Now for the full extraction!**
    1. Again, with the same terminal window open, run the following command   

         `ruby ccb-people-extract.rb`   

    2. The script will take several minutes to complete the extraction, and begin to download the images, if any.
    3. Once complete, the script will give you a final count of the People record count it extracted, as well as the number of person and family images download. The script will also detect if campus names were in the extracted info, and make some recommendations for the import.
    4. The output of the script will be placed into an output subfolder in the folder you ran it:
        1. You will find  `ccbextract_<date>.csv` and `pcoimport_<date>.csv` files in the output subfolder. Both are date and time stamped, so if you run the script again, you will have the new and older copies of each.
        2. Person images downloaded will be in the `output/ccbextract_images` subfolder, and Family images will be in the `output/ccbextract_family_images` subfolder.

6. **Notes**
 - As of 9/27/17, CCB apparently changed something related to the image URLs that the script was extracting, making the script fail and images unable to be downloaded. I updated the script on 9/29/17 to accomodate this change, so please make sure that you a) reinstall the gems based on the new list above, or at least install the eat gem, and b) Download the newest version of the script from this site.


## ccb-batch-extraction.rb
The second script that you're going to want to run is the CCB batch extraction script (ccb-batch-extraction.rb), which will extract all of the batch, transaction and transaction detail data out of CCB and provide you with single CCB Export CSV file, containing all available transaction information that came out of CCB, generally unfiltered or untranslated.

### How to use
1. **Download the script** (from Github) and open a terminal/command window in the same folder as the script. For example, if you downloaded the script into your Downloads folder, you will want to cd /users/<username>/Downloads.
2. **Edit the script**
   1. Open the script with a text editor of your choice
   2. Edit the username, password and ccb_url fields with the values you created and captured in the CCB API Info section above. *These values are strings, and will need to be double quoted*. For example:

        `ccb_url = "https://churchname.ccbchurch.com/api.php" `

   3.   Save the file, and close the text editor

3. **Run the script!**
    1. Since you would have tested your API keys in the last script, we will assume that these are working, so need to retest. Just make sure the URL, key and password are the same as the people extraction script.
    2. With the terminal window open, run the following command   

         `ruby ccb-batch-extract.rb`   

    2. The script will take several minutes to complete the extraction, with seemingly nothing happening for a few minutes. This is due to the way to api pull from CCB is structured -- it literally does one call to get all batch records going back to 1/1/2007.
    3.  Once complete, the script will give you a final count of the Batch, Transaction and Transaction Details records it extracted.
    4. The output of the script will be placed into an output subfolder in the folder you ran it. Note that the CSV format is designed to be a normalized representation of the data -- the CCB database has different tables for batches, transactions and transaction details, so that every batch might have 1 or more transaction, and each transaction might have one or more transaction detail, meaning a split gift to more than one fund. The normalized output provides one row per batch/transaction/transaction detail.

## ccb-event-extraction.rb
The third script that you're going to want to run is the CCB event extraction script (ccb-event-extraction.rb), which will extract all of the event details from CCB and provide you with single CCB Export CSV file, containing all event data.

### How to use
1. **Download the script** (from Github) and open a terminal/command window in the same folder as the script. For example, if you downloaded the script into your Downloads folder, you will want to cd /users/<username>/Downloads.
2. **Edit the script**
   1. Open the script with a text editor of your choice
   2. Edit the username, password and ccb_url fields with the values you created and captured in the CCB API Info section above. *These values are strings, and will need to be double quoted*. For example:

        `ccb_url = "https://churchname.ccbchurch.com/api.php" `

   3.   Save the file, and close the text editor

3. **Run the script!**
    1. Since you would have tested your API keys in the first script, we will assume that these are working, so need to retest. Just make sure the URL, key and password are the same as the people extraction script.
    2. With the terminal window open, run the following command   

         `ruby ccb-event-extract.rb`   

    2. The script will take several minutes to complete the extraction, with seemingly nothing happening for a few minutes. This is due to the way to api pull from CCB is structured -- it literally does one call to get all event records going back to 1/1/2010.
    3.  Once complete, the script will give you a final count of the Event records it extracted.
    4. The output of the script will be placed into an output subfolder in the folder you ran it.

## Stub Scripts
Along with the 3 scripts above, I created the beginnings of several other scripts, which are really stubs so far -- they each access the relevant CCB API endpoint, and extract the data as one huge JSON text, but for each of these, I was not able to complete the more tedious work of parsing the array/hash values in order extract specific fields for export to a CSV. You are more than welcome to extend them in any way you want. Or, you can just run them and pipe the output to the file (to get it out of CCB), and create the process to parse it later.

These stub scripts are as follows:
- ccb-attendance-extract.rb     -->     Extracts CCB attendance records
- ccb-calendar-extract.rb       -->     Extracts CCB calendar records
- ccb-coa-extract.rb            -->     Extracts CCB chart of account records
- ccb-forms-extract.rb          -->     Extracts CCB forms records
- ccb-group-extract.rb          -->     Extracts CCB group records
- ccb-process-extract.rb        -->     Extracts CCB process records
- ccb-resource-extract.rb       -->     Extracts CCB resource records

***

Please let me know any issues you have running these — while not perfect, the goal was to make the exit process from CCB less painful than it was for us!
