

turnAngle = 2*Math.PI/20
speed = 4
lines = 40

getNewPos = (pos, steps, turnAngle)->
  denominator = Math.sin(turnAngle/2)
  if Math.abs(denominator)<0.0000000001
    return [pos[0],pos[1]+speed*steps, pos[2]]

  sin1 = Math.sin(steps*turnAngle/2)/denominator
  changeLeft = speed*sin1*Math.sin((steps+1)*turnAngle/2)
  changeForward = speed*sin1*Math.cos((steps+1)*turnAngle/2)
  changeAngle = turnAngle*steps

  console.log 'changeLeft', changeLeft
  console.log 'changeForward', changeForward
  console.log 'changeAngle', changeAngle
  newPos = [
    pos[0] + Math.cos(pos[2])*changeLeft - Math.sin(pos[2])* changeForward
    pos[1] + Math.sin(pos[2])*changeLeft + Math.cos(pos[2])* changeForward
    pos[2] + changeAngle
  ]


investigateTraces = (pos, steps, rays)->
  angles =  (x for x in [-turnAngle..turnAngle] by turnAngle*2/rays)
  angles.map (angle)->
    [1..steps].map (step)->
      getNewPos(pos, step, angle)




console.log investigateTraces [0,0,0], 1, 10
