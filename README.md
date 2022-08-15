# Bash-scripting-recon
Power of .bashrc and .bash_aliases
In last stream I have explained how to user .bashrc and .bash_aliases for easy and powerfull recon.

# Tools:

1. [Subfinder](https://github.com/projectdiscovery/subfinder)
2. [Assestfinder](https://github.com/tomnomnom/assetfinder)
3. [Domained](https://github.com/TypeError/domained)
4. [AltDns](https://github.com/infosec-au/altdns)
5. [CTFR](https://github.com/UnaPibaGeek/ctfr)
6. [CSP](https://github.com/EdOverflow/csp/)
7. [Wayback](http://web.archive.org/)
8. [Ffuf](https://github.com/ffuf/ffuf)
9. [Notify](https://github.com/projectdiscovery/notify)
10. [Nuclei](https://github.com/projectdiscovery/nuclei)
11. [Virtual-host-discovery](https://github.com/jobertabma/virtual-host-discovery)
12. [Httpx](https://github.com/projectdiscovery/httpx)
13. [Tld-Scanner](https://github.com/ozzi-/tld_scanner)
14. [GitGrabber](https://github.com/hisxo/gitGraber)

# USE:

Save both file .bashrc and .bash_aliases in your vps (linux based)

**when you have only single target**

```
subenum target.com
alive target.com_unique
slacknotify target.com_unqiue.alive
getdirs target.com_unique.alive
```

**when you have list of target**

```
sublist targetlist.txt
cat targetname* | sort -u | uniq | tee domains.txt
alive domains.txt
slacknotify domains.txt.alive
getdirs domains.txt.alive
```

**virtual host discovery**

```
vhost server-ip target.com
```

**Github recon**

```
gitauto target
```

**tld enumeration and subdomain enumeration**

```
tldenum target
```

# SUPPORT-ME:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/Virdoexhunter)



