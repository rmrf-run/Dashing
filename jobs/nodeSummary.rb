require 'json'
require 'pp'
require 'faraday'
require 'faraday_middleware'
SCHEDULER.every('30s', first_in: '1s') {
the_nodes = []
#fill the node array in with your own node names
nodeDomain = "REPLACE_THIS_WITH_YOUR_TLD"


#fill the url in with the url to your sensu api if no on the same server
connection = Faraday.new 'http://localhost:4567/results/' do |conn|
	conn.response :json
        conn.adapter Faraday.default_adapter
end
the_nodes.each do |node|
	url = "#{node}"
        sensu_response = connection.get(url)
	#Sensu plugin: sensu-plugin-selinux
        selinux = sensu_response.body[3]["check"]["output"]
        selinux = selinux.delete('"')
        selinux = selinux[17..-1]#("SELinuxCheck OK: ")
        selinux = selinux.split(" ")
	#sensu script to check VMs on ovirt or rhev: count_vms.sh
	checkvms = sensu_response.body[7]["check"]["output"]
        checkvms = checkvms.delete('"')
	#redundant code here but pulls in the node name
        nodename = sensu_response.body[0]["client"]
        nodename = nodename.delete('"')
	#sensu plugin: sensu-plugins-cpu-checks
        nodecpu = sensu_response.body[2]["check"]["output"]
        nodecpu = nodecpu.split(" ")[3..-1]
        nodecpu = nodecpu[0].delete('"')
        nodecpu = nodecpu.split("=")
        nodecpu = nodecpu[1]
	nodecpu = nodecpu.to_f.round(0)
	#check node status
	nodestatus = sensu_response.body[9]["check"]["status"]
	nodestatus = nodestatus.to_i
	if nodestatus == 0
		nodestatus = "ok"
	elsif nodestatus == 1
		nodestatus = "warning"
	else
		nodestatus = "critical"
	end
	#sensu script to check memtotal: check_memory_total.sh 
	nodememtotal = sensu_response.body[6]["check"]["output"]
	#sensu script to check memfree: check_memory_free.sh
        nodememfree = sensu_response.body[8]["check"]["output"]
        nodememused = (nodememtotal.to_f - nodememfree.to_f)
        nodememper = (nodememused.to_f / nodememtotal.to_f) * 100
        nodememtotal = nodememtotal.to_f
        nodememfree = nodememfree.to_f
        nodememused = nodememused.to_f
        nodememper = nodememper.round(0)
	
	nodeName = "#{node}"        
	nodeName.delete('"')

	nodeAddress = "#{node}"
	nodeUrl = [nodeAddress, nodeDomain].join(".")
	
	#push all this info over to ovirt dashboard
	buzzwords = {}
	buzzwords["avm"] = {label: 'Active VMs', value: checkvms}
	buzzwords["selinux"] = {label: 'Selinux Mode', value: selinux[3]}
		send_event("#{nodeName}Info", { items: buzzwords.values })
		send_event("#{nodeName}Status", {message: nodeUrl, status: nodestatus})
		send_event("#{nodeName}MemPer", {value: nodememper })
		send_event("#{nodeName}TotalCPU", {value: nodecpu})
end
}

