//
//  Conductor
//  ROM Player
//
//  Created by Matthew Fecher on 7/20/17.
//  Copyright © 2017 AudioKit Pro. All rights reserved.

import AudioKit

class Conductor {
    
    // Globally accessible
    static let sharedInstance = Conductor()

    var sequencer: AKAppleSequencer!
    var sampler1 = AKSampler()
    var decimator: AKDecimator
    var tremolo: AKTremolo
    var fatten: Fatten
    var filterSection: FilterSection

    var autoPanMixer: AKDryWetMixer
    var autopan: AutoPan

    var multiDelay: PingPongDelay
    var masterVolume = AKMixer()
    var reverb: AKCostelloReverb
    var reverbMixer: AKDryWetMixer
    let midi = AKMIDI()

    init() {
 
        // MIDI Configure
        midi.createVirtualPorts()
        midi.openInput(name: "Session 1")
        midi.openOutput()
    
        // Session settings
        AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .medium
        AKSettings.enableLogging = false
        
        // Allow audio to play while the iOS device is muted.
        AKSettings.playbackWhileMuted = true
     
        do {
            try AKSettings.setSession(category: .playAndRecord, with: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
        } catch {
            AKLog("Could not set session category.")
        }
 
        // Signal Chain
        tremolo = AKTremolo(sampler1, waveform: AKTable(.sine))
        decimator = AKDecimator(tremolo)
        filterSection = FilterSection(decimator)
        filterSection.output.stop()

        autopan = AutoPan(filterSection)
        autoPanMixer = AKDryWetMixer(filterSection, autopan)
        autoPanMixer.balance = 0 

        fatten = Fatten(autoPanMixer)
        
        multiDelay = PingPongDelay(fatten)
        
        masterVolume = AKMixer(multiDelay)
     
        reverb = AKCostelloReverb(masterVolume)
        
        reverbMixer = AKDryWetMixer(masterVolume, reverb, balance: 0.3)
       
        // Set a few sampler parameters
        sampler1.releaseDuration = 0.5
  
        // Init sequencer
        midiLoad("rom_poly")
        
        // load defaults
        useSound("TX Brass")
        sampler1.masterVolume = 1.0
        masterVolume.volume = 2.0
        reverb.feedback = 0.0
        multiDelay.time = 0.0
        filterSection.cutoffFrequency = 1000
        filterSection.resonance = 0.0
        filterSection.lfoAmplitude = 0.0
        filterSection.lfoRate = 0.0
        tremolo.depth = 2.0
        tremolo.frequency = 0
        decimator.rounding = 0.0
        decimator.mix = 0.0
        decimator.decimation = 0
    }
    

    
    func addMidiListener(listener: AKMIDIListener) {
        midi.addListener(listener)
    }

    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        mode = .play
        sampler1.play(noteNumber: note, velocity: velocity)
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        mode = .silent
        sampler1.stop(noteNumber: note)
    }

    func useSound(_ sound: String) {
        let soundsFolder = Bundle.main.bundleURL.appendingPathComponent("Sounds/sfz").path
        sampler1.unloadAllSamples()
        sampler1.loadSFZ(path: soundsFolder, fileName: sound + ".sfz")
    }
    
    func midiLoad(_ midiFile: String) {
        let path = "Sounds/midi/\(midiFile)"
        sequencer = AKAppleSequencer(filename: path)
        sequencer.enableLooping()
        sequencer.setGlobalMIDIOutput(midi.virtualInput)
        sequencer.setTempo(100)
    }
    
    func sequencerToggle(_ value: Double) {
        allNotesOff()
        
        if value == 1 {
            sequencer.play()
        } else {
            sequencer.stop()
        }
    }
    
    func allNotesOff() {
        for note in 0 ... 127 {
            sampler1.stop(noteNumber: MIDINoteNumber(note))
        }
    }
}
