# ELK-klastri-juhend
Juhend Elasticsearchi, Logstashi, Kibana ja Winlogbeati ülesseadmiseks Debiani baasil
Vaja läheb vähemalt kolme Debiani (virtuaal)masinat, mis tuleks enne ära uuendada. Soovituslik on paigaldada ka SSH server.

1. Elasticsearchi installeerimine Debiani servermasinasse:
AMETLIK DOKUMENTATSIOON - https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html
	1.1 Elasticu public key importimine ja nende repositoorumi lisamine ning paigaldus:
		1) 'wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -'
		2) 'sudo apt-get install apt-transport-https'
		3) 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list'
		4) 'sudo apt-get update && sudo apt-get install elasticsearch'
	1.2 Elasticsearchi serviisi systemd's sisse lülitamine, et näiteks reboodi käigus automaatselt uuesti käivituks:
		1) 'sudo /bin/systemctl daemon-reload'
		2) 'sudo /bin/systemctl enable elasticsearch.service'
	1.3 Elasticu start/stop -
		1) 'sudo systemctl start elasticsearch.service'
		2) 'sudo systemctl stop elasticsearch.service'
	1.4 Debiani masinas Elasticsearchi pordi (9200) avamine:
		1) 'iptables -I INPUT -p tcp --dport 9200 --syn -j ACCEPT'
		2) 'service iptables save'
	1.5 Elasticsearchi konfigureerimine:
		1) 'sudo nano /etc/elasticsearch/elasticsearch.yml'
		2) Võiks konfiguratsioonifailis ära muuta:
			A. 'cluster.name' - näiteks 'cluster.name: maikool'
			B. 'node.name' - näiteks 'node.name: Elastic Master Node'
			C. 'network.host' - siia läheb Elasticu serveri ip või domeeninimi või eraldi 'etc/hosts' failis ära kirjeldatud nimi - näiteks 'network.host: elk-srv' või 'network.host: 10.16.44.65'
			!!NB!! KUI DEBIANIS KASUTADA DOMEENINIMESID, SIIS NATUKE ERINEVALT KUI WINDOWSIS - näiteks 'ELK-SRV.MAIKOOL.LOCAL' oleks 'ELK-SRV.LOCAL'
			D. 'discovery.seed_hosts' - siia läheb Elasticu Master node'i ip ehk praegusel juhul see sama node - näiteks 'discovery.seed_hosts: ["elk-srv"]'
			E. 'cluster.initial_master_nodes' - siia Elasticu Master node'ile eelenvalt määratud 'node.name'  - näiteks 'cluster.initial_master_nodes: ["Elastic Master Node"]'
		3) Peale confi muutmist restart Elasticule - 'sudo systemctl restart elasticsearch'
	1.6 Kontrollimine, kas Elasticule saab ligi:
		1) Enda Windows masinas veebibrauseri aadressiribale - 'ELASTICU_MASINA_IP:9200' ehk näiteks '10.16.44.65:9200'
		2) Vastuseks peaks kuvatama ~15 rida Elasticsearchi xml faili sisu - kui kuvab, siis kõik OK!
		
2. Winlogbeati installeerimine enda Windowsi masinale testimiseks - hiljem saab siis üle GPO paigaldada MSI kaudu:
AMETLIK DOKUMENTATSIOON - https://www.elastic.co/guide/en/beats/winlogbeat/current/winlogbeat-installation.html
	2.1 Winlogbeati tõmbamine ja paigaldus:
		1) Laadida alla vastav .zip fail (https://www.elastic.co/downloads/beats/winlogbeat) või siis MSI fail (aga MSI-ga paigaldab failid kahte erinevasse kausta)
		2) Alla laetud .zip fail lahti pakkida 'C:\Program Files' kausta.
		3) Lahti pakitud kaust ümber nimetada lihtsalt 'winlogbeat'-iks
		4) Powershelli käivitamine !administraatoriõigustes!
		5) Powershelli käsureal käivitada: ' & 'C:\Program Files\winlogbeat\install-service-winlogbeat.ps1' '
	2.2 Winlogbeati konfigureerimine:
	NB! Kui midagi on konfiguratsioonifailist puudu, siis see lihtsalt juurde lisada..
		1) Avada Notepad++'iga 'C:\Program Files\winlogbeat\' kaustas olev 'winlogbeat.yml' fail
		2) Konfiguratisoonifailis muuta:
			A. Välja kommenteerida 'output.elasticsearch' ja selle alt 'hosts'
			B. Eemaldada kommentaarimärk 'output.logstash:' eest ja selle alt 'hosts' eest
			C. 'output.logstash' alla 'hosts' reale läheb Elasticu masina domeeninimi koos Logstashi Beats sisendi vaikimisi pordiga (5044) - näiteks 'hosts: ["elk-srv.maikool.local:5044"]'
	2.3 Winlogbeati index template'i laadimine Elasticusse:
		1) Powershelli käsureal käivitada:
			A. 'cd 'C:\Program Files\winlogbeat' '
			B. ' .\winlogbeat.exe setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["elk-srv.maikool.local:9200"]' '
	2.4 Winlogbeati start/stop:
		1) Powershelli käsureal:
			A. 'cd 'C:\Program Files\winlogbeat' '
			B. 'Start-Service winlogbeat'
			C. 'Stop-Service winlogbeat'
		
3. Kibana installeerimine *teise* Debiani servermasinasse:
AMETLIK DOKUMENTATSIOON - https://www.elastic.co/guide/en/kibana/current/deb.html
	3.1 Elasticu public key importimine ja nende repositoorumi lisamine ning paigaldus:
		1) 'wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -'
		2) 'sudo apt-get install apt-transport-https'
		3) 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list'
		4) 'sudo apt-get update && sudo apt-get install kibana'
	3.2 Kibana serviisi systemd's sisse lülitamine:
		1) 'sudo /bin/systemctl daemon-reload'
		2) 'sudo /bin/systemctl enable kibana.service'
	3.3 Kibana start/stop:
		1) 'sudo systemctl start kibana.service'
		2) 'sudo systemctl stop kibana.service'
	3.4 Kibana konfigureerimine:
		1) 'sudo nano /etc/kibana/kibana.yml'
		2) Konfiguratisoonifailis ära muuta:
			A. 'server.host' - siia läheb Kibana serveri ip või domeeninimi või eraldi hosts failis ära kirjeldatud nimi - näiteks 'server.host: "kibana-srv"' või 'server.host: "10.16.44.67"'
			B. 'elasticsearch.hosts' - siia Elasticu masina URL koos pordiga - näiteks 'elasticsearch.hosts: ["http://elk-srv:9200"]'
		3) Peale confi muutmist Kibanale restart - 'sudo systemtl restart kibana'
	3.5 Kontrollimine, kas Kibanale saab ligi:
		1) Enda Windows masinas veebibrauseri aadressiribale - 'KIBANA_MASINA_IP:5601' ehk näiteks '10.16.44.67:5601'
		2) Avanema peaks Kibana graafiline interface - kui avaneb, siis kõik OK!

4. Logstashi installeerimine *samasse* Debiani servermasinasse
AMETLIK DOKUMENTATSIOON - https://www.elastic.co/guide/en/logstash/current/installing-logstash.html -
NB! VAJALIK ENNE PAIGADLADA Java 8 VÕI Java 11.
	4.1 Logstashi paigaldus:
		1) 'sudo apt-get install logstash'
	4.2 Logstashi serviisi sisse lülitamine:
		1) 'sudo /bin/systemctl daemon-reload'
		2) 'sudo /bin/systemctl enable logstash.service'
	4.3 Logstashi start/stop:
		1) 'sudo systemctl start logstash.service'
		2) 'sudo systemctl stop logstash.service'
	4.4 Logstashi konfigureerimine, et vastu võtta Winlogbeati poolt saadetud andmeid ja need edasi saata Elasticsearchi:
		1) 'sudo nano /etc/logstash/conf.d/logstash.conf'
		2) Beatside input pordilt 5044:
		
			' input {
				beats {
					port => 5044
					type => "wineventlog"

				}
			} '
			
		3) Fingerprint filter, et vältida juhuslikult tekkivaid duplikaatkirjeid:
		
			 ' filter {
				fingerprint {
					source => "message"
					target => "[@metadata][fingerprint]"
					method => "MURMUR3"

				}
			} '
			
		4) Mutate filter, et eemaldada ülearune info Winlogbeat'i "tags" väljalt:
			
			' filter {
				if "beats_input_codec_plain_applied" in [tags] {
					mutate {
						remove_tag => ["beats_input_codec_plain_applied"]
					}
				}
			} '
			
		5) Output ehk Elasticusse saatmine - 
		    A. 'hosts' on komaga eraldatud Elasticu URL-id ehk praegu üks ainuke URL;
			B. 'manage_template' lülitame välja, et vältida olukorda, kus templiiti automaatselt muudetakse;
			C. 'index' määrab ära indexi nime, kuhu andmed salvestatakse - sisuliselt andmebaas (hetkel loome kuupäevalise ehk iga päev tekib uus);
			D. 'document_id' saab ära määrata dokumendile kindla ID, mida meie populiseerime eelnevalt rakendatud Fingerprint filtriga:
			
			' output {
				 if [type] == "wineventlog" {
					elasticsearch {
					   hosts => ["http://elk-srv:9200"] # <- SIIA SULGUDESSE ENDA ELASTICSEARCHI NODE'i URL! 
					   manage_template => false
					   index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
					   document_id => "%{[@metadata][fingerprint]}"

					 }
				}
			} '
			
	4.5 Logstashi restart, et rakendada muudetud konfiguratsioon:
		1) 'sudo systemctl restart logstash'
		
5. Kibanast Winlogbeati andmete otsimine - Kui nüüd kõik 4 paigaldatud rakendust jooksevad, siis saab Kibanast uurida, kas mõned Winlogbeati kirjed on sinna tekkinud:
	5.1 Kõigepealt peab looma Kibana Index Pattern'i, mis otsib mingi kindla nimega indexi seest andmeid:
		1) Kibanas vasakult ribalt avada "Management"
		2) Edasi "Kibana" alt avada "Index Patterns"
		3) "Create Index Pattern"
		4) Sisestada otsingusse otsitava indexi nimi (kasutame !WILDCARDI!) - ' winlogbeat-* '
		5) Kibana peaks leidma hetkese kuupäevaga indexi (*kui ei leia, siis võiks oodata veel mõne minuti*) ja laseb jätkata - "Next Step"
		6) "Time Filter field name"-ks valida "@timestamp"
		7) "Create Index Pattern"
		8) Nüüd peaks Index Pattern olema loodud
	5.2 Kontrollimine, kas näeme Winlogbeati andmeid:
		1) Kibana vasakult ribalt avada "Discover"
		2) Vasakult peaks Index Pattern'iks valima loodud "winlogbeat-*"-i, kui see juba vaikimisi valitud pole
		3) Ülevalt paremalt saab muuta otsitavat ajavahemikku
		4) Kui Kibana saab andmed kätte, siis peaks kuvatud olema mõned tulpdiagrammid ja nende all ajaliselt reastatud Winlogbeati dokumendid
		
6. Winlogbeati paigaldamine üle GPO:
	6.1 Alla laadida Winlogbeati MSI fail ning paigaldada see üle GPO:
		1) GPO edukat rakendumist saab enda Windows masinas koheselt kontrollida Powershelli käsuga 'gpupdate /force /sync'
		2) Peale arvuti taaskäivitumist saab Winlogbeati töötamist kontrollida Powershelli käsuga 'Get-Service winlogbeat'
	6.2 Winlogbeati konfigureerimine skriptiga:
		1) Laadida siit repositooriumist alla 'winlogBeatYMLScript.ps1'
		2) Asendada skriptis 45. real '$replaceLogstashHost' muutuja väärtus enda Elasticsearchi masina domeeninimega
		3) Käivitada see skript domeenikontrolleris administraatorina peale MSI paigaldust
		4) Võibolla peab üle GPO muutma ka masinate RDP reegleid, et saaks läbi skripti masinas Powershelli sessiooni algatada..
		5) Peale skripti edukat käivitamist peaks Kibanasse hakkama laekuma Winlogbeati dokumente kõikidelt domeeni masinatelt
		
7. Elasticsearchi poolt kasutatava mälu suurendamine:
	- Et parandada Elasticu node'i jõudlust, on mõistlik tema kasutatava mälu maht lukustada, et vältida selle mälu juhuslikku paigutust saalealasse (memory swapping)
	- Elasticu enda dokumentatsioon soovitab Elasticsearchile anda maksimaalselt 50% kogu süsteemi vabast mälust (https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html)
	- Kogemus näitab, et Data Node'id kasutavad kõige rohkem mälu ja Master Node suhteliselt vähe (4GB lausa piisab) - hetkel on meil üks node, mis on vaikimisi nii Master Node kui ka Data Node korraga
	7.1 Erinevate konfiguratsioonifailide muutmine, et mälu lukustada:
		- Oletame näite jaoks, et soovitame Elasticsearchile anda 8GB mälu
		1) 'sudo nano /etc/default/elasticsearch' -> muuta ' ES_JAVA_OPTS="-Xms8g -Xmx8g" ' ja ' MAX_LOCKED_MEMORY=unlimited '
		2) 'sudo nano /etc/security/limits.conf' ->  faili lõppu juurde lisada ' elasticsearch soft memlock unlimited ' ja ' elasticsearch hard memlock unlimited '
		3) 'sudo nano /usr/lib/systemd/system/elasticsearch.service' -> lisada kuskile juurde ' LimitMEMLOCK=infinity '
		4) Kuna eelmine fail oli systemd fail, siis muudatuse rakendamiseks 'sudo systemctl daemon-reload'
		5) 'sudo nano /etc/elasticsearch/elasticsearch.yml' -> muuta ' bootstrap.memory_lock: true '
		6) 'sudo nano /etc/elasticsearch/jvm.options' -> muuta ' -Xms8g ' ja ' -Xmx8g '
	7.2 Elasticsearchi restart:
		1) 'sudo systemctl restart elasticsearch' ja kontrollime kas läheb ilusti käima -> 'sudo service elasticsearch status'
		2) Kui taaskäivitub edukalt, siis kõik OK!, kui ei, siis ilmselt kirjaviga mõnes muudetud konfiguratsioonifailis
		
8. Teise Elasticsearchi node'i lisamine:
	- Kuna üks node jääb suurema koormuse puhul võimekuselt väikseks, siis oleks mõistlik klastrisse veel juurde lisada vähemalt üks node
	- Uus node peaks olema eraldi uue masina peal ehk siis peaks läbi tegema kõik sammud, mis esimese Elasticu node'i puhulgi
AMETLIK DOKUMENTATSIOON - https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html
	8.1 Elasticu public key importimine ja nende repositoorumi lisamine ning paigaldus:
		1) 'wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -'
		2) 'sudo apt-get install apt-transport-https'
		3) 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list'
		4) 'sudo apt-get update && sudo apt-get install elasticsearch'
	8.2 Elasticsearchi serviisi systemd's sisse lülitamine, et näiteks reboodi käigus automaatselt uuesti käivituks:
		1) 'sudo /bin/systemctl daemon-reload'
		2) 'sudo /bin/systemctl enable elasticsearch.service'
	8.3 Elasticu start/stop -
		1) 'sudo systemctl start elasticsearch.service'
		2) 'sudo systemctl stop elasticsearch.service'
	8.4 Debiani masinas Elasticsearchi pordi avamine - kuna esimene masin jookseb juba pordil 9200, siis peame valima uue pordi (näiteks 9201):
		1) 'iptables -I INPUT -p tcp --dport 9201 --syn -j ACCEPT'
		2) 'service iptables save'
	8.5 Elasticsearchi konfigureerimine:
		1) 'sudo nano /etc/elasticsearch/elasticsearch.yml'
		2) Konfiguratsioonifailis ära muuta:
			A. 'cluster.name' - sama, mis sai esimesel masinal - näiteks 'cluster.name: maikool'
			B. 'node.name' - näiteks 'node.name: Elastic Node 2'
			C. 'network.host' - siia läheb Elasticu serveri ip või domeeninimi või eraldi 'etc/hosts' failis ära kirjeldatud nimi - näiteks 'network.host: elk-node2' või 'network.host: 10.16.44.68'
			!!NB!! KUI DEBIANIS KASUTADA DOMEENINIMESID, SIIS NATUKE ERINEVALT KUI WINDOWSIS - näiteks 'ELK-NODE2.MAIKOOL.LOCAL' oleks 'ELK-NODE2.LOCAL'
			D.	'http.port' - siia uus määratud port - näiteks 'http.port: 9201' 
			E. 'discovery.seed_hosts' - siia läheb Elasticu Master node'i IP ehk esimese masina IP - näiteks 'discovery.seed_hosts: ["elk-srv"]' (https://www.elastic.co/guide/en/elasticsearch/reference/current/discovery-settings.html)
			F. 'cluster.initial_master_nodes' - siia läheb esimesele masinale ehk Elasticu Master node'ile määratud 'node.name'  - näiteks 'cluster.initial_master_nodes: ["Elastic Master Node"]' (https://www.elastic.co/guide/en/elasticsearch/reference/current/discovery-settings.html)
			G. Kui on soovi, siis saab sellest node'ist teha ka eraldi Data Node'i (hetkel on ta korraga Master ja Data nagu esimenegi) - selleks lisada faili lõppu:
				'node.master:false'
				'node.data:true'
				'node.ingest:false'
		3) Restart Elasticule - 'sudo systemctl restart elasticsearch' ja kontroll, kas tuleb edukalt üles -> 'sudo service elasticsearch status'
	8.6 Kibana konfiguratsioonis uue Elasticu node'i lisamine:
		1) Kibana masinas 'sudo nano /etc/kibana/kibana.yml'
		2) 'elasticsearch.hosts' - lisada juurde uue node'i URL ehk kokku oleks komaga eraldatud nüüd kaks URL-i - näiteks 'elasticsearch.hosts: ["http://elk-srv:9200", "http://elk-node2:9201"]'
		3) Restart Kibanale - 'sudo systemctl restart kibana'
	8.7 Logstashi konfiguratsioonis uue Elasticsearchi URL-i lisamine output'i alla:
		1) Masinas, kus asub Logstash - 'sudo nano /etc/logstash/conf.d/logstash.conf'
		2) 'output'-i all lisada 'hosts' väljale juurde komaga eraldatult uue node'i URL - näiteks ' hosts => ["http://elk-srv:9200","http://elk-node2:9201"] '
		3) Restart Logstashile - 'sudo systemctl restart logstash' ja kontroll, kas saab mõlema masinaga ühendust -> 'sudo service logstash status'
	8.8 Uue Elasticu node'i mälu lukustamine - ehk seitsmenda punkti sammude kordamine ka uuel masinal

9. Syslogide saatmine Elasticsearchi koos geoip väljaga:
	- Uurime, kuidas Logstashiga vastu võtta mõne võrguseadme või servermasina sysloge ning rakendada andmetes leiduvate IP-de puhul geoip filterit
	9.1 Masinas, kus on paigaldatud Logstash - 'sudo nano /etc/logstash/conf.d/logstash.conf'
	9.2 Logstashil on olemas ka eraldi 'syslog input plugin' aga kogemuse põhjal võib öelda, et tõhusam on kasutada 'udp input plugin'-at:
		A. 'input' ahela sisse lisada:
		
		 ' udp {
			port => 5000 #port võib ka muu olla..
			type => "syslog"

		} '
		
		B. Peale varem lisatud fingerprint filteri ahelat lisada uus filteri ahel (grok filter, mis lisab paar uut välja sõnumi sisu põhjal) :
		
			' filter {
				  if [type] == "syslog" {
				   grok {
					match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:sysloghostname} %{DATA:syslog_program}(?:\{POSTINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
					add_field => [ "received_at", "%{@timestamp}" ]
					add_field => [ "received_from", "%{host}" ]
					}
				}
			} '
		
		C. Lisame veel ühe filteri ahela (date filter, et kätte saada kuupäev õigel kujul) :
			
			'  filter {
				  if [type] == "syslog" {
				   date {
					match => [ "syslog_timestamp", "MMM dd yyyy HH:mm:ss", "MMM d yyyy HH:mm:ss", "ISO8601" ]
					}
				}
			} '
			
		D. Järjekordne filter ahel (kv filter, sõnumist välja noppida ka 'SourceIP' ja 'DestinationIP' väljad - kui need eksisteerivad mõne muu nimega, siis peaks syslogide sisu uurima ja tegema siin filtris vastavad muudatused) :
			
			'  filter {
				  if [type] == "syslog" and [host] == "10.16.44.1"  { #antud IP on ruuteri oma ning sellega otsin vajalikke välju ainult ruuteri poolt saadetud syslogidelt (sysloge tuleb sisse mitmelt seadmelt)
				   kv {
					include_keys => [ "DestinationIP", "SourceIP", " source-ip", " destination-ip", "SourcePort", "DestinationPort", " source-port", " destination-port" ]
					field_split => ","
				  }
				}
			} '
		
		E. Kuna 'SourceIP' ja 'DestinationIP' välja esineb antud syslogides kahel erineval kujul, siis rakendan 'mutate' filtri, et need väljad ümber nimetada :
			
			'  filter {
				  if [type] == "syslog" {
				   mutate {
					rename => { " source-ip" => "SourceIP" }
					rename => { " destination-ip" => "DestinationIP" }
				  }
				}
			} '
		
		D. Nüüd lisame veel kaks filter ahelat, et geoip kätte saada nii 'SourceIP' kui ka 'DestinationIP' väljalt :
			
			'  filter {
				  if [type] == "syslog" and [host] == "10.16.44.1" {
				   geoip {
					source => "SourceIP"
					target => "geoip"
				  }
				}
			} '


			'	filter {
				  if [type] == "syslog" and [host] == "10.16.44.1" {
				   geoip {
					source => "DestinationIP"
					target => "geodestination"
				  }
				}
			} '
			
		E. Veel üks filter ahel, et nüüd puhastada 'tags' välja juhul kui 'grok' filter täisulatuses rakenduda ei saa :
			
			' filter {
				  if "_grokparsefailure" in [tags] {
					mutate {
					  remove_tag => ["_grokparsefailure"]
					}
				}
			} '
			
		F. Seejärel saab 'output' ahelasse peale winlogbeati lisada uue väljundi :
			
			'  else if [type] == "syslog" {
				  elasticsearch {
						hosts => ["http://elk-srv:9200","http://elk-node2:9201"]
						manage_template => false
						index => ["syslog-%{+YYYY.MM.dd}"]
						document_id => "%{[@metadata][fingerprint]}"

				}
			} '
		
		G. Nüüd, enne kui Logstashile restart teha ja Syslogid saatma panna, peaks geoip jaoks Kibanas ära kirjeldama templiidi.
	9.3 Kibanas 'Template Mapping'-u lisamine :
		1) Avada Kibanas "Management" -> "Index Management" -> "Index Templates"
		2) Paremalt valida "Create a Template"
		3) Templiidi sätted - Logistics :
			A. 'Name' - geoip
			B. Index patterns - syslog-*
			C. Merge order - 0
		4) Templiidi sätted - Index Settings :
			A. Jätta tühjaks
		5) Templiidi sätted - Mappings :
			A. "Mapped fields" -> " Add field"
			- Field name - geodestination
			- Field type - Object
			B. Loodud 'geodestination' objekti valikust -> "Add property"
			- Field name - ip
			- Field type - IP
			C. Uuesti 'geodestination' objekti valikust -> "Add property"
			- Field name - latitude
			- Field type - Numeric
			- Numeric type - Half float
			D. Uuesti 'geodestination' objekti valikust -> "Add property"
			- Field name - location
			- Field type - Geo-point
			E. Uuesti 'geodestination' objekti valikust -> "Add property"
			- Field name - longitude
			- Field type - Numeric
			- Numeric type - Half float
			F. Nüüd valida alt "Add field", et luua uus objekt
			- Field name - geoip
			- Field type - Object
			G. Loodud 'geoip' objekti valikust -> "Add property"
			- Field name - ip
			- Field type - IP
			H. Uuesti 'geoip' objekti valikust -> "Add property"
			- Field name - latitude
			- Field type - Numeric
			- Numeric type - Half float
			I. Uuesti 'geoip' objekti valikust -> "Add property"
			- Field name - location
			- Field type - Geo-point
			J. Uuesti 'geoip' objekti valikust -> "Add property"
			- Field name - longitude
			- Field type - Numeric
			- Numeric type - Half float
		6) Templiidi sätted - Aliases
			A. Jätta tühjaks
		7) "Review Template" -> "Save template"
	9.4 Nüüd võime taaskäivitada Logstashi, et rakendada uus konfiguratsioon ja saatma panna ka syslogid (kui veel ei ole) :
		1) 'sudo systemctl restart logstash' ja kontroll, kas käivitub - 'sudo service logstash status'
		2) Käivitada soovitud võrguseadmelt või serverilt syslogide saatmine vastavale pordile (näite puhul 5000)
	9.5 Syslogi Index Pattern'i loomine Kibanas :
		1) Kibanast avada "Management" -> "Index Patterns" -> "Create index pattern"
		2) Index pattern - ' syslog-* '
		3) Time Filter field name - ' @timestamp '
		4) "Create index pattern"
		5) Võimalik, et peab mõnda aega ootama, et natuke dokumente laekuks ja siis värskendama Index Patternit, et andmetüübid rakenduks:
			A. Kibanas "Management" -> "Index Patterns"
			B. Avada loodud ' syslog-* ' index
			C. Ülevalt paremalt keskmine ikoon "Refresh field list"
	9.6 Kui kõik on edukalt läinud, siis saaks geoip-d kasutades luua Kibanas kaardi:
		1) Kibana vasakult ribalt "Maps" -> "Create map"
		2) Näiteks Heat Map:
			A. "Add layer"
			B. "Grid aggregation"
			C. Index pattern - "syslog-*"
			D. Geospatial field - peaks valida saama kas "geoip.location" või "geodestination.location" (kui ei saa, siis pole geoip filter edukalt rakendunud ja geoip väljad tekkinud)
			E. Show as - "heat map"
			F. Alt paremalt "Add layer"
		3) Näiteks "Pew-Pew" map:
			A. "Add layer"
			B. "Point to point"
			C. "Index pattern - "syslog-*"
			D. Source - "geoip.location"
			E. Destination - "geodestination.location"
			F. Alt paremalt "Add layer"
		4) Kaardi saab salvestada ülevalt vasakult - "Save"

10. Nüüd on meil jooksmas kahe sõlmega Elasticsearchi klaster, millesse laekuvad Windows Eventid kogu domeenist ja Syslogid mõnest võrguseadmest :-)
