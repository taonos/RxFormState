//
//  FieldState.swift
//  RxFormState
//
//  Created by Lance Zhu on 2016-07-07.
//  Copyright © 2016 Lance Zhu. All rights reserved.
//

import Foundation
import RxSwift
import ValidationNEL

public protocol FieldStateType {
    var name: String { get }
    var required: Bool { get }
    var errors: [ValidationError]? { get }
    var visited: Bool { get }
    var touched: Bool { get }
    var valid: Bool { get }
    var invalid: Bool { get }
    var dirty: Bool { get }
    var pristine: Bool { get }
    var isInitialValue: Bool { get }
    var isUserInput: Bool { get }
}

public struct FieldState<T: Equatable> : FieldStateType {
    
    public typealias ValidationRule = T -> ValidationNEL<T, ValidationError>
    
    public let name: String
    public let required: Bool
    public let value: FieldValue<T>
    public let validation: ValidationRule?
    public let errors: [ValidationError]?
    public let visited: Bool
    public let touched: Bool
    
    public var valid: Bool {
        return errors == nil ? true : false
    }
    
    public var invalid: Bool {
        return !valid
    }
    
    public var dirty: Bool {
        switch value {
        case .Initial(_):
            return false
        case .Input(_):
            return true
        }
    }
    
    public var pristine: Bool {
        return !dirty
    }
    
    public var validDirtyValue: T? {
        if valid && dirty {
            return value.currentValue
        }
        else {
            return nil
        }
    }
    
    public var isInitialValue: Bool {
        if case .Initial(_) = value {
            return true
        }
        else {
            return false
        }
    }
    
    public var isUserInput: Bool {
        return !isInitialValue
    }
    
    public var initialValue: T? {
        switch value {
        case let .Initial(i):
            return i
        default:
            return nil
        }
    }
    
    public var inputValue: T? {
        switch value {
        case let .Input(_, v):
            return v
        default:
            return nil
        }
    }
    
    public init(name: String, required: Bool, initialValue: T?, validation: ValidationRule?) {
        self.name = name
        self.required = required
        value = .Initial(initial: initialValue)
        self.validation = validation
        if let value = value.currentValue, validation = validation {
            self.errors = validation(value).failure
        }
        else {
            self.errors = nil
        }
        
        visited = false
        touched = false
    }
    
    private init(name: String, required: Bool, value: FieldValue<T>, validation: ValidationRule?, visited: Bool, touched: Bool) {
        self.name = name
        self.required = required
        self.value = value
        self.validation = validation
        if let value = value.currentValue, validation = validation {
            self.errors = validation(value).failure
        }
        else {
            self.errors = nil
        }
        
        self.visited = visited
        self.touched = touched
    }
    
    public func onChange(value: T) -> FieldState<T> {
        return FieldState<T>(
            name: name,
            required: self.required,
            value: self.value.onChange(value),
            validation: self.validation,
            visited: self.visited,
            touched: self.touched
        )
    }
    
    public func onFocus() -> FieldState<T> {
        if visited {
            return self
        }
        else {
            return FieldState<T>(
                name: name,
                required: self.required,
                value: value,
                validation: self.validation,
                visited: true,
                touched: self.touched
            )
        }
    }
    
    public func onBlur() -> FieldState<T> {
        if touched {
            return self
        }
        else {
            return FieldState<T>(
                name: name,
                required: self.required,
                value: value,
                validation: self.validation,
                visited: self.visited,
                touched: true
            )
        }
    }
}

public extension FieldState {
    public func formattedErrors(separator: String = "\n") -> String? {
        guard let e = errors where !e.isEmpty else {
            return nil
        }
        
        let message = e.map { $0.description }.joinWithSeparator(separator)
        
        return "\(name): \(message)"
    }
}

public enum FieldValue<T: Equatable> {
    case Initial(initial: T?)
    case Input(initial: T?, current: T)
    
    public func onChange(newValue: T) -> FieldValue<T> {
        switch self {
        case let .Initial(initial) where initial == newValue:
            return self
        case let .Initial(initial):
            return .Input(initial: initial, current: newValue)
        case let .Input(initial, _) where initial == newValue:
            return .Initial(initial: initial)
        case let .Input(initial, _):
            return .Input(initial: initial, current: newValue)
        }
    }
    
    public var initialValue: T? {
        switch self {
        case let .Initial(i):
            return i
        case let .Input(i, _):
            return i
        }
    }
    
    public var currentValue: T? {
        switch self {
        case .Initial(_):
            return nil
        case let .Input(_, v):
            return v
        }
    }
}
