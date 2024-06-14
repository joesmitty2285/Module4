import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var timer: Timer?
    @State private var countdown: Int = 0
    @State private var remainingTime: String = ""
    @State private var timerActive = false
    @State private var musicPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image based on time
                Image(self.isAM() ? "AMImage" : "PMImage")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Live clock
                    Text(self.getFormattedDate(date: self.currentTime))
                        .font(.title)
                        .padding()
                    
                    // Picker for countdown
                    HStack {
                        VStack {
                            Picker(selection: $selectedHours, label: Text("")) {
                                ForEach(0..<24) { hour in
                                    Text("\(hour)").tag(hour)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: geometry.size.width / 4)
                            
                            Text("hours")
                                .font(.headline)
                        }
                        
                        VStack {
                            Picker(selection: $selectedMinutes, label: Text("")) {
                                ForEach(0..<60) { minute in
                                    Text("\(minute)").tag(minute)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: geometry.size.width / 4)
                            
                            Text("mins")
                                .font(.headline)
                        }
                    }
                    
                    // Start/Stop Button
                    Button(action: {
                        self.toggleTimer()
                    }) {
                        Text(self.timerActive || self.musicPlaying ? "Stop Music" : "Start Timer")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    
                    // Remaining Time
                    Text("Time Remaining: " + self.remainingTime)
                        .padding()
                }
            }
            .onAppear {
                self.startClock()
            }
        }
    }
    
    // Function to start live clock
    func startClock() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.currentTime = Date()
        }
    }
    
    // Function to get formatted date
    func getFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // Function to check if it's AM
    func isAM() -> Bool {
        let hour = Calendar.current.component(.hour, from: self.currentTime)
        return hour < 12
    }
    
    // Function to toggle timer
    func toggleTimer() {
            if self.musicPlaying {
                self.stopMusic()
            } else if self.timerActive {
                self.stopTimer()
            } else {
                self.startTimer()
            }
        }
    
    // Function to start timer
    func startTimer() {
        self.countdown = (self.selectedHours * 3600) + (self.selectedMinutes * 60)
        self.remainingTime = self.formatTime(seconds: self.countdown)
        self.timerActive = true
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.countdown > 0 {
                self.countdown -= 1
                self.remainingTime = self.formatTime(seconds: self.countdown)
            } else {
                self.timer?.invalidate()
                self.playMusic()
                self.timerActive = false
            }
        }
    }
    
    func stopTimer() {
            self.timer?.invalidate()
            self.timerActive = false
            self.remainingTime = ""
        }
    
    // Function to stop music
    func stopMusic() {
        self.audioPlayer?.stop()
        self.timerActive = false
        self.musicPlaying = false
        self.remainingTime = ""
    }
    
    // Function to play music
    func playMusic() {
        guard let url = Bundle.main.url(forResource: "AlarmSound", withExtension: "mp3") else { return }
        self.audioPlayer = try? AVAudioPlayer(contentsOf: url)
        self.audioPlayer?.play()
        self.musicPlaying = true
    }
    
    // Function to format time
    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
