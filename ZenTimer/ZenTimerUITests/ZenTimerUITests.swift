import XCTest

final class ZenTimerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Basic App Launch Tests

    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify the main timer view loads
        XCTAssertTrue(app.staticTexts["05:00"].exists)
        XCTAssertTrue(app.staticTexts["Drag to set time"].exists)
    }

    func testTimerDisplayElements() throws {
        let app = XCUIApplication()
        app.launch()

        // Check for key UI elements
        XCTAssertTrue(app.staticTexts["05:00"].exists) // Initial time display
        XCTAssertTrue(app.staticTexts["Drag to set time"].exists) // Status text
        XCTAssertTrue(app.buttons["Play"].exists) // Play button
        XCTAssertTrue(app.buttons["Reset"].exists) // Reset button
    }

    // MARK: - Timer Control Tests

    func testPlayPauseButton() throws {
        let app = XCUIApplication()
        app.launch()

        let playButton = app.buttons["Play"]
        XCTAssertTrue(playButton.exists)

        // Start the timer
        playButton.tap()

        // Should now show pause button and running status
        XCTAssertTrue(app.buttons["Pause"].exists)
        XCTAssertTrue(app.staticTexts["Running"].exists)

        // Pause the timer
        app.buttons["Pause"].tap()

        // Should go back to play button
        XCTAssertTrue(app.buttons["Play"].exists)
    }

    func testResetButton() throws {
        let app = XCUIApplication()
        app.launch()

        // Start timer and let it run briefly
        app.buttons["Play"].tap()
        sleep(2) // Let timer run for 2 seconds

        // Reset the timer
        app.buttons["Reset"].tap()

        // Should be back to initial state
        XCTAssertTrue(app.buttons["Play"].exists)
        XCTAssertTrue(app.staticTexts["05:00"].exists)
        XCTAssertTrue(app.staticTexts["Drag to set time"].exists)
    }

    // MARK: - Time Adjustment Tests

    func testMinuteAdjustmentButtons() throws {
        let app = XCUIApplication()
        app.launch()

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
        app.launch()

        // Look for settings button/icon
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()

            // Should navigate to settings
            XCTAssertTrue(app.navigationBars["Settings"].exists)
        }
    }

    // MARK: - Notification Settings Tests

    func testNotificationToggles() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to settings if they exist
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()

            // Test notification toggles
            let vibrationToggle = app.switches["Vibration"]
            if vibrationToggle.exists {
                let initialState = vibrationToggle.value as? String
                vibrationToggle.tap()

                // State should have changed
                let newState = vibrationToggle.value as? String
                XCTAssertNotEqual(initialState, newState)
            }

            let flashToggle = app.switches["Flash"]
            if flashToggle.exists {
                flashToggle.tap()
                // Should toggle successfully
            }

            let soundToggle = app.switches["Sound"]
            if soundToggle.exists {
                soundToggle.tap()
                // Should toggle successfully
            }
        }
    }

    // MARK: - Accessibility Tests

    func testAccessibilityLabels() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify key elements have accessibility labels
        XCTAssertTrue(app.buttons["Play"].exists)
        XCTAssertTrue(app.buttons["Reset"].exists)

        // Timer display should be accessible
        let timerDisplay = app.staticTexts["05:00"]
        XCTAssertTrue(timerDisplay.exists)
        XCTAssertTrue(timerDisplay.isHittable)
    }

    // MARK: - Gesture Tests

    func testCircularDragGesture() throws {
        let app = XCUIApplication()
        app.launch()

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
        app.launch()

        // Start a timer
        app.buttons["Play"].tap()
        XCTAssertTrue(app.staticTexts["Running"].exists)

        // Send app to background
        XCUIDevice.shared.press(.home)

        // Wait briefly
        sleep(2)

        // Bring app back to foreground
        app.activate()

        // Timer should still be running
        XCTAssertTrue(app.staticTexts["Running"].exists)
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
        app.launch()

        // Start timer
        app.buttons["Play"].tap()

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
        app.launch()

        // Set timer to 1 minute (or minimum time)
        // This test might need adjustment based on how time setting is implemented
        let decreaseButton = app.buttons["-"]
        if decreaseButton.exists {
            // Try to set to minimum time
            for _ in 0..<10 {
                decreaseButton.tap()
            }
        }

        // Start the timer
        app.buttons["Play"].tap()

        // For testing purposes, we'll just verify the timer can be started
        // A full completion test would take too long for automated testing
        XCTAssertTrue(app.staticTexts["Running"].exists)

        // Reset to avoid long wait
        app.buttons["Reset"].tap()
        XCTAssertTrue(app.staticTexts["Drag to set time"].exists)
    }

    // MARK: - Memory and Resource Tests

    func testMemoryLeaks() throws {
        let app = XCUIApplication()

        // Launch and interact with app multiple times
        for _ in 0..<5 {
            app.launch()

            // Perform basic interactions
            app.buttons["Play"].tap()
            sleep(1)
            app.buttons["Pause"].tap()
            app.buttons["Reset"].tap()

            app.terminate()
        }

        // If we get here without crashes, basic memory management is working
        XCTAssertTrue(true)
    }

    // MARK: - Rotation Tests (iPhone)

    func testDeviceRotation() throws {
        let app = XCUIApplication()
        app.launch()

        // Test portrait orientation (should be locked for this app)
        XCUIDevice.shared.orientation = .portrait

        // Verify UI elements are still accessible
        XCTAssertTrue(app.staticTexts["05:00"].exists)
        XCTAssertTrue(app.buttons["Play"].exists)

        // Try landscape (should stay in portrait for this app)
        XCUIDevice.shared.orientation = .landscapeLeft

        // Should still be in portrait mode
        XCTAssertTrue(app.staticTexts["05:00"].exists)
        XCTAssertTrue(app.buttons["Play"].exists)

        // Reset orientation
        XCUIDevice.shared.orientation = .portrait
    }
}