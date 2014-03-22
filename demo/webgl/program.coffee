VertexFormat = require('vertex-format').VertexFormat

exports.compile = (gl, module) ->
    program = gl.createProgram()
    shaders = parse({}, module)
    for name, source of shaders
        shader = gl.createShader(gl[name])
        gl.attachShader(program, shader)
        gl.shaderSource(shader, source)
        gl.compileShader(shader)
        unless gl.getShaderParameter(shader, gl.COMPILE_STATUS)
            throw gl.getShaderInfoLog(shader)
    gl.linkProgram(program)
    unless gl.getProgramParameter(program, gl.LINK_STATUS)
        throw gl.getProgramInfoLog(program)
    return new Program(gl, program)

parse = (shaders, module) ->
    intro = "precision mediump float;"
    valid_shaders = {VERTEX_SHADER:true, FRAGMENT_SHADER:true}
    read = (command, text) ->
        if valid_shaders[command]
            shaders[command] ?= intro
            shaders[command] += text
        else if command[...8] == 'include '
            parse(shaders, module.resolve(command[8...]))
        else if command == 'generic'
            for name, flag of valid_shaders
                shaders[name] ?= intro
                shaders[name] += text
        else
            throw Error("shader program command error: #{command}")
    module.sources = TextDecoder('utf-8').decode(new Uint8Array(module.buffer))
    for block in module.sources.split(/\n(?=\w)/)
        cr = block.indexOf('\n')
        if cr >= 0
            command = block[...cr].trim()
            text    = block[cr...]
            read(command, text)
        else
            read(block, null)
    return shaders

exports.Program = class Program
    constructor: (@gl, @object) ->
        @uniform_cache = {}
        @attrib_cache  = {}
        @current_vertex_format = null

    loc: (name) ->
        if @uniform_cache[name]?
            return @uniform_cache[name]
        loc = @gl.getUniformLocation(@object, name)
        @uniform_cache[name] = loc
        return loc

    attribLoc: (name) ->
        if @attrib_cache[name]?
            return @attrib_cache[name]
        loc = @gl.getAttribLocation(@object, name)
        @attrib_cache[name] = loc
        return loc

    uniform1f: (name, x) ->
        @gl.uniform1f(@loc(name), x)

    uniformVec2: (name, vec2) ->
        @gl.uniform2fv(@loc(name), vec2)

    uniformVec3: (name, vec3) ->
        @gl.uniform3fv(@loc(name), vec3)

    uniformMat4: (name, matrix) ->
        @gl.uniformMatrix4fv(@loc(name), @gl.FALSE, matrix)

    use: () ->
        @gl.useProgram(@object)

    vertexFormat: (next) ->
        return false if @current_vertex_format is next
        if @current_vertex_format?
            for field in @current_vertex_format.fields
                loc = @attribLoc(field.name)
                @gl.disableVertexAttribArray(loc) if loc >= 0
        @current_vertex_format = next
        if next?
            stride = next.stride
            for field in next.fields
                loc = @attribLoc(field.name)
                if loc >= 0
                    normalized = @gl.FALSE
                    normalized = @gl.TRUE  if field.normalized
                    @gl.enableVertexAttribArray(loc)
                    @gl.vertexAttribPointer(loc, field.count, @gl[field.type], normalized, stride, field.offset)
        return true
