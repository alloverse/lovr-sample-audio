-- erokia.ogg: https://freesound.org/people/Erokia/sounds/543742/
-- elke.ogg: https://freesound.org/people/Eelke/sounds/232991/

local voices = {}

function makeVoice(file, color)
    local voice = {
        source= lovr.audio.newSource(file, "static"),
        color= color,
        transform= lovr.math.newMat4(),
    }
    voice.source:setLooping(true)
    voice.source:play()
    return voice
end

function lovr.load()
    local colors = {0xff0000, 0x00ff00, 0x0000ff}
    for i, file in ipairs({"elke.ogg", "erokia.ogg"}) do
        local voice = makeVoice(file, colors[i])
        table.insert(voices, voice)
    end
end

function lovr.update()
    for i, voice in ipairs(voices) do
        voice.transform:identity():translate(0,1.4,0):rotate(lovr.timer.getTime()/2.0 + i*3.14, 0, 1, 0):translate(0,0,-4)
        local x, y, z, sx, sy, sz, a, ax, ay, az = voice.transform:unpack()
        voice.source:setPose(x, y, z, a, ax, ay, az)
    end
end

function lovr.draw()
    for _, voice in ipairs(voices) do
        lovr.graphics.setColor(voice.color)
        lovr.graphics.cube("line", voice.transform)
        local frac = voice.source:tell() / voice.source:getDuration()
        lovr.graphics.cube("fill", lovr.math.mat4(voice.transform):translate(0.5-frac/2,0,0):scale(frac,1,1))
    end
end