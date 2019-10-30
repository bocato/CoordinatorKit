//
//  CoordinatorErrorTests.swift
//  CoordinatorKitTests
//
//  Created by Eduardo Sanches Bocato on 30/10/19.
//  Copyright © 2019 Bocato. All rights reserved.
//

import XCTest
@testable import CoordinatorKit

final class CoordinatorErrorTests: XCTestCase {
    
    func test_duplicatedChildFlow_localizedDescription() {
        // Given
        let expectedLocalizedDescription = "Attempted to use append a flow that is already in running."
        let error: CoordinatorError = .duplicatedChildFlow
        
        // When / Then
        XCTAssertEqual(expectedLocalizedDescription, error.localizedDescription)
    }
    
    func test_couldNotFindChildFlowWithIdentifier_localizedDescription() {
        // Given
        let identifier = "SomeIdentifier"
        let expectedLocalizedDescription = "The expected flow (\(identifier)) is not on the stack/not running."
        let error: CoordinatorError = .couldNotFindChildFlowWithIdentifier(identifier)
        
        // When / Then
        XCTAssertEqual(expectedLocalizedDescription, error.localizedDescription)
    }
    
//    func test_() {
//        // Given
//        // When
//        // Then
//    }
    
}
