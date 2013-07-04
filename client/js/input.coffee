# Attaches to a controller (which provides callbacks for left/right/stop) and
# an element which input listeners are attached to.
window.keyDownHandler = (controller, element) ->
  # KeyCode to action mapping
  keyMap =
    37: 'left'
    39: 'right'

  currentAction = defaultAction = 'stop'

  controlKeyListener = (event) ->
    key = event.keyCode
    action = keyMap[key]
    return unless action

    # Keydown: LEFT / RIGHT
    if event.type is 'keydown'
      controller[action]() if currentAction isnt action
      currentAction = action
    # Keyup: STOP
    else if currentAction is action
      controller[defaultAction]()
      currentAction = defaultAction

    event.stopPropagation()

  element.addEventListener 'keydown', controlKeyListener
  element.addEventListener 'keyup', controlKeyListener

# Call to debug controller input to console
window.attachDebugInputHandler = ->
  document.addEventListener 'DOMContentLoaded', ->
    controller =
      left: -> console.log "LEFT"
      right: -> console.log "RIGHT"
      stop: -> console.log "STOP"
    keyDownHandler(controller, document)
