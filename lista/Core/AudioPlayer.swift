//
//  AudioPlayer.swift
//  lista
//

import AVFAudio
import Foundation

enum AudioPlaybackError: Error {
    case fileNotFound
    case playbackFailed
}

protocol AudioPlayerProtocol {
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }

    func play(url: URL) throws
    func pause()
    func stop()
}

final class AudioPlayer {
    static let shared = AudioPlayer()

    private var player: AVAudioPlayer?

    private init() {}
}

extension AudioPlayer: AudioPlayerProtocol {
    var isPlaying: Bool {
        player?.isPlaying == true
    }

    var currentTime: TimeInterval {
        player?.currentTime ?? 0
    }

    var duration: TimeInterval {
        player?.duration ?? 0
    }

    func play(url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw AudioPlaybackError.fileNotFound
        }

        do {
            if player?.url != url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
            }

            if let player, player.currentTime >= player.duration {
                player.currentTime = 0
            }

            guard player?.play() == true else {
                throw AudioPlaybackError.playbackFailed
            }
        } catch {
            throw AudioPlaybackError.playbackFailed
        }
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
    }
}
