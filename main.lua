-- erokia.ogg: https://freesound.org/people/Erokia/sounds/543742/
-- elke.ogg: https://freesound.org/people/Eelke/sounds/232991/

local voices = {}
local capturedSamples = 0 
local micStarted = nil

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
    local captured = lovr.audio.getCaptureDuration("samples")
    if captured > 0 then
        capturedSamples = capturedSamples + captured
        local data = lovr.audio.capture()
        lovr.filesystem.append("audio.pcm", data:getBlob():getString())
    end

    if lovr.headset.wasPressed("hand/left", "trigger") or lovr.headset.wasPressed("hand/right", "a") then
        micStarted = lovr.audio.start("capture")
        lovr.filesystem.write("audio.pcm", "")
    end
end

function lovr.draw()
    for _, voice in ipairs(voices) do
        lovr.graphics.setColor(voice.color)
        lovr.graphics.cube("line", voice.transform)
        local tell = voice.source.tell and voice.source.tell or voice.source.getTime
        local frac = tell(voice.source) / voice.source:getDuration()
        lovr.graphics.cube("fill", lovr.math.mat4(voice.transform):translate(0.5-frac/2,0,0):scale(frac,1,1))
    end
    if micStarted == nil then lovr.graphics.setColor(1,1,1,1) elseif micStarted == true then lovr.graphics.setColor(0,1,0,1) else lovr.graphics.setColor(1,0,0,1) end
    lovr.graphics.print(string.format("Captured %.2fs", capturedSamples/44100), 0, 1.5, -2, 0.1)
end