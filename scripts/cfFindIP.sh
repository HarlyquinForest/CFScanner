#!/bin/bash  -
#===============================================================================
#
#          FILE: cfFindIP.sh
#
#         USAGE: ./cfFindIP.sh [ThreadCount]
#
#   DESCRIPTION: Scan all 1.5 Mil CloudFlare IP addresses
#
#       OPTIONS: ---
#  REQUIREMENTS: ThreadCount (integer Number which defines the parallel processes count)
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Morteza Bashsiz (mb), morteza.bashsiz@gmail.com
#  ORGANIZATION: Linux
#       CREATED: 01/24/2023 07:36:57 PM
#      REVISION:  1 by Nomad
#===============================================================================
#               You are running the version that is forked from the original 
#               repository and edited by HarlyquinForest
# MODIFICATION: 03/02/2023 12:12:12 PM
#      OPTIONS: -i : load IPs from a file , -t : set number of threads , -s : only output successfuly responding ips , -f : set custom fronting , -r : scan only one IP/Subnet , -h : show help  
#         NOTE: ----
#         BUGS: ----
#       AUTHOR: Amin Yousefnejad (HarlyquinForest) , aminyousefnejad28@gmail.com
set -o nounset                                  # Treat unset variables as an error

skip_fail=0
threads=16
IpListPath='.'
fronting="fronting.sudoer.net"

now=$(date +"%Y%m%d-%H%M%S")
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
resultDir="$scriptDir/../result"
resultFile="$resultDir/$now-result.cf"
cloudFlareIpList=$(curl -s -XGET https://www.cloudflare.com/ips-v4)
IPList="$cloudFlareIpList"

#help and usage 
function showHelp {
  echo ""
  echo ""
  echo "░█▀▀░█▀▀░█▀▀░█▀▀░█▀█░█▀█░█▀█░█▀▀░█▀▄"
  echo "░█░░░█▀▀░▀▀█░█░░░█▀█░█░█░█░█░█▀▀░█▀▄"
  echo "░▀▀▀░▀░░░▀▀▀░▀▀▀░▀░▀░▀░▀░▀░▀░▀▀▀░▀░▀"
  echo " --- Cloudflare IP scanner tool ---"
  echo ""
  echo "Usage:  cfFindIP.sh [OPTION] ..."
  echo "Default IP list loads from https://www.cloudflare.com/ips-v4"
  echo ""
  echo "  -i    loads IP list from file"
  echo "  -t    number of concurrency (Default value is: 16)"
  echo "  -s    show successfuly responding ips "
  echo "  -f    set fronting domain name (Default value is: fronting.sudoer.net | Attention: If not set correctlly IPs wno't respond)"
  echo "  -r    scan just one IP/Subnet "
  echo "  -h    show this help message "
  echo ""
  echo "Examples:"
  echo "  cfFindIP.sh  -i ips.txt -t 16 -f host.name -s "
  echo ""
  echo "People shouldn't afraid from their government, they have to be afraid of people"
}
# Function fncCheckSubnet
# Check Subnet
function fncCheckSubnet {
	local ipList resultFile timeoutCommand domainFronting skip host
	ipList="$1"
	resultFile="$2"
  skip="$3"
  host="$4"
	# set proper command for linux
	if command -v timeout >/dev/null 2>&1; 
	then
	    timeoutCommand="timeout"
	else
		# set proper command for mac
		if command -v gtimeout >/dev/null 2>&1; 
		then
		    timeoutCommand="gtimeout"
		else
		    echo >&2 "I require 'timeout' command but it's not installed. Please install 'timeout' or an alternative command like 'gtimeout' and try again."
		    exit 1
		fi
	fi
	for ip in ${ipList}
		do
			if $timeoutCommand 1 bash -c "</dev/tcp/$ip/443" > /dev/null 2>&1;
			then
        domainFronting=$($timeoutCommand 2 curl -s -w "%{http_code}\n" --tlsv1.2 -servername $host -H "Host: $host" --resolve "$host":443:"$ip" https://"$host" -o /dev/null | grep '200')
				if [[ "$domainFronting" == "200" ]]
				then
					timeMil=$($timeoutCommand 2 curl -s -w "TIME: %{time_total}\n" --tlsv1.2 -servername scan.sudoer.net -H 'Host: scan.sudoer.net' --resolve scan.sudoer.net:443:"$ip" https://scan.sudoer.net | grep "TIME" | tail -n 1 | awk '{print $2}' | xargs -I {} echo "{} * 1000 /1" | bc )
					if [[ "$timeMil" ]] 
					then
						echo "OK $ip ResponseTime $timeMil" 
						echo "$timeMil $ip" >> "$resultFile"
					else
						if [[ "$skip" == "0" ]]; then echo FAILED "$ip"; fi
					fi
				else
					if [[ "$skip" == "0" ]]; then echo FAILED "$ip"; fi
				fi
			else
				if [[ "$skip" == "0" ]]; then echo FAILED "$ip"; fi
			fi
	done
}
# End of Function fncCheckSubnet
export -f fncCheckSubnet
#Function to Iterate through ip ranges
function fnIterateSubnet {
  for subNet in ${IPList}
  do
	  ipList=$(nmap -sL -n "$subNet" | awk '/Nmap scan report/{print $NF}')
	  parallel -j "$threads" fncCheckSubnet ::: "$ipList" ::: "$resultFile" ::: "$skip_fail" ::: "$fronting"
  done

}

# Check if 'parallel', 'nmap' and 'bc' packages are installed
# If they are not,exit the script

if [[ "$(uname)" == "Linux" ]]; then
    command -v parallel >/dev/null 2>&1 || { echo >&2 "I require 'parallel' but it's not installed. Please install it and try again."; exit 1; }
    command -v nmap >/dev/null 2>&1 || { echo >&2 "I require 'nmap' but it's not installed. Please install it and try again."; exit 1; }
    command -v bc >/dev/null 2>&1 || { echo >&2 "I require 'bc' but it's not installed. Please install it and try again."; exit 1; }
		command -v timeout >/dev/null 2>&1 || { echo >&2 "I require 'timeout' but it's not installed. Please install it and try again."; exit 1; }

elif [[ "$(uname)" == "Darwin" ]];then
    command -v parallel >/dev/null 2>&1 || { echo >&2 "I require 'parallel' but it's not installed. Please install it and try again."; exit 1; }
    command -v nmap >/dev/null 2>&1 || { echo >&2 "I require 'nmap' but it's not installed. Please install it and try again."; exit 1; }
    command -v bc >/dev/null 2>&1 || { echo >&2 "I require 'bc' but it's not installed. Please install it and try again."; exit 1; }
    command -v gtimeout >/dev/null 2>&1 || { echo >&2 "I require 'gtimeout' but it's not installed. Please install it and try again."; exit 1; }
fi


while getopts 'hsi:t:f:r:' opt; do
  case "$opt" in
    s)
       skip_fail=1 
      ;;
    i)
      arg="$OPTARG"
      IpListPath="$arg"
      if [[ -f "$IpListPath" ]]; then 
        IPList=`cat "$IpListPath"`
      fi
      ;;
    t)
      arg="$OPTARG"
      threads="$arg"
      ;;
    f)
      arg="$OPTARG"
      fronting="$arg"
      echo "Fronting domain set : $fronting"
      ;;
    r)
      arg="$OPTARG"
      IPList="$arg"
      ;;
    ?|h)
      showHelp
      exit 0
      ;;
  esac
done

#check if expected output folder exists and create if it's not availbe
if [ ! -d "$resultDir" ]; then
    mkdir -p "$resultDir"
fi

echo "" > "$resultFile"

fnIterateSubnet 

sort -n -k1 -t, "$resultFile" -o "$resultFile"
