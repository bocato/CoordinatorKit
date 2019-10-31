//
//  CoordinatorType.swift
//  CoordinatorKit
//
//  Created by Eduardo Sanches Bocato on 29/10/19.
//  Copyright © 2019 Bocato. All rights reserved.
//

import Foundation

/// An enum that defines an event to be passed on from
/// a child to it's parents over the responders Chain
public protocol CoordinatorEvent {}

/// Defines a delegate to pass the outputs in the responder chain
public protocol CoordinatorDelegate: AnyObject {
    
    /// Returns the child that just finished
    ///
    /// - Parameter child: the child that finished
    func childDidFinish(_ child: CoordinatorType)
}

/// Defines an coordinator for Controllers, or Coordinators
public protocol CoordinatorType: AnyObject {
    
    // MARK: - Properties
    
    /// Delegate in order to implement the responder chain like communication
    var coordinatorDelegate: CoordinatorDelegate? { get set }
    
    /// The parent coordinator, i.e., who started this one
    ///
    /// - Note: this guy should be weak
    var parent: CoordinatorType? { get set }
    
    /// The child coordinators, i.e., the sub-flows of integration
    var children: [CoordinatorType]? { get set }
    
    // MARK: - Methods
    
    /// Starts the integration flow and calls registerViewControllerBuilders() to do it
    func start()
}

public protocol EventReceivingCoordinator: CoordinatorType {
    
    // MARK: - Event Listeners
    
    /// Receives an output from it's parent
    ///
    /// - Parameters:
    ///   - event: the event that was sent
    ///   - child: the child that has sent the output
    ///
    /// - Example:
    ///    `func receiveEvent(_ event: CoordinatorEvent, from child: CoordinatorType) {
    ///        switch (event, child) {
    ///        case let (event as SomeCoordinator.Event, child as SomeCoordinator):
    ///            switch event {
    ///            case .someEvent:
    ///                // DO SOMETHING...
    ///                sendEventToParent(event) // Pass it on if needed, or not...
    ///            }
    ///        default: return
    ///        }
    ///    }`
    ///
    /// - Note: This needs to be implemented/overriden in order to intercept the inputs from the parent
    func receiveEvent(_ event: CoordinatorEvent, from child: CoordinatorType) throws
    
    /// Receives an event from the parent
    ///
    /// - Parameters:
    ///   - event: the event that was sent, it needs to conform with CoordinatorEvent
    ///
    /// - Example:
    ///    `func receiveEventFromParent(_ event: CoordinatorEvent) {
    ///        switch (event) {
    ///        case .someInput:
    ///        // DO SOMETHING
    ///        }
    ///    }`
    ///
    /// - Note: This needs to be implemented/overriden in order to intercept the inputs from the parent
    func receiveEventFromParent(_ event: CoordinatorEvent) throws
}

public extension CoordinatorType {
    
    // MARK: - Methods
    
    /// Used to have a callback and clean up everything flow related
    func finish() {
        coordinatorDelegate?.childDidFinish(self)
    }
    
    // MARK: - Child Operations
    
    /// Attachs a child integration flow
    ///
    /// - Parameters:
    ///   - child: the child to be attached
    ///   - completion: the completion handler to be called after attaching it
    /// - Returns: Void
    
    func attachChild(_ child: CoordinatorType, completion: (() -> ())? = nil) throws {
        if children?.first(where: { $0.identifier == child.identifier }) != nil {
            throw CoordinatorError.duplicatedChildFlow
        }
        child.parent = self
        children?.append(child)
        completion?()
    }
    
    /// Dettachs a child flow and finishs it
    ///
    /// - Parameters:
    ///   - childIdentifier: the identifier of the child to be removed
    ///   - completion: the completion handler to be called after detaching the child
    func detachChildWithIdentifier(_ childIdentifier: String, completion: (() -> ())? = nil) throws {
        guard let childToDettachIndex = children?.firstIndex(where: { $0.identifier == childIdentifier }) else {
            throw CoordinatorError.couldNotFindChildFlowWithIdentifier(childIdentifier)
        }
        children?[childToDettachIndex].finish()
        children?.remove(at: childToDettachIndex)
        completion?()
    }
    
    // MARK: - Events Senders
    
    /// Default implementation, in order to guarantee that the event is passed on
    ///
    /// - Parameter event: the desired event to be sent
    func sendEventToParent(_ event: CoordinatorEvent) throws {
        try parent?.receiveEvent(event, from: self)
    }
    
    /// Sends an event to a designated Child
    ///
    /// - Parameters:
    ///   - event: a desired event to be sent, it needs to conform with CoordinatorEvent
    ///   - childIdentifier: the child coordinator
    func sendEvent(_ event: CoordinatorEvent, toChildWithIdentifier childIdentifier: String) throws {
        guard let childToSendTheInput = children?.first(where: { $0.identifier == childIdentifier } ) else {
            throw CoordinatorError.couldNotFindChildFlowWithIdentifier(childIdentifier)
        }
        try childToSendTheInput.receiveEventFromParent(event)
    }
    
    // MARK: - Event Receivers
    
    /// Default implementation, so the user don't have to implement it unless it is needed.
    /// This needs to be overriden in order to intercept the events on the parents
    ///
    /// - Parameters:
    ///   - event: the event that was sent
    ///   - child: the child that has sent the output
    ///
    /// - Example:
    ///    `func receiveEvent(_ event: CoordinatorEvent, from child: CoordinatorType) {
    ///        switch (event, child) {
    ///        case let (event as SomeCoordinator.Event, child as SomeCoordinator):
    ///            switch event {
    ///            case .someEvent:
    ///                // DO SOMETHING...
    ///                sendEventToParent(event) // Pass it on if needed, or not...
    ///            }
    ///        default: return
    ///        }
    ///    }`
    ///
    func receiveEvent(_ event: CoordinatorEvent, from child: CoordinatorType) throws {
        guard let eventReceiver = self as? EventReceivingCoordinator else {
            throw CoordinatorError.coordinatorIsNotAnEventReceiver(identifier)
        }
        try eventReceiver.receiveEvent(event, from: child)
    }
    
    /// Default implementation, so the user don't have to implement it unless it is needed.
    /// This needs to be overriden in order to intercept the outputs on the parents
    ///
    /// - Example:
    ///    `func receiveEventFromParent(_ event: CoordinatorEvent) {
    ///        switch (event) {
    ///        case .someInput:
    ///        // DO SOMETHING
    ///        }
    ///    }`
    ///
    func receiveEventFromParent(_ event: CoordinatorEvent) throws {
        guard let eventReceiver = self as? EventReceivingCoordinator else {
            throw CoordinatorError.coordinatorIsNotAnEventReceiver(identifier)
        }
        try eventReceiver.receiveEventFromParent(event)
    }
    
    // MARK: - Helpers
    
    /// NOTE: - This should be overriden in case you need to use dynamic identifiers.
    var identifier: String {
        return String(describing: type(of: self))
    }
    
}
