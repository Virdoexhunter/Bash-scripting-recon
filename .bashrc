#add all this in your .bashrc file
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin


function subenum(){
	subfinder -d $1 -all | tee domains.$1.txt
	#cat domains.$1.txt | dnsgen - | massdns -r /root/wordlists/resolvers.txt -t A -o S -w massdns.txt
	assetfinder --subs-only $1 | tee -a domains.$1.txt
	amass enum -d $1  | tee -a $1.amass 
	#ctfr -d $1 | tee -a domains.$1.txt
	curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$1&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u | tee -a domains.$1.txt
	curl -sk "https://crt.sh/?q=%.$1&output=json" | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' | tee -a domains.$1.txt
	curl -s "https://riddler.io/search/exportcsv?q=pld:$1" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u | tee -a domains.$1.txt
	curl -s "https://www.virustotal.com/ui/domains/$1/subdomains?limit=40" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u | tee -a domains.$1.txt
	curl https://subbuster.cyberxplore.com/api/find?domain=$1 -s | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | tee -a domains.$1.txt
	#curl -s "https://certspotter.com/api/v1/issuances?domain=$1&include_subdomains=true&expand=dns_names" | jq .[].dns_names | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u  | tee -a domains.$1.txt
 	curl -s "https://jldc.me/anubis/subdomains/$1" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u | tee -a domains.$1.txt
	curl -s "https://securitytrails.com/list/apex_domain/$1" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep ".$1" | sort -u | tee -a domains.$1.txt
	curl --silent https://sonar.omnisint.io/subdomains/$1 | grep -oE "[a-zA-Z0-9._-]+\.$1" | sort -u | tee -a domains.$1.txt
	curl --silent -X POST https://synapsint.com/report.php -d "name=https%3A%2F%2F$1" | grep -oE "[a-zA-Z0-9._-]+\.$1" | sort -u | tee -a domains.$1.txt
  	curl -s "https://recon.dev/api/search?key=apikey&domain=$1" |jq -r '.[].rawDomains[]' | sed 's/ //g' | sort -u | tee -a domains.$1.txt
 	
	puredns bruteforce /root/wordlists/subs/altdns.txt $1 -r /root/wordlists/resolvers.txt | tee  resolved.txt
	cat  * | sort -u | uniq  | tee $1_uniq
	cat $1_uniq | dnsgen - | massdns -r /root/wordlists/resolvers.txt -t A -o S -w massdns.txt 
	gotator -sub $1_uniq -perm /root/wordlists/subs/perm.txt -depth 3 -mindup | uniq | tee $1_perm.txt
	cat  $1_perm.txt | massdns -r /root/wordlists/resolvers.txt -t A -o S -w permuteddomains.txt

}

function virtualhost()
{
	vhost --ip=$1 --host=$2 --wordlist=/home/ubuntu/virtual-host-discover/wordlist --output=$2.txt | grep $2 | cut -d " " -f2 | cut -d "/" -f 3 | grep -v __cf_bm | grep -v = | grep $2
}

function sublist()
{
	cat $1 | while read i; do subenum $i; done 
}

function alive()
{
	cat $1 | httpx --ports "80,443,3000,3001,3306,21,444,8080,8443,8888,8082,8888,9000,9001,9002" | tee $1.alive
	cat $1.alive | csp -c 20 | tee $1.csp
} 

function slacknotify(){
	nuclei -t /home/ubuntu/nuclei-templates -l $1 --severity low,medium,high,critical -c 100 -o $1.nuclei | notify -silent
}


function getdirs(){
	ffuf -w $1:URL -w /home/ubuntu/words.txt:WORD -u URL/WORD -t 100 -o  $1.dirs -H "Host: localhost"  -s  -mc 200,301,302,401,403
}

function tldenum(){
	tld  -n -d $1 -i /home/ubuntu/tld_scanner/topTLDs.txt -o $1.tld
	cat $1.tld | tr ':' '\n' | grep $1 | cut -d "/" -f 3 | cut -d '"' -f1 | tee $1.tld2
	rm $1.tld
	mv $1.tld2 $1.tld
	cat $1.tld | while read i; do subenum $i ;done 
}

function gitauto()
{
	gitgraber -k /home/ubuntu/tool/gitGraber/wordlists/keywords.txt -q $1 -s
}
