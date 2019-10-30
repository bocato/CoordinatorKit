//
//  CoordinatorType.swift
//  CoordinatorKit
//
//  Created by Eduardo Sanches Bocato on 29/10/19.
//  Copyright © 2019 Bocato. All rights reserved.
//

import Foundation

/// An enum that defines an output to be passed on from
/// a child to it's parents over the responders Chain
public protocol CoordinatorOutput {}

/// An enum that defines an input to be passed on from
/// the parent to it's childs
public protocol CoordinatorInput {}

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
    
    //
    // MARK: - Output Operations
    //
    
    /// Receives an output from it's parent
    ///
    /// - Parameters:
    ///   - child: the child that has sent the output
    ///   - output: the output that was sent, it needs to conform with CoordinatorOutput
    func receiveOutput(from child: CoordinatorType, output: CoordinatorOutput)
    
    //
    // MARK: - Input Operations
    //
    
    /// Receives an input from it's parent
    ///
    /// - Parameters:
    ///   - input: the output that was sent, it needs to conform with CoordinatorInput
    ///
    /// - Note: This needs to be overriden in order to intercept the inputs from the parent
    func receiveInput(_ input: CoordinatorInput)
    
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
    
    // MARK: - Output Operations
    
    /// Default implementation, in order to guarantee that the output is passed on
    ///
    /// - Parameter output: the desired output to be sent
    func sendOutputToParent(_ output: CoordinatorOutput) {
        parent?.receiveOutput(from: self, output: output)
    }
    
    /// Default implementation, in order to guarantee that the output is passed on.
    /// This needs to be overriden in order to intercept the outputs on the parents
    ///
    /// - Parameters:
    ///   - child: the child that has sent the output
    ///   - output: the output that was sent..
    ///
    /// - Example:
    ///    `func receiveOutput(from child: Coordinator, output: CoordinatorOutput) {
    ///        switch (child, output) {
    ///        case let (coordinator as SomeCoordinator, output as SomeCoordinator.Output):
    ///            switch output {
    ///            case .someOutput:
    ///                // DO SOMETHING...
    ///                sendOutputToParent(output) // Pass it on if needed, or not...
    ///            }
    ///        default: return
    ///        }
    ///    }`
    ///
    func receiveOutput(from child: CoordinatorType, output: CoordinatorOutput) {
        parent?.receiveOutput(from: self, output: output)
    }
    
    // MARK: - Input Operations
    
    /// Sends an input to a designated Child
    ///
    /// - Parameters:
    ///   - childIdentifier: the child coordinator
    ///   - input: a desired input object to be sent, it needs to conform with CoordinatorOutput
    func sendInputToChild(_ childIdentifier: String, input: CoordinatorInput) throws {
        guard let childToSendTheInput = children?.first(where: { $0.identifier == childIdentifier } ) else {
            throw CoordinatorError.couldNotFindChildFlowWithIdentifier(childIdentifier)
        }
        childToSendTheInput.receiveInput(input)
    }
    
    /// Broadcast a designated input to all coordinator children
    ///
    /// - Parameter input:
    func broadcastInputToAllChilds(input: CoordinatorInput) throws {
        children?.forEach { $0.receiveInput(input) }
    }
    
    /// Default implementation, in order to guarantee that the output is passed on.
    /// This needs to be overriden in order to intercept the outputs on the parents
    ///
    /// - Parameters:
    ///   - child: the child that has sent the output
    ///   - output: the output that was sent..
    ///
    /// - Example:
    ///    `override func receiveInput(_ input: CoordinatorInput) {
    ///        switch (input) {
    ///        case .someInput:
    ///        // DO SOMETHING
    ///        }
    ///    }`
    ///
    func receiveInput(_ input: CoordinatorInput) {
        debugPrint("\(input) was received from \(parent?.identifier ?? "nobody")")
    }
    
    // MARK: - Helpers
    
    var identifier: String {
        return String(describing: type(of: self))
    }
    
}
