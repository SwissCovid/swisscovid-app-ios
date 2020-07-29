/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

/// A view that can be reused.
protocol NSReusableView: AnyObject {
    /// The reuse identifier of a view.
    ///
    /// The default implementation returns the name of the class.
    static var reuseIdentifier: String { get }
}

extension NSReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: - Adopting ReusableView

extension UITableViewCell: NSReusableView {}

extension UITableViewHeaderFooterView: NSReusableView {}

extension UICollectionViewCell: NSReusableView {}

// MARK: - Registering and Reusing In Table Views

extension UITableView {
    func register<T: UITableViewCell>(_ cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }

    func register<T: UITableViewHeaderFooterView>(_ viewType: T.Type) {
        register(viewType, forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Could not dequeue view with identifier: \(T.reuseIdentifier)")
        }
        return view
    }
}

// MARK: - Registering and Reusing In Collection Views

extension UICollectionView {
    /// Register a collection view cell for reuse.
    ///
    /// - Parameter cellType: The class of the collection view cell to register.
    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    /// Dequeue a reusable collection view cell for displaying at a given index path.
    ///
    /// - Parameter indexPath: The index path where the cell will be placed.
    /// - Returns: A dequeued reusable cell.
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }

    /// Register a supplementary view for reuse.
    ///
    /// - Parameters:
    ///   - viewType: The class of the view to register.
    ///   - kind: The kind of supplementary view to create.
    func register<T: UIView>(_: T.Type, forSupplementaryViewOfKind kind: String) where T: NSReusableView {
        register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    /// Dequeue a reusable supplementary view.
    ///
    /// - Parameters:
    ///   - kind: The kind of supplementary view to dequeue.
    ///   - indexPath: The index path where the view will be placed.
    /// - Returns: A dequeued reusable supplementary view.
    func dequeueReusableSupplementaryView<T: UIView>(of kind: String, for indexPath: IndexPath) -> T where T: NSReusableView {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue view with identifier: \(T.reuseIdentifier)")
        }
        return view
    }
}
