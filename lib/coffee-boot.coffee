window.CoffeeBoot = CoffeeBoot = {}

CoffeeBoot.boot = (url, entry='scripts/main') ->
    loader = switch fileext(url)
        when 'json' then () ->
            wget url, 'text', (manifest) ->
                buildModule JSON.parse(manifest), dirname(url), (module) ->
                    CoffeeBoot.main = module.require(entry)
        when 'tar' then () ->
            wget url, 'arraybuffer', (buffer) ->
                buildModule Tar.extract(buffer), url, (module) ->
                    CoffeeBoot.main = module.require(entry)
        else
            throw Error("unknown package format #{fileext(url)}")
    window.addEventListener 'load', loader

buildModule = (records, urlprefix, callback) ->
    module = new Module('directory')
    loadedModules = 0
    totalModules  = 0
    moduleLoaded  = () ->
        callback(module) if ++loadedModules >= totalModules
    for {path, type, buffer} in records
        newmodule = new Module(type)
        newmodule.basename = basename(path)
        if type == 'file' and not buffer?
            getFileModule(newmodule, urlprefix + path, moduleLoaded)
            totalModules++
        else
            newmodule.buffer = buffer
            newmodule.url = urlprefix + path
        directory = module.resolve(dirname(path), false)
        directory.submodules[newmodule.basename] = newmodule
        newmodule.parent = directory
    if totalModules == 0
        callback(module)

getFileModule = (module, url, callback) ->
    wget url, 'arraybuffer', (buffer) ->
        module.url    = url
        module.buffer = buffer
        callback()

wget = (url, type, success) ->
    xhr = new XMLHttpRequest()
    xhr.open('GET', url, true)
    xhr.responseType = type
    xhr.onload = () ->
        if @status == 200
            success @response
    xhr.send()

class Module
    constructor: (@type, @basename, @buffer=null, @url=null) ->
        @submodules = {}
        @parent     = null

    getRoot: () ->
        return @parent.getRoot() if @parent?
        return @

    resolve: (path='', route=true) ->
        path = rstrip(path, '/')
        path = '' if path == '.'
        path = path[2..] if path[...2] == './'

        current = switch @type
            when 'file' then @parent
            when 'directory' then this
        if path[0] == '/'
            current = current.getRoot()
            path = path[1..]
        return current if path == ''
        parent = current.parent
        for name in path.split('/')
            parent  = current
            current = current.submodules[name] if current?
        if route
            current = parent.submodules[name + '.coffee'] if parent? and not current?
            current = current.submodules['index.coffee'] ? current
        return current

    require: (path='') ->
        module = @resolve(path)
        unless module?
            throw Error("cannot access module #{path}")
        if fileext(module.basename) == 'coffee'
            return module.exports if module.exports?
            module.exports = {}
            module.loaded = false
            module.sources = TextDecoder('utf-8').decode(new Uint8Array(module.buffer))
            coffeeLoad module.sources, module.url,
                module:  module
                exports: module.exports
                require: (path='') -> module.require path
            module.loaded = true
            return module.exports
        else
            return module.buffer

coffeeLoad = (source, sourceURL, namespace) ->
    js = CoffeeScript.compile source, bare:true
    js += "\n//# sourceURL=#{sourceURL}"
    vars = []
    args = []
    for name, arg of namespace
        vars.push name
        args.push arg
    vars.push js
    return (new Function(vars...))(args...)

basename = (path) ->
    directory = ''
    base      = ''
    shift     = false
    for ch in path
        if shift
            directory += base + '/'
            base = ''
            shift = false
        if ch == '/'
            shift = true
        else
            base += ch
    return base
 
dirname = (path) ->
    directory = ''
    base  = ''
    shift     = false
    for ch in path
        if shift
            directory += base + '/'
            base = ''
            shift = false
        if ch == '/'
            shift = true
        else
            base += ch
    return directory

rstrip = (string, ch) ->
    i = string.length-1
    i-- while i >= 0 and string[i] == ch
    return string[0..i]

fileext = (path) ->
    a = path.split('.')
    return "" if a.length == 1 or (a[0] == "" and a.length == 2)
    return a.pop()
