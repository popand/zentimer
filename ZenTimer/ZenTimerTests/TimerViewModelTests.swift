import XCTest
import Combine
@testable import ZenTimer

final class TimerViewModelTests: XCTestCase {
    var viewModel: TimerViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        super.setUp()
        viewModel = TimerViewModel()
        cancellables = Set<AnyCancellable>()

        // Clear any existing UserDefaults state
        clearUserDefaults()
    }

    override func tearDownWithError() throws {
        cancellables.forEach { $0.cancel() }
        cancellables = nil
        viewModel = nil
        clearUserDefaults()
        super.tearDown()
    }

    private func clearUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "timerEndDate")
        defaults.removeObject(forKey: "timerTotalSeconds")
        defaults.removeObject(forKey: "timerStartDate")
        defaults.removeObject(forKey: "flashEnabled")
        defaults.removeObject(forKey: "vibrationEnabled")
        defaults.removeObject(forKey: "soundEnabled")
        defaults.removeObject(forKey: "doNotDisturbEnabled")
    }

    // MARK: - Initial State Tests

    func testInitialState() throws {
        XCTAssertEqual(viewModel.minutes, 5)
        XCTAssertEqual(viewModel.totalSeconds, 300) // 5 * 60
        XCTAssertEqual(viewModel.timeLeft, 300)
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertFalse(viewModel.isDragging)
        XCTAssertNil(viewModel.dragProgress)
    }

    func testInitialNotificationPreferences() throws {
        XCTAssertFalse(viewModel.flashEnabled)
        XCTAssertTrue(viewModel.vibrationEnabled) // Default to true
        XCTAssertFalse(viewModel.soundEnabled)
        XCTAssertFalse(viewModel.doNotDisturbEnabled)
    }

    // MARK: - Time Setting Tests

    func testSetTimeFromProgress() throws {
        // Test setting time to 30 minutes (50% progress)
        viewModel.setTime(fromProgress: 0.5)

        XCTAssertEqual(viewModel.minutes, 30)
        XCTAssertEqual(viewModel.totalSeconds, 1800) // 30 * 60
        XCTAssertEqual(viewModel.timeLeft, 1800)
        XCTAssertEqual(viewModel.dragProgress, 0.5)
    }

    func testSetTimeFromProgressBoundaries() throws {
        // Test minimum boundary (0% should give 1 minute)
        viewModel.setTime(fromProgress: 0.0)
        XCTAssertEqual(viewModel.minutes, 1)
        XCTAssertEqual(viewModel.totalSeconds, 60)
        XCTAssertEqual(viewModel.timeLeft, 60)

        // Test maximum boundary (100% should give 60 minutes)
        viewModel.setTime(fromProgress: 1.0)
        XCTAssertEqual(viewModel.minutes, 60)
        XCTAssertEqual(viewModel.totalSeconds, 3600)
        XCTAssertEqual(viewModel.timeLeft, 3600)
    }

    func testSetTimeWhileRunning() throws {
        // Start timer first
        viewModel.toggleTimer()
        XCTAssertTrue(viewModel.isRunning)

        let originalMinutes = viewModel.minutes
        let originalTimeLeft = viewModel.timeLeft

        // Try to set time while running - should be ignored
        viewModel.setTime(fromProgress: 0.8)

        XCTAssertEqual(viewModel.minutes, originalMinutes)
        XCTAssertEqual(viewModel.timeLeft, originalTimeLeft)
    }

    func testAdjustMinutes() throws {
        // Test increasing minutes
        viewModel.adjustMinutes(by: 5)
        XCTAssertEqual(viewModel.minutes, 10)
        XCTAssertEqual(viewModel.totalSeconds, 600)
        XCTAssertEqual(viewModel.timeLeft, 600)

        // Test decreasing minutes
        viewModel.adjustMinutes(by: -3)
        XCTAssertEqual(viewModel.minutes, 7)
        XCTAssertEqual(viewModel.totalSeconds, 420)
        XCTAssertEqual(viewModel.timeLeft, 420)
    }

    func testAdjustMinutesBoundaries() throws {
        // Test minimum boundary
        viewModel.adjustMinutes(by: -10) // Should clamp to 1
        XCTAssertEqual(viewModel.minutes, 1)

        // Test maximum boundary
        viewModel.adjustMinutes(by: 100) // Should clamp to 99
        XCTAssertEqual(viewModel.minutes, 99)
    }

    func testAdjustMinutesWhileRunning() throws {
        viewModel.toggleTimer()
        XCTAssertTrue(viewModel.isRunning)

        let originalMinutes = viewModel.minutes
        viewModel.adjustMinutes(by: 5)

        // Should be ignored while running
        XCTAssertEqual(viewModel.minutes, originalMinutes)
    }

    // MARK: - Progress Calculation Tests

    func testProgressCalculation() throws {
        viewModel.setTime(fromProgress: 0.5) // 30 minutes

        // Initially, progress should be 100% (full time remaining)
        XCTAssertEqual(viewModel.progress, 1.0, accuracy: 0.001)

        // Simulate time passing
        viewModel.timeLeft = 900 // 15 minutes remaining out of 30
        XCTAssertEqual(viewModel.progress, 0.5, accuracy: 0.001)

        // Timer completed
        viewModel.timeLeft = 0
        XCTAssertEqual(viewModel.progress, 0.0, accuracy: 0.001)
    }

    func testSetTimeProgress() throws {
        // Test without dragging
        viewModel.minutes = 30
        XCTAssertEqual(viewModel.setTimeProgress, 0.5, accuracy: 0.001) // 30/60

        // Test with dragging
        viewModel.isDragging = true
        viewModel.dragProgress = 0.75
        XCTAssertEqual(viewModel.setTimeProgress, 0.75, accuracy: 0.001)

        // Test dragging takes precedence
        viewModel.minutes = 10 // This should be ignored while dragging
        XCTAssertEqual(viewModel.setTimeProgress, 0.75, accuracy: 0.001)
    }

    // MARK: - Formatted Time Tests

    func testFormattedTime() throws {
        // Test various time formats
        viewModel.timeLeft = 3661 // 1:01:01
        XCTAssertEqual(viewModel.formattedTime, "61:01")

        viewModel.timeLeft = 125 // 2:05
        XCTAssertEqual(viewModel.formattedTime, "02:05")

        viewModel.timeLeft = 60 // 1:00
        XCTAssertEqual(viewModel.formattedTime, "01:00")

        viewModel.timeLeft = 5 // 0:05
        XCTAssertEqual(viewModel.formattedTime, "00:05")

        viewModel.timeLeft = 0 // 0:00
        XCTAssertEqual(viewModel.formattedTime, "00:00")
    }

    // MARK: - Status Text Tests

    func testStatusText() throws {
        // Initial state
        XCTAssertEqual(viewModel.statusText, "Drag to set time")

        // Running state
        viewModel.isRunning = true
        XCTAssertEqual(viewModel.statusText, "Running")

        // Finished state
        viewModel.isRunning = false
        viewModel.timeLeft = 0
        XCTAssertEqual(viewModel.statusText, "Finished")

        // Back to initial state
        viewModel.timeLeft = 300
        XCTAssertEqual(viewModel.statusText, "Drag to set time")
    }

    // MARK: - Timer Control Tests

    func testToggleTimer() throws {
        XCTAssertFalse(viewModel.isRunning)

        // Start timer
        viewModel.toggleTimer()
        XCTAssertTrue(viewModel.isRunning)

        // Stop timer
        viewModel.toggleTimer()
        XCTAssertFalse(viewModel.isRunning)
    }

    func testResetTimer() throws {
        // Set custom time and start timer
        viewModel.setTime(fromProgress: 0.5) // 30 minutes
        viewModel.toggleTimer()

        // Simulate some time passing
        viewModel.timeLeft = 1500 // 25 minutes remaining

        // Reset timer
        viewModel.resetTimer()

        XCTAssertFalse(viewModel.isRunning)
        XCTAssertEqual(viewModel.timeLeft, viewModel.totalSeconds) // Should restore to total time
    }

    // MARK: - Notification Preference Tests

    func testToggleFlash() throws {
        XCTAssertFalse(viewModel.flashEnabled)

        viewModel.toggleFlash()
        XCTAssertTrue(viewModel.flashEnabled)

        viewModel.toggleFlash()
        XCTAssertFalse(viewModel.flashEnabled)
    }

    func testToggleVibration() throws {
        XCTAssertTrue(viewModel.vibrationEnabled) // Default is true

        viewModel.toggleVibration()
        XCTAssertFalse(viewModel.vibrationEnabled)

        viewModel.toggleVibration()
        XCTAssertTrue(viewModel.vibrationEnabled)
    }

    func testToggleSound() throws {
        XCTAssertFalse(viewModel.soundEnabled)

        viewModel.toggleSound()
        XCTAssertTrue(viewModel.soundEnabled)

        viewModel.toggleSound()
        XCTAssertFalse(viewModel.soundEnabled)
    }

    func testToggleDoNotDisturb() throws {
        XCTAssertFalse(viewModel.doNotDisturbEnabled)

        viewModel.toggleDoNotDisturb()
        XCTAssertTrue(viewModel.doNotDisturbEnabled)

        viewModel.toggleDoNotDisturb()
        XCTAssertFalse(viewModel.doNotDisturbEnabled)
    }

    // MARK: - UserDefaults Persistence Tests

    func testUserPreferencesPersistence() throws {
        // Set preferences
        viewModel.toggleFlash() // true
        viewModel.toggleVibration() // false (was true)
        viewModel.toggleSound() // true
        viewModel.toggleDoNotDisturb() // true

        // Create new instance to test loading
        let newViewModel = TimerViewModel()

        XCTAssertTrue(newViewModel.flashEnabled)
        XCTAssertFalse(newViewModel.vibrationEnabled)
        XCTAssertTrue(newViewModel.soundEnabled)
        XCTAssertTrue(newViewModel.doNotDisturbEnabled)
    }

    // MARK: - State Observation Tests

    func testPublishedPropertiesUpdate() throws {
        let expectation = XCTestExpectation(description: "Properties should publish changes")
        var receivedUpdates = 0

        viewModel.$minutes
            .dropFirst() // Skip initial value
            .sink { _ in
                receivedUpdates += 1
                if receivedUpdates >= 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Trigger change
        viewModel.setTime(fromProgress: 0.75)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThanOrEqual(receivedUpdates, 1)
    }

    // MARK: - Edge Case Tests

    func testZeroProgressHandling() throws {
        // Test that zero total seconds doesn't cause division by zero
        viewModel.totalSeconds = 0
        XCTAssertEqual(viewModel.progress, 1.0) // Should default to 1.0
    }

    func testNegativeTimeLeft() throws {
        // This shouldn't happen in normal operation, but test defensive handling
        viewModel.timeLeft = -10
        // The formatted time might show negative values, which is acceptable
        // Just verify it doesn't crash and produces a valid string
        let formattedTime = viewModel.formattedTime
        XCTAssertNotNil(formattedTime)
        XCTAssertFalse(formattedTime.isEmpty)
    }

    // MARK: - Performance Tests

    func testFormattedTimePerformance() throws {
        measure {
            for _ in 0..<1000 {
                viewModel.timeLeft = Int.random(in: 0...3600)
                _ = viewModel.formattedTime
            }
        }
    }

    func testProgressCalculationPerformance() throws {
        measure {
            for _ in 0..<1000 {
                viewModel.timeLeft = Int.random(in: 0...3600)
                viewModel.totalSeconds = Int.random(in: 60...3600)
                _ = viewModel.progress
            }
        }
    }
}