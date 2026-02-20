//
//  InsertItemAudioView.swift
//  lista
//

import SwiftUI

struct InsertItemAudioView: View {
    @Binding var isRecording: Bool
    @Binding var hasDraft: Bool
    @Binding var isPlaying: Bool
    @Binding var playbackProgress: Double

    let onStartRecording: () -> Void
    let onStopRecording: () -> Void
    let onDiscardDraft: () -> Void
    let onTogglePlayback: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if isRecording {
                recordingStateView
            } else if hasDraft {
                draftReadyStateView
            } else {
                idleStateView
            }
        }
    }

    private var idleStateView: some View {
        Button {
            onStartRecording()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "mic")
                    .font(.title3)
                    .foregroundStyle(AppColors.blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "button.record_audio_note"))
                        .font(.headline)
                        .foregroundStyle(AppColors.blue)

                    Text(String(localized: "subtitle.tap_to_start_recording"))
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedForeground)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [5]
                        )
                    )
                    .foregroundStyle(AppColors.mutedForeground)
            )
        }
    }

    private var recordingStateView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)

                Text(String(localized: "status.recording_in_progress"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.cardForeground)

                Spacer()
            }

            Button {
                onStopRecording()
            } label: {
                Text(String(localized: "button.stop_recording"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColors.accentForeground)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.blue)
            )
        }
    }

    private var draftReadyStateView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "waveform")
                    .foregroundStyle(AppColors.green)

                Text(String(localized: "status.audio_note_ready"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.cardForeground)

                Spacer()
            }

            Button {
                onTogglePlayback()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    Text(
                        isPlaying
                            ? String(localized: "button.pause_audio")
                            : String(localized: "button.play_audio")
                    )
                    .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(AppColors.accentForeground)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppColors.blue)
            )

            ProgressView(value: playbackProgress, total: 1)
                .tint(AppColors.blue)
                .frame(maxWidth: .infinity)

            HStack(spacing: 10) {
                Button {
                    onStartRecording()
                } label: {
                    Text(String(localized: "button.re_record"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppColors.background)
                )

                Button(role: .destructive) {
                    onDiscardDraft()
                } label: {
                    Text(String(localized: "button.discard"))
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
