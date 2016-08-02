//
//  ObservableType+Optional.swift
//  RxFormState
//
//  Created by Lance Zhu on 2016-07-07.
//  Copyright © 2016 Lance Zhu. All rights reserved.
//

import Foundation
import RxSwift

// Originially from here: https://github.com/artsy/eidolon/blob/24e36a69bbafb4ef6dbe4d98b575ceb4e1d8345f/Kiosk/Observable%2BOperators.swift#L30-L40
// Credit to Artsy and @ashfurrow

public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    /// Cast `Optional<Wrapped>` to `Wrapped?`
    public var value: Wrapped? {
        return self
    }
}

public extension ObservableType where E: OptionalType {
    /**
     Unwraps and filters out `nil` elements.
     - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.
     */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func filterNil() -> Observable<E.Wrapped> {
        return self.flatMap { element -> Observable<E.Wrapped> in
            guard let value = element.value else {
                return Observable<E.Wrapped>.empty()
            }
            return Observable<E.Wrapped>.just(value)
        }
    }
}
