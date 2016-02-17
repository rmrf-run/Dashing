require 'uptimerobot'

apiKey = 'USE_YOUR_API_KEY'

SCHEDULER.every '3m', :first_in => 0 do |job|
  client = UptimeRobot::Client.new(apiKey: apiKey)

  raw_monitors = client.getMonitors['monitors']['monitor']

  items = raw_monitors.map { |monitor| 
    { 
      label: monitor['friendlyname'],
      ratio: monitor['alltimeuptimeratio'], 
      value: if monitor['status'] == '0' then 'Paused' elsif monitor['status'] == '2' then 'Up' elsif monitor['status'] == '9' then 'Down' else 'Unknown' end      
    }

  }
  send_event('uptimerobot', { items: items } )

end
