//
//  CoordinatorError.swift
//  CoordinatorKit
//
//  Created by Eduardo Sanches Bocato on 29/10/19.
//  Copyright © 2019 Bocato. All rights reserved.
//

import Foundation
/**
 Errors that can be thrown by an Coordinator.
 */
public enum CoordinatorError: Error {
    
    // MARK: - Errors
    
    /// Signals that the developer is trying to attach a flow that is already in the stack
    case duplicatedChildFlow
    
    /// There is no child flow with the expected identifier
    case couldNotFindChildFlowWithIdentifier(String)
    
    /// The coordinator does not conform with `EventReceivingCoordinator` protocol
    case coordinatorIsNotAnEventReceiver(String)
    
}
extension CoordinatorError {
    
    /// Returns a localized description
    var localizedDescription: String {
        switch self {
        case .duplicatedChildFlow:
            return """
            Attempted to use append a flow that is already in running.
            """
        case .couldNotFindChildFlowWithIdentifier(let identifier):
            return """
            The expected flow (\(identifier)) is not on the stack/not running.
            """
        case let .coordinatorIsNotAnEventReceiver(coordinatorName):
            return """
            \(coordinatorName) does not conform with `EventReceivingCoordinator` protocol.
            """
        }
    }
    
}
