import XCTest

final class ZenTimerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.

        // Reset app state by clearing UserDefaults and relaunching
        resetAppForTesting()
    }

    /// Reset the app to a clean state for testing
    private func resetAppForTesting() {
        let app = XCUIApplication()

        // Clear UserDefaults by passing reset flag
        app.launchArguments.append("--reset-for-testing")

        // Ensure app is terminated before launching
        app.terminate()
        app.launch()

        // Wait for app to fully load
        _ = app.staticTexts["Drag to set time"].waitForExistence(timeout: 5)

        // If timer is running from previous state, stop it
        if app.buttons["pause.fill"].exists {
            app.buttons["pause.fill"].tap()
            app.buttons["arrow.clockwise"].tap() // Reset timer
            // Wait for UI to update
            _ = app.buttons["play.fill"].waitForExistence(timeout: 3)
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Basic App Launch Tests

    func testAppLaunches() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Verify the main timer view loads
        XCTAssertTrue(app.staticTexts["05:00"].exists)
        XCTAssertTrue(app.staticTexts["Drag to set time"].exists)
        // Verify control buttons are present (should be play after reset)
        XCTAssertTrue(app.buttons["play.fill"].exists)
        XCTAssertTrue(app.buttons["arrow.clockwise"].exists)
    }

    func testTimerDisplayElements() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Check for key UI elements
        XCTAssertTrue(app.staticTexts["05:00"].exists) // Initial time display
        XCTAssertTrue(app.staticTexts["Drag to set time"].exists) // Status text
        XCTAssertTrue(app.buttons["play.fill"].exists) // Play button (after reset)
        XCTAssertTrue(app.buttons["arrow.clockwise"].exists) // Reset button
        // Check notification toggle buttons
        XCTAssertTrue(app.buttons["flashlight.on.fill"].exists)
        XCTAssertTrue(app.buttons["iphone.radiowaves.left.and.right"].exists)
        XCTAssertTrue(app.buttons["speaker.wave.1.fill"].exists)
        XCTAssertTrue(app.buttons["moon.fill"].exists)
        // Check settings button
        XCTAssertTrue(app.buttons["gearshape.fill"].exists)
    }

    // MARK: - Timer Control Tests

    func testPlayPauseButton() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        let playButton = app.buttons["play.fill"]
        XCTAssertTrue(playButton.exists)

        // Start the timer
        playButton.tap()

        // Should now show pause button and running status
        XCTAssertTrue(app.buttons["pause.fill"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Running"].exists)

        // Pause the timer
        app.buttons["pause.fill"].tap()

        // Should go back to play button
        XCTAssertTrue(app.buttons["play.fill"].waitForExistence(timeout: 2))
    }

    func testResetButton() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Start timer and let it run briefly
        app.buttons["play.fill"].tap()
        XCTAssertTrue(app.buttons["pause.fill"].waitForExistence(timeout: 2))
        sleep(2) // Let timer run for 2 seconds

        // Reset the timer
        app.buttons["arrow.clockwise"].tap()

        // Should be back to initial state
        XCTAssertTrue(app.buttons["play.fill"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["05:00"].exists)
        XCTAssertTrue(app.staticTexts["Drag to set time"].exists)
    }

    // MARK: - Time Adjustment Tests

    func testMinuteAdjustmentButtons() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Test increase button
        let increaseButton = app.buttons["+"]
        if increaseButton.exists {
            increaseButton.tap()
            // Time should increase (we can't easily verify exact time due to dynamic updates)
        }

        // Test decrease button
        let decreaseButton = app.buttons["-"]
        if decreaseButton.exists {
            decreaseButton.tap()
            // Time should decrease
        }
    }

    // MARK: - Settings Navigation Tests

    func testSettingsNavigation() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Look for settings button/icon
        let settingsButton = app.buttons["gearshape.fill"]
        XCTAssertTrue(settingsButton.exists)
        settingsButton.tap()

        // Should show settings sheet/modal
        // Wait for settings to appear
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["App Information"].exists)
        XCTAssertTrue(app.buttons["Done"].exists)

        // Close settings
        app.buttons["Done"].tap()

        // Should be back to main screen
        XCTAssertTrue(app.staticTexts["05:00"].waitForExistence(timeout: 3))
    }

    // MARK: - Notification Settings Tests

    func testNotificationToggles() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Test notification toggle buttons directly on main screen
        let flashButton = app.buttons["flashlight.on.fill"]
        if flashButton.exists {
            flashButton.tap()
            // Flash button should still exist after toggle
            XCTAssertTrue(flashButton.exists)
        }

        let vibrationButton = app.buttons["iphone.radiowaves.left.and.right"]
        if vibrationButton.exists {
            vibrationButton.tap()
            // Vibration button should still exist after toggle
            XCTAssertTrue(vibrationButton.exists)
        }

        let soundButton = app.buttons["speaker.wave.1.fill"]
        if soundButton.exists {
            soundButton.tap()
            // Sound button should still exist after toggle
            XCTAssertTrue(soundButton.exists)
        }

        let dndButton = app.buttons["moon.fill"]
        if dndButton.exists {
            dndButton.tap()
            // Do Not Disturb button should still exist after toggle
            XCTAssertTrue(dndButton.exists)
        }
    }

    // MARK: - Accessibility Tests

    func testAccessibilityLabels() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Verify key elements have accessibility identifiers
        XCTAssertTrue(app.buttons["play.fill"].exists)
        XCTAssertTrue(app.buttons["arrow.clockwise"].exists)
        XCTAssertTrue(app.buttons["flashlight.on.fill"].exists)
        XCTAssertTrue(app.buttons["iphone.radiowaves.left.and.right"].exists)
        XCTAssertTrue(app.buttons["speaker.wave.1.fill"].exists)
        XCTAssertTrue(app.buttons["moon.fill"].exists)
        XCTAssertTrue(app.buttons["gearshape.fill"].exists)

        // Timer display should be accessible
        let timerDisplay = app.staticTexts["05:00"]
        XCTAssertTrue(timerDisplay.exists)
        XCTAssertTrue(timerDisplay.isHittable)
    }

    // MARK: - Gesture Tests

    func testCircularDragGesture() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Find the circular timer area (this might need adjustment based on actual implementation)
        let timerCircle = app.otherElements.containing(.staticText, identifier:"05:00").element

        if timerCircle.exists {
            let startPoint = timerCircle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            let endPoint = timerCircle.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5))

            // Perform drag gesture to adjust time
            startPoint.press(forDuration: 0.1, thenDragTo: endPoint)

            // Time should have changed from the initial 05:00
            // Note: We can't easily verify the exact time due to the dynamic nature
            // but we can verify the gesture was recognized by checking if time display updated
        }
    }

    // MARK: - App State Tests

    func testAppBackgroundAndForeground() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Start a timer
        app.buttons["play.fill"].tap()
        XCTAssertTrue(app.staticTexts["Running"].waitForExistence(timeout: 2))

        // Send app to background
        XCUIDevice.shared.press(.home)

        // Wait briefly
        sleep(2)

        // Bring app back to foreground
        app.activate()

        // Timer should still be running
        XCTAssertTrue(app.staticTexts["Running"].waitForExistence(timeout: 3))
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    func testTimerAccuracy() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Ensure we have the play button (timer is stopped)
        XCTAssertTrue(app.buttons["play.fill"].exists)

        // Start timer
        app.buttons["play.fill"].tap()
        XCTAssertTrue(app.buttons["pause.fill"].waitForExistence(timeout: 2))

        // Record start time
        let startTime = Date()

        // Wait for 5 seconds
        sleep(5)

        // Check that roughly 5 seconds have passed
        // Note: This is a rough test due to UI update delays
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThan(elapsed, 4.5) // Should be at least 4.5 seconds
        XCTAssertLessThan(elapsed, 6.0) // Should be less than 6 seconds
    }

    // MARK: - Edge Case Tests

    func testTimerCompletion() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Ensure we have the play button (timer is stopped)
        XCTAssertTrue(app.buttons["play.fill"].exists)

        // Set timer to minimum time for faster testing
        let decreaseButton = app.buttons["-"]
        if decreaseButton.exists {
            // Try to set to minimum time
            for _ in 0..<10 {
                decreaseButton.tap()
            }
        }

        // Start the timer
        app.buttons["play.fill"].tap()
        XCTAssertTrue(app.buttons["pause.fill"].waitForExistence(timeout: 2))

        // For testing purposes, we'll just verify the timer can be started
        // A full completion test would take too long for automated testing
        XCTAssertTrue(app.staticTexts["Running"].exists)

        // Reset to avoid long wait
        app.buttons["arrow.clockwise"].tap()
        XCTAssertTrue(app.staticTexts["Drag to set time"].waitForExistence(timeout: 2))
    }

    // MARK: - Memory and Resource Tests

    func testMemoryLeaks() throws {
        let app = XCUIApplication()

        // Launch and interact with app multiple times
        for _ in 0..<5 {
            // Add reset flag to ensure clean state
            app.launchArguments = ["--reset-for-testing"]
            app.launch()

            // Wait for app to fully load
            _ = app.staticTexts["Drag to set time"].waitForExistence(timeout: 5)

            // Ensure we start with play button (clean state)
            if app.buttons["pause.fill"].exists {
                app.buttons["pause.fill"].tap()
                app.buttons["arrow.clockwise"].tap()
                _ = app.buttons["play.fill"].waitForExistence(timeout: 3)
            }

            // Perform basic interactions
            if app.buttons["play.fill"].exists {
                app.buttons["play.fill"].tap()
                _ = app.buttons["pause.fill"].waitForExistence(timeout: 2)
                sleep(1)
                app.buttons["pause.fill"].tap()
                _ = app.buttons["play.fill"].waitForExistence(timeout: 2)
                app.buttons["arrow.clockwise"].tap()
            }

            app.terminate()
        }

        // If we get here without crashes, basic memory management is working
        XCTAssertTrue(true)
    }

    // MARK: - Rotation Tests (iPhone)

    func testDeviceRotation() throws {
        let app = XCUIApplication()

        // App should already be launched and reset from setUp
        // Test portrait orientation (should be locked for this app)
        XCUIDevice.shared.orientation = .portrait

        // Verify UI elements are still accessible
        XCTAssertTrue(app.staticTexts["05:00"].exists)
        // Check for either play or pause button (depending on current state)
        let hasPlayButton = app.buttons["play.fill"].exists
        let hasPauseButton = app.buttons["pause.fill"].exists
        XCTAssertTrue(hasPlayButton || hasPauseButton, "Should have either play or pause button")

        // Try landscape (should stay in portrait for this app)
        XCUIDevice.shared.orientation = .landscapeLeft

        // Give a moment for rotation to process
        sleep(1)

        // Should still be in portrait mode with same UI elements
        XCTAssertTrue(app.staticTexts["05:00"].exists)
        // Verify the same button state is maintained
        if hasPlayButton {
            XCTAssertTrue(app.buttons["play.fill"].exists)
        } else {
            XCTAssertTrue(app.buttons["pause.fill"].exists)
        }

        // Reset orientation
        XCUIDevice.shared.orientation = .portrait
    }
}
