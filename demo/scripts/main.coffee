webgl = require('/webgl')

canvas = document.getElementById('demo')
canvas.style.position = 'fixed'
canvas.style.left   = '0px'
canvas.style.top    = '0px'
canvas.style.width  = '100%'
canvas.style.height = '100%'
canvas.style.zIndex = '-100'
canvas.style.display = 'block'
document.body.appendChild(canvas)
gl = canvas.getContext 'webgl'

window.gl = gl

main_glsl = webgl.compile(gl, module.resolve('main.glsl'))
vfmt_p3 = webgl.vertexFormat [
    {name:'position', count:2}
]
vbo = gl.createBuffer()
gl.bindBuffer(gl.ARRAY_BUFFER, vbo)
gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
    -1.0, -1.0, +1.0, -1.0, -1.0, +1.0,
    -1.0, +1.0, +1.0, -1.0, +1.0, +1.0,
]), gl.STATIC_DRAW)

main = () ->
    resizeCanvas()
    window.addEventListener 'resize', resizeCanvas
    draw()

now = Date.now()/1000
start = now - now%100000
draw = () ->
    now = Date.now()/1000 - start
    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height)
    gl.clearColor 0.5, Math.sin(Date.now()/1000.0) * 0.5 + 0.5, 0.5, 0.5
    gl.clear gl.COLOR_BUFFER_BIT

    main_glsl.use()
    main_glsl.vertexFormat vfmt_p3
    main_glsl.uniform1f('time', now)
    main_glsl.uniformVec2('resolution', [canvas.width, canvas.height])

    body = document.body
    main_glsl.uniformVec2('scroll', [body.scrollLeft, body.scrollTop])

    gl.drawArrays gl.TRIANGLES, 0, 6

    main_glsl.vertexFormat null

    requestAnimationFrame draw

resizeCanvas = () ->
    if canvas.width != canvas.clientWidth or canvas.height != canvas.clientHeight
        canvas.width  = canvas.clientWidth
        canvas.height = canvas.clientHeight

main()
window.module = module
