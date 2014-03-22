Tar = this.Tar = {}

Tar.extract = (buffer, offset=0) ->
    records = []
    while not zeroFilled(buffer, offset, 1024)
        records.push record = readRecord(buffer, offset)
        offset += 512 + pad512(record.buffer.byteLength)
    return records

readRecord = (buffer, offset) ->
    throw Error("not a valid tar archive") if readString(buffer, offset+257, 5) != "ustar"
    typeFlag = readString(buffer, offset+156, 1)
    size = parseInt(readString(buffer, offset+124, 12), 8)
    return {
        path: readString(buffer, offset, 100)
        buffer: buffer.slice(offset+512, offset+512+size)
        type: switch typeFlag
            when '0' then 'file'
            when '5' then 'directory'
            else typeFlag
    }

readString = (buffer, offset, length) ->
    u8 = new Uint8Array(buffer, offset, length)
    u8 = new Uint8Array(buffer, offset, strlen(u8))
    return TextDecoder('utf-8').decode(u8)

strlen = (u8) ->
    for i in [0...u8.length]
        return i if u8[i] == 0
    return u8.length

zeroFilled = (buffer, offset, count) ->
    u8 = new Uint8Array(buffer, offset)
    for x in u8
        return false if x != 0
    return true

pad512 = (x) -> x + (512 - x%512) % 512
