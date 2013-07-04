keyDownHandler = (controller, element) ->
  keyMap =
    37: 'left'
    39: 'right'

  currentAction = defaultAction = 'stop'

  element.addEventListener 'keydown', (event) ->
    key = event.keyCode
    action = keyMap[key]
    return unless action
    controller[action]() unless currentAction is action
    currentAction = action
    event.stopPropagation()

  element.addEventListener 'keyup', (event) ->
    key = event.keyCode
    action = keyMap[key]
    return unless action
    console.log { action: action, current: currentAction }
    if currentAction is action
      controller[defaultAction]()
      currentAction = defaultAction
    event.stopPropagation()

# Call to debug controller input to console
debugController = ->
  document.addEventListener 'DOMContentLoaded', ->
    controller =
      left: -> console.log "LEFT"
      right: -> console.log "RIGHT"
      stop: -> console.log "STOP"
    keyDownHandler(controller, document)
