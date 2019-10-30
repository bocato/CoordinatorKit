//
//  CommonCoordinatorTypes.swift
//  CoordinatorKit
//
//  Created by Eduardo Sanches Bocato on 29/10/19.
//  Copyright © 2019 Bocato. All rights reserved.
//

import UIKit

// Represents coordinators that will have a navigation controller encapsulated flow
public protocol NavigationCoordinatorType: CoordinatorType {
    // Initializes with the coordinator with navigation controller to take care of the flows of navigation
    init(_ navigationController: UINavigationController)
}

public protocol ApplicationCoordinatorType: CoordinatorType { // This one doesn't have a parentFlow
    /// - Note: Create the initialization omiting the parent, since there is
    ///         only one aplication coordinator, being that, it won't have a parent.
}
public extension ApplicationCoordinatorType {
    func finish() { fatalError("Application should never call `finish`.") }
}
