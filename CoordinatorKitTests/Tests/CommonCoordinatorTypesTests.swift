//
//  CoordinatorTypesTest.swift
//  CoordinatorKitTests
//
//  Created by Eduardo Sanches Bocato on 30/10/19.
//  Copyright © 2019 Bocato. All rights reserved.
//

import XCTest
@testable import CoordinatorKit

final class CoordinatorTypesTest: XCTestCase {

    func test_applicationCoordinatorType_shouldThrowFatalError_onFinish() {
        // Given
        let applicationCoordinator: ApplicationCoordinatorType = ApplicationCoordinatorTypeMock()
        
        // When / Then
        expectFatalError(expectedMessage: "Application should never call `finish`.") {
            applicationCoordinator.finish()
        }
    }
    
}

// MARK: - Testing Helpers
private final class ApplicationCoordinatorTypeMock: ApplicationCoordinatorType {
    var coordinatorDelegate: CoordinatorDelegate?
    var parent: CoordinatorType?
    var children: [CoordinatorType]?
    
    func start() {}
    func receiveEvent(_ event: CoordinatorEvent, from child: CoordinatorType) throws {}
    func receiveEventFromParent(_ event: CoordinatorEvent) throws {}
}
