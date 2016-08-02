//
//  ValidationNEL.swift
//  ValidationNEL
//
//  Created by Lance Zhu on 2016-07-07.
//  Copyright © 2016 Lance Zhu. All rights reserved.
//

import Foundation
import Swiftz

// swiftlint:disable variable_name_min_length

public enum ValidationNEL<T, E> {
    case Success(T)
    case Failure([E])
    
    /// Return `true` if this validation is success.
    public var isSuccess: Bool {
        switch self {
        case .Success(_):
            return true
        case .Failure(_):
            return false
        }
    }
    
    /// Return `true` if this validation is failure.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    public var success: T? {
        switch self {
        case let .Success(a):
            return a
        default:
            return nil
        }
    }
    
    public var failure: [E]? {
        switch self {
        case let .Failure(e):
            return e
        default:
            return nil
        }
    }
    
    /**
     Return the success value of this validation or the given default if failure.
     
     - parameter x: default value
     
     - returns: the success value or the default value
     */
    public func getOrElse(x: T) -> T {
        switch self {
        case let .Success(a):
            return a
        case .Failure(_):
            return x
        }
    }
}

extension ValidationNEL : Applicative {
    
    public typealias A = T
    public typealias B = Any
    public typealias FB = ValidationNEL<B, E>
    
    public typealias FAB = ValidationNEL<T -> B, E>
    
    public func map<B>(f: T -> B) -> ValidationNEL<B, E> {
        switch self {
        case let .Success(t):
            return .Success(f(t))
        case let .Failure(e):
            return .Failure(e)
        }
    }
    
    public func fmap<B>(f: T -> B) -> ValidationNEL<B, E> {
        return f <^> self
    }
    
    public static func pure(t: T) -> ValidationNEL<T, E> {
        return .Success(t)
    }
    
    public func ap(f: ValidationNEL<T -> B, E>) -> ValidationNEL<B, E> {
        return f <*> self
    }
    
}

extension ValidationNEL : Foldable {
    public func foldr(folder: A -> B -> B, _ initial: B) -> B {
        switch self {
        case let .Success(a):
            return folder(a)(initial)
        case .Failure(_):
            return initial
        }
    }
    
    public func foldl(folder: B -> A -> B, _ initial: B) -> B {
        switch self {
        case let .Success(a):
            return folder(initial)(a)
        case .Failure(_):
            return initial
        }
    }
    
    public func foldMap<M : Monoid>(f: A -> M) -> M {
        switch self {
        case let .Success(a):
            return f(a)
        case .Failure(_):
            return M.mempty
        }
    }
}

public func <^> <E, RA, RB>(f: RA -> RB, v: ValidationNEL<RA, E>) -> ValidationNEL<RB, E> {
    switch v {
    case let .Failure(e):
        return .Failure(e)
    case let .Success(t):
        return .Success(f(t))
    }
}

public func <*> <E, TA, TB>(f: ValidationNEL<TA -> TB, E>, v: ValidationNEL<TA, E>) -> ValidationNEL<TB, E> {
    switch (f, v) {
    case (let .Success(f), let .Success(t)):
        return .Success(f(t))
    case (.Success(_), let .Failure(e)):
        return .Failure(e)
    case (let .Failure(e), .Success(_)):
        return .Failure(e)
    case (let .Failure(e1), let .Failure(e2)):
        var errors = [E]()
        errors.appendContentsOf(e1)
        errors.appendContentsOf(e2)
        return .Failure(errors)
    }
}
