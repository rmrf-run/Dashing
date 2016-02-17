# Place this file in assets/javascripts/
# Dashing compiles it to JavaScript

class @Cycler

  $ = jQuery

  constructor: (options) ->
    @boards = options.boards or []
    @duration = options.duration or 10
    @loadAll = options.loadAll or false
    @width = options.width or 1920
    @height = options.height or 1080

    # Init counter
    @counter = -1

    # Make sure there aren't any margins or padding
    $('body, #container').css
      margin: 0
      padding: 0
      overflow: 'hidden'

    # Create the container
    @$container =
      $('<div />',
        id: 'cycler-boards'
      ).css(
        width: @width
        height: @height
        overflow: 'hidden'
      ).appendTo '#container'

    # If loadAll is enabled, create all the boards right away
    if @loadAll
      for board, i in @boards
        @showBoard(i, false)

    # Warning
    if @loadAll and @boards.length > 4
      console?.warn 'You have a large-ish number of boards – consider setting
                     `loadAll` to false for better performance.'

    # Start the first cycle
    @next()


  nextCounterValue: ->
     if @counter < @boards.length - 1 then @counter + 1 else 0


  $getBoard: (i) ->
    @$container.children(".board##{ @boards[i] }")


  showBoard: (i, visible = false) ->
    if @$getBoard(i).length
      # If the board is already in DOM, just show it
      @$getBoard(i).show() if visible

    else
      # If the board doesn't exist already, create and load it
      $('<iframe />',
        src: @boards[i]
        id: @boards[i]
        class: 'board'
      ).css(
        display: if visible then 'block' else 'none'
        width: @width
        height: @height
        border: 'none'
      ).appendTo @$container


  next: ->
    $previousBoard = @$getBoard(@counter)

    # Advance the counter
    @counter = @nextCounterValue()

    # Create and show the new board
    @showBoard(@counter, true)

    # Hide or remove the previous board
    if @boards.length <= 2 or @loadAll
      $previousBoard.hide()
    else
      $previousBoard.remove()

    # Create the board that will be shown in the next iteration, hidden for now
    @showBoard(@nextCounterValue(@counter), false)

    # Start the cycle again after the duration has passed
    setTimeout ( => @next() ), @duration * 1000
