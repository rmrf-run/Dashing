# Switcher widget written by Juha Mustonen / SC5
Dashing.WidgetSwitcher = WidgetSwitcher
# Switches (reloads to another address) the dashboards in periodic manner
# <div id="container" data-switcher-interval="10000" data-switcher-dashboards="dashboard1 dashboard2">
#   <%= yield %>
# </div>
#
class DashboardSwitcher
  constructor: () ->
    @dashboardNames = []
    # Collect the dashboard names from attribute, if provided (otherwise skip switching)
    names = $('[data-switcher-dashboards]').first().attr('data-switcher-dashboards') || ''
    if names.length > 1
      # Get names separated with comma or space
      @dashboardNames = (name.trim() for name in names.split(/[ ,]+/).filter(Boolean))

  start: (interval=60000) ->
    interval = parseInt(interval, 10)
    @maxPos = @dashboardNames.length - 1

    # Skip switching if no names defined
    if @dashboardNames.length == 0
      return

    # Take the dashboard name from that last part of the path
    pathParts = window.location.pathname.split('/')
    @curName = pathParts[pathParts.length - 1]
    @curPos = @dashboardNames.indexOf(@curName)

    # If not found, default to first
    if @curPos == -1
      @curPos = 0
      @curName = @dashboardNames[@curPos]

    # instantiate switcher controls for countdown and manual switching
    @switcherControls = new DashboardSwitcherControls(interval, @)
    @switcherControls.start() if @switcherControls.present()

    @startLoop(interval)

  startLoop: (interval) ->
    self = @
    @handle = setTimeout(() ->
      # Increase the position or reset back to zero
      self.curPos += 1
      if self.curPos > self.maxPos
        self.curPos = 0

      # Switch to new dashboard
      self.curName = self.dashboardNames[self.curPos]
      window.location.pathname = "/#{self.curName}"

    , interval)

  stopLoop: () ->
    clearTimeout @handle

  currentName: () ->
    @curName

  nextName: () ->
    @dashboardNames[@curPos + 1] || @dashboardNames[0]

  previousName: () ->
    @dashboardNames[@curPos - 1] || @dashboardNames[@dashboardNames.length - 1]


# Switches (hides and shows) elements within on list item
# <li switcher-interval="3000">
#   <div widget-1></div>
#   <div widget-2></div>
#   <div widget-3></div>
# </li>
#
# Supports optional switcher interval, defaults to 5sec
class WidgetSwitcher
  constructor: (@elements) ->
    @$elements = $(@elements)

  start: (interval=5000) ->
    self = @
    @maxPos = @$elements.length - 1;
    @curPos = 0

    # Show only first at start
    self.$elements.slice(1).hide()

    # Start loop
    @handle = setInterval(()->
      # Hide all at first - then show the current and ensure it uses table-cell display type
      self.$elements.hide() #.addClass('animated flipOutX')
      $(self.$elements[self.curPos]).show().css('display', 'table-cell') #.addClass('animated fadeIn')

      # Increase the position or reset back to zero
      self.curPos += 1
      if self.curPos > self.maxPos
        self.curPos = 0

    , parseInt(interval, 10))

  stop: () ->
    clearInterval(@handle)

# Adds a countdown timer to show when next dashboard will appear
# TODO:
#   - show the name of the next dashboard
#   - add controls for manually cycling through dashboards
class DashboardSwitcherControls
  arrowContent = "&#65515;"
  stopTimerContent = "stop timer"
  startTimerContent = "start timer"

  constructor: (interval=60000, dashboardSwitcher) ->
    @currentTime = parseInt(interval, 10)
    @interval = parseInt(interval, 10)
    @$elements = $('#dc-switcher-controls')
    @dashboardSwitcher = dashboardSwitcher
    @incrementTime = 1000 # refresh every 1000 milliseconds
    @arrowContent = @$elements.data('next-dashboard-content') || DashboardSwitcherControls.arrowContent
    @stopTimerContent = @$elements.data('stop-timer-content') || DashboardSwitcherControls.stopTimerContent
    @startTimerContent = @$elements.data('start-timer-content') || DashboardSwitcherControls.startTimerContent
    @

  present: () ->
    @$elements.length

  start: () ->
    @addElements()
    @$timer = $.timer(@updateTimer, @incrementTime, true)

  addElements: () ->
    template = @$elements.find('dashboard-name-template')
    if template.length
      @$nextDashboardNameTemplate = template
      @$nextDashboardNameTemplate.remove()
    else
      @$nextDashboardNameTemplate = $("<dashboard-name-template>Next dashboard: $nextName in </dashboard-name-template>")
    @$nextDashboardNameContainer = $("<span id='dc-switcher-next-name'></span>")
    @$countdown = $("<span id='dc-switcher-countdown'></span>")
    @$manualSwitcher = $("<span id='dc-switcher-next' class='fa fa-forward'></span>").
      html(@arrowContent).
      click () =>
        location.href = "/#{@dashboardSwitcher.nextName()}"
    @$switcherStopper = $("<span id='dc-switcher-pause-reset' class='fa fa-pause'></span>").
      html(@stopTimerContent).
      click(@pause)
    @$elements.
      append(@$nextDashboardNameContainer).
      append(@$countdown).
      append(@$manualSwitcher).
      append(@$switcherStopper)

  formatTime: (time) ->
    time = time / 10;
    min = parseInt(time / 6000, 10)
    sec = parseInt(time / 100, 10) - (min * 60)
    "#{(if min > 0 then @pad(min, 2) else "00")}:#{@pad(sec, 2)}"

  pad: (number, length) =>
    str = "#{number}"
    while str.length < length
      str = "0#{str}"
    str

  pause: () =>
    @$timer.toggle()
    if @isRunning()
      @dashboardSwitcher.stopLoop()
      @$switcherStopper.removeClass('fa-pause').addClass('fa-play').html(@startTimerContent)
    else
      @dashboardSwitcher.startLoop @currentTime
      @$switcherStopper.removeClass('fa-play').addClass('fa-pause').html(@stopTimerContent)

  isRunning: () =>
    @$switcherStopper.hasClass('fa-pause')

  resetCountdown: () ->
    # Get time from form
    newTime = @interval
    if newTime > 0
      @currentTime = newTime

    # Stop and reset timer
    @$timer.stop().once()

  updateTimer: () =>
    # Update dashboard name
    @$nextDashboardNameContainer.html(
      @$nextDashboardNameTemplate.html().replace('$nextName', @dashboardSwitcher.nextName())
    )
    # Output timer position
    timeString = @formatTime(@currentTime)
    @$countdown.html(timeString)

    # If timer is complete, trigger alert
    if @currentTime is 0
      @pause()
      @resetCountdown()
      return

    # Increment timer position
    @currentTime -= @incrementTime
    if @currentTime < 0
      @currentTime = 0

# Expose our API
Dashing.DashboardSwitcher = DashboardSwitcher
Dashing.WidgetSwitcher = WidgetSwitcher
Dashing.DashboardSwitcherControls = DashboardSwitcherControls

# Dashboard loaded and ready
Dashing.on 'ready', ->
  # If multiple widgets per list item, switch them periodically
  $('.gridster li').each (index, listItem) ->
    $listItem = $(listItem)
    # Take the element(s) right under the li
    $widgets = $listItem.children('div')
    if $widgets.length > 1
      switcher = new WidgetSwitcher $widgets
      switcher.start($listItem.attr('data-switcher-interval') or 5000)

  # If multiple dashboards defined (using data-swticher-dashboards="board1 board2")
  $container = $('#container')
  ditcher = new DashboardSwitcher()
  ditcher.start($container.attr('data-switcher-interval') or 60000)

