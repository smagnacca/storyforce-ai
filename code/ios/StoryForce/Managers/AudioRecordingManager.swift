import AVFoundation
import Foundation

/**
 AudioRecordingManager
 Handles voice recording, transcription, and S3 upload for practice coaching
 */

@MainActor
class AudioRecordingManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var audioURL: URL?
    @Published var isProcessing = false
    @Published var error: String?

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private let audioSession = AVAudioSession.sharedInstance()
    private var displayLink: CADisplayLink?

    override init() {
        super.init()
        setupAudioSession()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = "Failed to setup audio session: \(error.localizedDescription)"
        }
    }

    // MARK: - Recording

    func startRecording() {
        let filename = UUID().uuidString + ".wav"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(filename)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            self.audioURL = audioURL
            isRecording = true
            recordingTime = 0

            // Start timer
            startRecordingTimer()

            print("📱 Recording started: \(filename)")
        } catch {
            self.error = "Failed to start recording: \(error.localizedDescription)"
            print("❌ Recording error: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopRecordingTimer()
        print("📱 Recording stopped. Duration: \(String(format: "%.1f", recordingTime))s")
    }

    func cancelRecording() {
        audioRecorder?.stop()
        if let url = audioURL {
            try? FileManager.default.removeItem(at: url)
        }
        audioURL = nil
        isRecording = false
        recordingTime = 0
        stopRecordingTimer()
        print("📱 Recording cancelled")
    }

    // MARK: - Playback

    func playRecording() {
        guard let url = audioURL else {
            error = "No recording found"
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("🔊 Playback started")
        } catch {
            self.error = "Failed to play recording: \(error.localizedDescription)"
            print("❌ Playback error: \(error)")
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        print("🔊 Playback stopped")
    }

    // MARK: - Upload & Transcription

    func uploadAndTranscribe(
        storyId: String,
        completionHandler: @escaping (String?, String?) -> Void
    ) {
        guard let audioURL = audioURL else {
            error = "No recording to upload"
            completionHandler(nil, "No recording available")
            return
        }

        isProcessing = true

        Task {
            do {
                // Read audio file
                let audioData = try Data(contentsOf: audioURL)

                // Upload to S3
                let s3URL = try await uploadToS3(audioData)
                print("☁️  Audio uploaded to S3: \(s3URL)")

                // Call backend to transcribe and score
                let transcriptionResult = try await transcribeAudio(
                    storyId: storyId,
                    audioURL: s3URL
                )

                isProcessing = false
                completionHandler(transcriptionResult.transcription, nil)
                print("✅ Transcription & scoring complete")
            } catch {
                isProcessing = false
                self.error = error.localizedDescription
                completionHandler(nil, error.localizedDescription)
                print("❌ Upload/transcription error: \(error)")
            }
        }
    }

    private func uploadToS3(_ audioData: Data) async throws -> String {
        // TODO: Implement S3 upload with presigned URL
        // For now, return mock URL
        let filename = UUID().uuidString + ".wav"
        return "https://storyforce-audio.s3.amazonaws.com/\(filename)"
    }

    private func transcribeAudio(storyId: String, audioURL: String) async throws -> (transcription: String, score: Double) {
        let endpoint = URL(string: "http://localhost:3000/api/stories/\(storyId)/practice")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Get auth token
        guard let token = await AuthManager.shared.getValidToken() else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Mock transcription for now
        let mockTranscription = "I understand your pain with long sales cycles. Let me tell you about a similar company..."

        let body: [String: String] = [
            "audioUrl": audioURL,
            "transcription": mockTranscription,
        ]

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw NSError(domain: "API", code: -1)
        }

        let result = try JSONDecoder().decode(
            [String: AnyCodable].self,
            from: data
        )

        let score = (result["score"] as? NSNumber)?.doubleValue ?? 7.5

        return (transcription: mockTranscription, score: score)
    }

    // MARK: - Timer

    private func startRecordingTimer() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateRecordingTime)
        )
        displayLink?.preferredFramesPerSecond = 1
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopRecordingTimer() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateRecordingTime() {
        recordingTime += 1
    }

    // MARK: - AVAudioRecorderDelegate

    nonisolated func audioRecorderDidFinishRecording(
        _ recorder: AVAudioRecorder,
        successfully flag: Bool
    ) {
        Task { @MainActor in
            if !flag {
                error = "Recording failed"
            }
        }
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(
        _ recorder: AVAudioRecorder,
        error: AVAudioRecorder.ErrorCode
    ) {
        Task { @MainActor in
            self.error = "Audio encoding error: \(error)"
        }
    }

    // MARK: - Cleanup

    deinit {
        displayLink?.invalidate()
        audioRecorder?.stop()
        audioPlayer?.stop()
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }
}

// Helper for JSON encoding/decoding
struct AnyCodable: Codable {
    let value: Any

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodable")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if value is NSNull {
            try container.encodeNil()
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Cannot encode AnyCodable"
            ))
        }
    }
}
