# Attaches to a controller (which provides callbacks for left/right/stop) and
# an element which input listeners are attached to.
keyDownHandler = (controller, element) ->
  # KeyCode to action mapping
  keyMap =
    37: 'left'
    39: 'right'

  currentAction = defaultAction = 'stop'

  # Send LEFT/RIGHT control event on keydown
  element.addEventListener 'keydown', (event) ->
    key = event.keyCode
    action = keyMap[key]
    return unless action
    controller[action]() unless currentAction is action
    currentAction = action
    event.stopPropagation()

  # Send STOP control event on keyup
  element.addEventListener 'keyup', (event) ->
    key = event.keyCode
    action = keyMap[key]
    return unless action
    if currentAction is action
      controller[defaultAction]()
      currentAction = defaultAction
    event.stopPropagation()

# Call to debug controller input to console
attachDebugInputHandler = ->
  document.addEventListener 'DOMContentLoaded', ->
    controller =
      left: -> console.log "LEFT"
      right: -> console.log "RIGHT"
      stop: -> console.log "STOP"
    keyDownHandler(controller, document)
