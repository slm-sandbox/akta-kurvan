keyDownHandler = (controller, element) ->
  keyMap =
    37: 'left'
    39: 'right'

  currentKey = null

  element.addEventListener 'keydown', (event) ->
    key = event.keyCode
    return unless keyMap[key]
    controller[key]() unless currentKey is keyMap[key]
    currentKey = keyMap[key]
    event.stopPropagataion()

  element.addEventListener 'keyup', (event) ->
    key = event.keyCode
    return unless keyMap[key]
    if currentKey is keyMap[key]
      controller['stop']
      currentKey = null
    event.stopPropagataion()

document.attachEventListener 'DOMContentLoaded', ->
  controller =
    left: console.log "LEFT"
    right: console.log "RIGHT"
    stop: console.log "STOp"
  keyDownHandler(controller, document)
