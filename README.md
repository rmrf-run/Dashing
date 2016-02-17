# Dockerized dashing monitor for Ovirt/Rhev

### Prerequisites

* working ovirt/rhev install with API available (only needed for storage domain, host, and VM info)

* working install of [Sensu](https://sensuapp.org/) with included scripts running on ovirt/rhev hosts, see folder ansible-sensu-ovirt for an add on ansible role

* docker installed on your system

### To run

* clone repo

* ``` docker pull mylivingweb/dockerfile-dashing ``` or your build your own with included DockerFile

* change selinux permissions ``` chcon -Rt svirt_sandbox_file_t Dashing ```

* edit the jobs/sensu.rb and change the ``` SENSU_API_ENDPOINT ```

* edit the jobs/nodeSummary.rb and add in your nodes ``` the_nodes ``` array and change ``` connection = Faraday.new ``` to your SENSUAPI:4567/results

* edit the jobs/ovirtSummary.rb and change the ``` connection = Faraday.new ``` to your https://ovirt.yourdomain.tld/ovirt-engine and change ``` conn.basic_auth ``` to your admin username and password

* if you use uptimerobot as well you can change the api there, otherwise you can remove the file jobs/uptimerobot.rb

* edit the dashboards/ovirt.erb to reflect your nodes, i added in 2 nodes already, a node0 and node1. The logic is as follows for each div, the ``` data-id ``` corresponds to node0Status, node0MemPer, node0TotalCPU, node0Info, node1Status, node1MemPer, etc. Whatever sensu picks up as your node or host name then change the data-id field to that plus Status or MemPer to reflect whatever you want. The ``` data-switcher-interval ``` is added in to allow switch of divs to show your different nodes and statuses.

* Once your edits have been made your can start the docker container and mount your volumes, if any errors happen they will show in stdout, if no errors happen you can add the -d option to run container as daemon ``` docker run -v /root/Dashing/assets:/assets -v /root/Dashing/dashboards:/dashboards -v /root/Dashing/config:/config -v /root/Dashing/widgets:/widgets -v /root/Dashing/jobs:/jobs -p 8080:3040 mylivingweb/docker-dashing ```

Code has been pulled from working enviroment and edited to remove corporate info, some things may have been fat fingered while editing so please edit appropriately. Also this is my 2nd or 3rd foray into ruby so if the code could have been written better please let me know where.

### Thanks
- [@Shopify](https://github.com/Shopify/dashing), for dashing
- [@frvi](https://github.com/frvi), For the original DockerFiles
- [@mattgruter](https://github.com/mattgruter), Awesome contributions!
- [@rowanu](https://github.com/rowanu), [Hotness Widget](https://gist.github.com/rowanu/6246149).
- [@munkius](https://github.com/munkius), [fork](https://gist.github.com/munkius/9209839) of Hotness Widget.
- [@chelsea](https://github.com/chelsea), [Random Aww](https://gist.github.com/chelsea/5641535).
- [@pysysops](https://github.com/pysysops), For the modified DockerFiles and general heavy lifting of it all.
- [@mrichar1](https://github.com/mrichar1/dashing-sensu), Dashing Sensu widgets and dashboard.
- [@QuibitProducts](https://github.com/QubitProducts/dashing-contrib), A dashing contribution library, I used [Switcher](https://github.com/QubitProducts/dashing-contrib/wiki/Widget:-Switcher) specifically.
- [@andre-morassut](https://gist.github.com/andre-morassut/8670610), Dashing Hotness Meter Widget

![screenshot](https://raw.githubusercontent.com/mylivingweb/Dashing/master/screenshot.png)

