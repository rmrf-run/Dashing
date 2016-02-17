require 'json'
require 'pp'
require 'faraday'
require 'faraday_middleware'
#REPLACE LOCAL HOST WITH THE URL TO YOUR OVIRT ENGINE AS WELL AS USERNAME AND PASSWORD
#This job is basic info about storage domains and # of VMs, I recommend keeping the scheduler limited to every 1800s
SCHEDULER.every('1800s', first_in: '1s') {
connection = Faraday.new 'https://localhost/ovirt-engine/' do |conn|
        conn.basic_auth 'admin_user', 'password'
        conn.response :json
        conn.adapter Faraday.default_adapter
end
json_response = connection.get('api?accept=application/json')
#get total VMs
sumVMsTotal = json_response.body["summary"]["vms"]["total"]
#get total Hosts
sumHostsTotal = json_response.body["summary"]["hosts"]["total"]
#get total Storage domains
sumSDtotal = json_response.body["summary"]["storage_domains"]["total"]
#send it all to the dashboard
send_event('vmsonline',{
        current: sumVMsTotal
	})
send_event('hostsonline',{
	current: sumHostsTotal
	})
send_event('sdsonline',{
        current: sumSDtotal
        })
send_event('dcsonline',{
	current: '2'
#hardcoded number of datacenters, if you have a different number you can put it here
	})
#pull in storage domain info
json_response2 = connection.get('api/storagedomains?accept=application/json')
sd1 = json_response2.body["storage_domain"][0]["available"]
sd1 = sd1.to_f / 1099511627776.0
sd2 = json_response2.body["storage_domain"][1]["storage"]["volume_group"]["logical_unit"][0]["size"]
sd2 = sd2.to_f / 1099511627776.0
sd3 = json_response2.body["storage_domain"][2]["storage"]["volume_group"]["logical_unit"][0]["size"]
sd3 = sd3.to_f / 1099511627776.0
sd4 = json_response2.body["storage_domain"][4]["storage"]["volume_group"]["logical_unit"][0]["size"]
sd4 = sd4.to_f / 1099511627776.0
sd5 = json_response2.body["storage_domain"][5]["storage"]["volume_group"]["logical_unit"][0]["size"]
sd5 = sd5.to_f / 1099511627776.0
totalSD = sd1 + sd2 + sd3 + sd4 + sd5
totalSD = "#{totalSD.round(1)}TB"
#send total storage over to dashboard
send_event('totalSD',{
        current: totalSD
        })
sd1a = json_response2.body["storage_domain"][0]["used"]
sd1a = sd1a.to_f / 1099511627776.0
sd2a = json_response2.body["storage_domain"][1]["used"]
sd2a = sd2a.to_f / 1099511627776.0
sd3a = json_response2.body["storage_domain"][2]["used"]
sd3a = sd3a.to_f / 1099511627776.0
sd4a = json_response2.body["storage_domain"][4]["used"]
sd4a = sd4a.to_f / 1099511627776.0
sd5a = json_response2.body["storage_domain"][5]["used"]
sd5a = sd5a.to_f / 1099511627776.0
usedSD = sd1a + sd2a + sd3a + sd4a + sd5a
usedSD = "#{usedSD.round(1)}TB"
#send used storage over to dashbaord
send_event('usedSD',{
        current: usedSD
        })
sd1b = json_response2.body["storage_domain"][0]["available"]
sd1b = sd1b.to_f / 1099511627776.0
sd2b = json_response2.body["storage_domain"][1]["available"]
sd2b = sd2b.to_f / 1099511627776.0
sd3b = json_response2.body["storage_domain"][2]["available"]
sd3b = sd3b.to_f / 1099511627776.0
sd4b = json_response2.body["storage_domain"][4]["available"]
sd4b = sd4b.to_f / 1099511627776.0
sd5b = json_response2.body["storage_domain"][5]["available"]
sd5b = sd5b.to_f / 1099511627776.0
availSD = sd1b + sd2b + sd3b + sd4b + sd5b
availSD = "#{availSD.round(1)}TB"
#send available storage to dashboard
send_event('availSD',{
        current: availSD
        })

}

