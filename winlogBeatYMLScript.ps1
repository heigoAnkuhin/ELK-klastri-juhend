Import-Module ActiveDirectory
# autendin adminina
$cred = Get-Credential

# hangin koik arvutid, mida soovin..
$computers = Get-ADComputer -Filter {DNSHostName -like "*"}

# voi siis sellega votta arvutid.. -> $computers = Get-ADComputer -Filter 'operatingsystem -notlike "*server*"'

# kontrollime kas leidsime yldse mone arvuti..
if($computers.Count -lt 1) {
    Write-Host "Ei leitud yhtegi arvutit.."
    exit
    }

foreach ($computer in $computers) {
    Write-Host "Testin yhendust arvutiga $computer.DNSHostName"
    # tegelt connection test kukub labi kui ICMP on blokeeritud tulemyyris..
    if(Test-Connection -ComputerName $computer.DNSHostName -Count 1 -ErrorAction SilentlyContinue) {
        Write-Host "Arvuti tootab ja vastab paringutele. Kaivitame kasud..." -ForegroundColor Green
        $s = New-PSSession -ComputerName $computer.DNSHostName -Credential $cred
        # alustame failitootlusega - itereerime iga arvuti labi..
            Invoke-Command -Session $s -ScriptBlock {


                $winlogBeatDirectory = "C:\ProgramData\Elastic\Beats\winlogbeat"

                if(!(Test-Path $winlogBeatDirectory)) {
                    Write-Host "Winlogbeati pole arvutis $env:computername paigaldatud. Votan jargmise arvuti." -ForegroundColor Yellow
                    continue
                 }

                 else {
                

                    Set-Location -Path $winlogBeatDirectory

                    Copy-Item .\winlogbeat.example.yml -Destination .\winlogbeat.yml -Force


                    $ymlContent = Get-Content .\winlogbeat.yml
                    $replaceElasticOutput = '#output.elasticsearch:'
					$replaceElasticHost = '#  hosts: ["localhost:9200"]'
					$replaceLogstashOutput = 'output.logstash:'
					$replaceLogstashHost = '  hosts: ["elk-srv.maikool.local:5044"]' # <- SIIN MUUTA	


                    $ymlContent | % { $_.Replace('output.elasticsearch:', $replaceElasticOutput) } | Set-Content .\winlogbeat.yml
                    $ymlContent = Get-Content .\winlogbeat.yml					
					$ymlContent | % { $_.Replace('  hosts: ["localhost:9200"]', $replaceElasticHost) } | Set-Content .\winlogbeat.yml
                    $ymlContent = Get-Content .\winlogbeat.yml					
					$ymlContent | % { $_.Replace('#output.logstash:', $replaceLogstashOutput) } | Set-Content .\winlogbeat.yml
                    $ymlContent = Get-Content .\winlogbeat.yml					
					$ymlContent | % { $_.Replace('  #hosts: ["localhost:5044"]', $replaceLogstashHost) } | Set-Content .\winlogbeat.yml

                    Restart-Service winlogbeat
                    Write-Host "Toimingud lopetatud arvutis $env:computername" -ForegroundColor Cyan

               }
            }
        }
        else {

            Write-Host "Arvuti ei vasta. Kontrolli yhendust voi pane ta kaima." -ForegroundColor Red

            }
    }
