# Sudoer Telegram Bot
This script scans all 1.5 Million cloudflare IP addresses and generate a result file contains the IPs which are work with CDN

Script now support custom ip list that can be controled by command line options and even single IP/Subnet range 
## Requirements
You have to install following packages
```
curl
nmap
parallel
```


## How to run
1. clone

```shell
[~]>$ git clone https://github.com/HarlyquinForest/CFScanner.git
```

2. Change direcotry

```shell
[~]>$ cd CFScanner/scripts
```
3. Execute it

You dont need to specify anything. There is some default values, but you can control them with command line options 

```shell
[~/CFScanner/scripts]>$ bash cfFindIP.sh  
```
Options can be find like this 
```text
░█▀▀░█▀▀░█▀▀░█▀▀░█▀█░█▀█░█▀█░█▀▀░█▀▄
░█░░░█▀▀░▀▀█░█░░░█▀█░█░█░█░█░█▀▀░█▀▄
░▀▀▀░▀░░░▀▀▀░▀▀▀░▀░▀░▀░▀░▀░▀░▀▀▀░▀░▀
 --- Cloudflare IP scanner tool ---

Usage:  cfFindIP.sh [OPTION] ...
Default IP list loads from https://www.cloudflare.com/ips-v4

  -i    loads IP list from file
  -t    number of concurrency (Default value is: 16)
  -s    show successfuly responding ips 
  -f    set fronting domain name (Default value is: fronting.sudoer.net | Attention: If not set correctlly IPs wno't respond)
  -r    scan just one IP/Subnet 
  -h    show this help message 

Examples:
  cfFindIP.sh  -i ips.txt -t 16 -f host.name -s 

People shouldn't afraid from their government, they have to be afraid of people
```
4. Result
It will generate a file by datetime in result direcotry

```shell
[~/CFScanner]>$ ls result/
20230120-203358-result.cf
[~/CFScanner]>$
```
