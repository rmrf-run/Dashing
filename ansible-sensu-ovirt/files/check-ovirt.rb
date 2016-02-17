#!/opt/sensu/embedded/bin/ruby
#
## get the current list of processes
processes = `ps aux`
#
## determine if the chef-client process is running
running = processes.lines.detect do |process|
  process.include?('ovirt')
  end
#
#  # return appropriate check output and exit status code
if running
        puts 'OK - Ovirt is running'
        exit 0
else
        puts 'WARNING - Ovirt is NOT running'
        exit 1
end