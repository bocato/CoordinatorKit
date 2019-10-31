//
//  CoordinatorTypeTests.swift
//  CoordinatorKitTests
//
//  Created by Eduardo Sanches Bocato on 30/10/19.
//  Copyright © 2019 Bocato. All rights reserved.
//

import XCTest
@testable import CoordinatorKit

final class CoordinatorTypeTests: XCTestCase {
    
    func test_finish_shouldTrigerDelegate() {
        // Given
        let delegateSpy = CoordinatorDelegateSpy()
        let sut: CoordinatorType = CoordinatorTypeMock()
        sut.coordinatorDelegate = delegateSpy
        
        // When
        sut.finish()
        
        // Then
        XCTAssertTrue(delegateSpy.childDidFinishCalled, "`childDidFinish` should have been called.")
        XCTAssertEqual(sut.identifier, delegateSpy.childPassed?.identifier, "Expected \(sut.identifier), but got \(String(describing: delegateSpy.childPassed?.identifier)).")
    }
    
    func test_attachChild_shouldSucceed_forNewChild() {
        // Given
        let sut: CoordinatorType = CoordinatorTypeMock()
        let child = OtherCoordinatorTypeMock()
        
        // When
        try? sut.attachChild(child)
        
        // Then
        XCTAssertEqual(sut.identifier, child.parent?.identifier, "Expected \(sut.identifier) to be the parent coordinator, but got \(String(describing: child.parent?.identifier)).")
        XCTAssertEqual(sut.children?.count, 1, "Expected `children.count` to be `1`.")
    }
    
    func test_attachChild_shouldFailt_forDuplicatedChildren() {
        // Given
        let sut: CoordinatorType = CoordinatorTypeMock()
        let child = OtherCoordinatorTypeMock()
        try? sut.attachChild(child)
        
        // When
        var errorThrown: CoordinatorError?
        do {
            try sut.attachChild(child)
            XCTFail("Expected throw error, but it didn't happen.")
        } catch {
            guard let coordinatorError = error as? CoordinatorError else {
                XCTFail("Expected a `CoordinatorError`.")
                return
            }
            errorThrown = coordinatorError
        }
        
        // Then
        XCTAssertNotNil(errorThrown, "Expected an error, but got nil.")
        guard case .duplicatedChildFlow = errorThrown else {
            XCTFail("Expected `duplicatedChildFlow` error, but got \(String(describing: errorThrown)).")
            return
        }
    }
    
    func test_dettachChild_shouldSucceed_forValidChild() {
        // Given
        let sut: CoordinatorType = CoordinatorTypeMock()
        
        let child = OtherCoordinatorTypeMock()
        let childDelegateSpy = CoordinatorDelegateSpy()
        child.coordinatorDelegate = childDelegateSpy

        try? sut.attachChild(child)
        XCTAssertEqual(sut.children?.count, 1, "Expected `children.count` to be `1`.")
        
        // When
        try? sut.detachChildWithIdentifier(child.identifier)
        
        // Then
        XCTAssertTrue(childDelegateSpy.childDidFinishCalled, "`childDidFinish` should have been called.")
        XCTAssertEqual(sut.children?.count, 0, "Expected `children.count` to be `0`.")
    }
    
    func test_dettachChild_shouldFail_forInvalidChildIdentifier() {
        // Given
        let sut: CoordinatorType = CoordinatorTypeMock()
        
        // When
        var errorThrown: CoordinatorError?
        do {
            try sut.detachChildWithIdentifier("SomeIdentifier")
            XCTFail("Expected throw error, but it didn't happen.")
        } catch {
            guard let coordinatorError = error as? CoordinatorError else {
                XCTFail("Expected a `CoordinatorError`.")
                return
            }
            errorThrown = coordinatorError
        }
        
        // Then
        XCTAssertNotNil(errorThrown, "Expected an error, but got nil.")
        guard case .couldNotFindChildFlowWithIdentifier = errorThrown else {
            XCTFail("Expected `duplicatedChildFlow` error, but got \(String(describing: errorThrown)).")
            return
        }
    }
    
    func test_whenSendEventToParentIsCalled_parentShouldReceiveTheExpectedEvent() {
        // Given
        let parent = CoordinatorSpy()
        let child = CoordinatorTypeMock()
        try? parent.attachChild(child)

        let event = CoordinatorEventMock()

        // When
        do {
            try child.sendEventToParent(event)
        } catch {
            XCTFail("`sendEventToParent` failed!")
        }

        // Then
        XCTAssertTrue(parent.receiveEventFromChildCalled, "`receiveEvent(:from:)` should have been called on the parent.")
        XCTAssertTrue(parent.eventPassedToReceiveEventFromChild is CoordinatorEventMock, "Expected `CoordinatorEventMock`, but got \(String(describing: parent.eventPassedToReceiveEventFromChild)).")

    }

    func test_whenSendEventToParentIsCalled_andReceiverIsNotEventReceivingCoordinator_itShouldThrowTheExpecteError() {
        // Given
        let parent = CoordinatorTypeMock()
        let child = OtherCoordinatorTypeMock()
        try? parent.attachChild(child)

        let event = CoordinatorEventMock()

        // When
        var errorThrown: CoordinatorError?
        do {
            try child.sendEventToParent(event)
            XCTFail("Expected throw error, but it didn't happen.")
        } catch {
            guard let coordinatorError = error as? CoordinatorError else {
                XCTFail("Expected a `CoordinatorError`.")
                return
            }
            errorThrown = coordinatorError
        }
        
        // Then
        XCTAssertNotNil(errorThrown, "Expected an error, but got nil.")
        guard case .coordinatorIsNotAnEventReceiver = errorThrown else {
            XCTFail("Expected `coordinatorIsNotAnEventReceiver` error, but got \(String(describing: errorThrown)).")
            return
        }
    }
    
    func test_whenSendEventToChild_isSendToAnInvalidChildIdentifier_itShouldThrowTheExpectedError() {
        // Given
        let parent = CoordinatorTypeMock()
        let child = CoordinatorSpy()
        try? parent.attachChild(child)

        let event = CoordinatorEventMock()
        let invalidChildIdentifier = "InvalidIdentifier"

        // When
        var errorThrown: CoordinatorError?
        do {
            try parent.sendEvent(event, toChildWithIdentifier: invalidChildIdentifier)
            XCTFail("Expected throw error, but it didn't happen.")
        } catch {
            guard let coordinatorError = error as? CoordinatorError else {
                XCTFail("Expected a `CoordinatorError`.")
                return
            }
            errorThrown = coordinatorError
        }
        
        // Then
        XCTAssertNotNil(errorThrown, "Expected an error, but got nil.")
        guard case let .couldNotFindChildFlowWithIdentifier(identifier) = errorThrown else {
            XCTFail("Expected `coordinatorIsNotAnEventReceiver` error, but got \(String(describing: errorThrown)).")
            return
        }
        XCTAssertEqual(invalidChildIdentifier, identifier, "Expected \(invalidChildIdentifier), but got \(identifier).")

    }
    
    func test_whenSendEventToChild_childShouldReceiveTheExpectedEvent() {
        // Given
        let parent = CoordinatorTypeMock()
        let child = CoordinatorSpy()
        try? parent.attachChild(child)

        let event = CoordinatorEventMock()

        // When
        do {
            try parent.sendEvent(event, toChildWithIdentifier: child.identifier)
        } catch {
            XCTFail("`sendEvent(:toChildWithIdentifier:)` failed!")
        }

        // Then
        XCTAssertTrue(child.receiveEventFromParentCalled, "`receiveEvent()` should have been called on the child.")
        XCTAssertTrue(child.eventPassedToReceiveEventFromParent is CoordinatorEventMock, "Expected `CoordinatorEventMock`, but got \(String(describing: child.eventPassedToReceiveEventFromParent)).")

    }
    
    func test_whenSendEventToChild_andReceiverIsNotEventReceivingCoordinator_itShouldThrowTheExpecteError() {
        // Given
        let parent = CoordinatorTypeMock()
        let child = CoordinatorTypeMock()
        try? parent.attachChild(child)

        let event = CoordinatorEventMock()

        // When
        var errorThrown: CoordinatorError?
        do {
            try parent.sendEvent(event, toChildWithIdentifier: child.identifier)
            XCTFail("Expected throw error, but it didn't happen.")
        } catch {
            guard let coordinatorError = error as? CoordinatorError else {
                XCTFail("Expected a `CoordinatorError`.")
                return
            }
            errorThrown = coordinatorError
        }
        
        // Then
        XCTAssertNotNil(errorThrown, "Expected an error, but got nil.")
        guard case .coordinatorIsNotAnEventReceiver = errorThrown else {
            XCTFail("Expected `coordinatorIsNotAnEventReceiver` error, but got \(String(describing: errorThrown)).")
            return
        }
    }
    
}

// MARK: - Testing Helpers

private final class CoordinatorTypeMock: CoordinatorType {
    var coordinatorDelegate: CoordinatorDelegate?
    var parent: CoordinatorType?
    var children: [CoordinatorType]? = []
    func start() {}
}

private final class OtherCoordinatorTypeMock: CoordinatorType {
    var coordinatorDelegate: CoordinatorDelegate?
    var parent: CoordinatorType?
    var children: [CoordinatorType]? = []
    func start() {}
}

private final class CoordinatorDelegateSpy: CoordinatorDelegate {
    
    private(set) var childDidFinishCalled = false
    private(set) var childPassed: CoordinatorType?
    func childDidFinish(_ child: CoordinatorType) {
        childDidFinishCalled = true
        childPassed = child
    }
    
}

private final class CoordinatorSpy: CoordinatorType, EventReceivingCoordinator {

    var coordinatorDelegate: CoordinatorDelegate?
    var parent: CoordinatorType?
    var children: [CoordinatorType]? = []

    private(set) var startCalled = false
    func start() {
        startCalled = true
    }

    private(set) var receiveEventFromChildCalled = false
    private(set) var eventPassedToReceiveEventFromChild: CoordinatorEvent?
    private(set) var childPassed: CoordinatorType?
    func receiveEvent(_ event: CoordinatorEvent, from child: CoordinatorType) {
        receiveEventFromChildCalled = true
        eventPassedToReceiveEventFromChild = event
        childPassed = child
    }
    
    private(set) var receiveEventFromParentCalled = false
    private(set) var eventPassedToReceiveEventFromParent: CoordinatorEvent?
    func receiveEventFromParent(_ event: CoordinatorEvent) throws {
        receiveEventFromParentCalled = true
        eventPassedToReceiveEventFromParent = event
    }
    
}

private struct CoordinatorEventMock: CoordinatorEvent {}
