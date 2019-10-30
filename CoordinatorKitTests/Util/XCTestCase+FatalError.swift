//
//  XCTestCase+FatalError.swift
//  CoordinatorKitTests
//
//  Created by Eduardo Sanches Bocato on 30/10/19.
//  Copyright © 2019 Bocato. All rights reserved.
//

import XCTest
@testable import CoordinatorKit

extension XCTestCase {
    
    /// Defines a way to create a `fatalError` expectation.
    /// - Parameter expectedMessage: The message to be shown when the expectation fails.
    /// - Parameter timeout: The expectation timeout.
    /// - Parameter testcase: The block of code that can throw a fatal error.
    func expectFatalError(
        expectedMessage: String,
        timeout: TimeInterval = 2.0,
        testcase: @escaping () -> Void
    ) {
        
        let expectation = self.expectation(description: "expectingFatalError")
        var assertionMessage: String? = nil
        FatalErrorUtil.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
            self.unreachable()
        }
        
        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)
        
        waitForExpectations(timeout: 2) { _ in
            XCTAssertEqual(assertionMessage, expectedMessage)
            FatalErrorUtil.restoreFatalError()
        }
        
    }
    
    private func unreachable() -> Never {
        repeat {
            RunLoop.current.run()
        } while (true)
    }
    
}
