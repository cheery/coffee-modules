typeinfo = {
    BYTE:  {size:1, jstype: 'Int8'}
    SHORT: {size:2, jstype: 'Int16'}
    INT:   {size:4, jstype: 'Int32'}
    FLOAT: {size:4, jstype: 'Float32'}
    UNSIGNED_BYTE:  {size:1, jstype: 'Uint8'}
    UNSIGNED_SHORT: {size:2, jstype: 'Uint16'}
    UNSIGNED_INT:   {size:4, jstype: 'Uint32'}
}

exports.vertexFormat = (obj) ->
    return null unless obj?
    if Object.getPrototypeOf(obj) is VertexFormat.prototype
        return obj
    else
        return new VertexFormat(obj)

exports.VertexFormat = class VertexFormat
    constructor: (@json) ->
        @stride = 0
        @fields = []
        for field in @json
            type = field.type ? "FLOAT"
            info = typeinfo[type]
            @fields.push {
                name:  field.name
                count: field.count
                type:  type
                offset: @stride
                info:  info
                normalized: field.normalized
            }
            @stride += info.size * field.count
