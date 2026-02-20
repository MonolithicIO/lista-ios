//
//  AudioRecorder.swift
//  lista
//
//  Created by Lucca Beurmann on 20/02/26.
//

import AVFAudio
import Foundation

enum AudioRecordingError: Error {
    case permissionDenied
    case audioSessionConfigurationFailed
    case recorderStartFailed
    case noActiveRecording
    case missingDraft
    case draftPersistenceFailed
}

protocol AudioRecorderProtocol {
    var isRecording: Bool { get }
    var hasDraft: Bool { get }

    func requestRecordPermission() async -> Bool
    func startRecording() throws
    func stopRecording() throws -> URL
    func discardDraft() throws
    func saveDraft(fileName: String) throws -> String
}

final class AudioRecorder {

    static let shared = AudioRecorder()

    private var audioRecorder: AVAudioRecorder?
    private var draftRecordingURL: URL?

    private init() {}

    private var documentsDirectoryURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
    }

    private func removeDraftIfNeeded() throws {
        guard let draftRecordingURL else { return }

        if FileManager.default.fileExists(atPath: draftRecordingURL.path) {
            try FileManager.default.removeItem(at: draftRecordingURL)
        }

        self.draftRecordingURL = nil
    }
}

extension AudioRecorder: AudioRecorderProtocol {

    var isRecording: Bool {
        audioRecorder?.isRecording == true
    }

    var hasDraft: Bool {
        guard let draftRecordingURL else { return false }
        return FileManager.default.fileExists(atPath: draftRecordingURL.path)
    }

    func requestRecordPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func startRecording() throws {
        if isRecording {
            audioRecorder?.stop()
            audioRecorder = nil
        }

        try removeDraftIfNeeded()
        let draftRecordingURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).m4a")

        let recordingSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let recorder: AVAudioRecorder
        do {
            recorder = try AVAudioRecorder(
                url: draftRecordingURL,
                settings: recordingSettings
            )
        } catch {
            throw AudioRecordingError.audioSessionConfigurationFailed
        }

        recorder.prepareToRecord()
        guard recorder.record() else {
            throw AudioRecordingError.recorderStartFailed
        }

        self.audioRecorder = recorder
        self.draftRecordingURL = draftRecordingURL
    }

    func stopRecording() throws -> URL {
        guard let recorder = audioRecorder, recorder.isRecording else {
            throw AudioRecordingError.noActiveRecording
        }

        recorder.stop()
        audioRecorder = nil

        guard let draftRecordingURL, FileManager.default.fileExists(atPath: draftRecordingURL.path) else {
            throw AudioRecordingError.missingDraft
        }

        return draftRecordingURL
    }

    func discardDraft() throws {
        if isRecording {
            _ = try stopRecording()
        }

        try removeDraftIfNeeded()
    }

    func saveDraft(fileName: String) throws -> String {
        if isRecording {
            _ = try stopRecording()
        }

        guard let draftRecordingURL, FileManager.default.fileExists(atPath: draftRecordingURL.path) else {
            throw AudioRecordingError.missingDraft
        }

        let finalName = "\(fileName).m4a"
        let destinationURL = documentsDirectoryURL.appendingPathComponent(finalName)

        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }

            try FileManager.default.moveItem(at: draftRecordingURL, to: destinationURL)
            self.draftRecordingURL = nil
            return finalName
        } catch {
            throw AudioRecordingError.draftPersistenceFailed
        }
    }
}
