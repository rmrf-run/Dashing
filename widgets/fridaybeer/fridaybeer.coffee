class Dashing.Fridaybeer extends Dashing.Widget

  ready: ->
    $('.beer').hide()
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.beer is "no"
      $('.beer').hide()
      $('.pour').height('0px')
      $('#liquid').height('0px')
      $('.beer-foam').css("bottom", '10px')
    else
      $('.beer').show()
      $('.pour') #Pour Me Another Drink, Bartender!
        .delay(2000)
        .animate({
          height: '360px'
          }, 1500)
        .delay(1600)
        .slideUp(500);

      $('#liquid') # I Said Fill 'Er Up!
        .delay(3400)
        .animate({
          height: '170px'
        }, 2500);

      $('.beer-foam') # Keep that Foam Rollin' Toward the Top! Yahooo!
        .delay(3400)
        .animate({
          bottom: '200px'
        }, 2500);
