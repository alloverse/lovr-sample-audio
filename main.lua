-- erokia.ogg: https://freesound.org/people/Erokia/sounds/543742/
-- elke.ogg: https://freesound.org/people/Eelke/sounds/232991/

local voices = {}
local capturedSamples = 0 
local micStarted = nil
local sampleRate = 44100
local micGen = nil
local sinGen = lovr.data.newSound(sampleRate*1.0, "f32", "mono", sampleRate, "stream")

function makeVoice(file, color)
    local voice = {
        source= lovr.audio.newSource(file),
        color= color,
        transform= lovr.math.newMat4(),
    }
    pcall(voice.source.setLooping, voice.source, true)
    voice.source:play()
    return voice
end

function lovr.load()
    lovr.system.requestPermission('audiocapture')

    local pdevices = lovr.audio.getDevices("playback")
    for i, device in ipairs(pdevices) do
        print(device.name..(device.default and " [default]" or " "))
    end
    print("----")
    local cdevices = lovr.audio.getDevices("capture")
    for i, device in ipairs(cdevices) do
        print(device.name..(device.default and " [default]" or " "))
    end
    print("----")
    --lovr.audio.useDevice("playback", pdevices[2].name)

    local colors = {0xff0000, 0x00ff00, 0x0000ff, 0xff00ff}
    for i, file in ipairs({"elke.ogg", "erokia.ogg", sinGen}) do
        local voice = makeVoice(file, colors[i])
        table.insert(voices, voice)
    end
    generateAudio(0.2)
end

local f = 0.0
function generateAudio(dt)
	if dt > 0.1 then
		dt = 0.1
	end
	local c = dt * sampleRate
    local frames = {}
	for i=0, c-1 do
		t = math.floor(math.fmod(f, 2)) * 500 + 1500
        local sample = math.sin(f*t) * 0.6
        table.insert(frames, sample)
		f = f + 1/sampleRate
	end
    sinGen:setFrames(frames, c)
end

function lovr.update(dt)
    for i, voice in ipairs(voices) do
        voice.transform:identity():translate(0,1.4,0):rotate(lovr.timer.getTime()/2.0 + i*(6.28/#voices), 0, 1, 0):translate(0,0,-4)
        local x, y, z, sx, sy, sz, a, ax, ay, az = voice.transform:unpack()
        voice.source:setPose(x, y, z, a, ax, ay, az)
    end
    if not micGen then
        micGen = lovr.data.newSound(sampleRate*1.0, "f32", mono, sampleRate, "stream")
        local success = lovr.audio.setDevice("capture", nil, micGen, "shared")
        print("Capture set device", success)
        if success then
        table.insert(voices, makeVoice(micGen, 0xff00ff))
        end
    end
    if micGen then
        capturedSamples = micGen:getDuration("samples")
    end

    --generateAudio(dt)

    for i, v in ipairs(voices) do
        if not v.source:isPlaying() then
		    print("Starting playback", i)
            v.source:play()
        end
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
