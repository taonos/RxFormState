//
//  FieldFactory.swift
//  RxFormState
//
//  Created by Lance Zhu on 2016-07-07.
//  Copyright © 2016 Lance Zhu. All rights reserved.
//

import Foundation
import RxSwift
import ValidationNEL

public protocol FieldFactoryType {
    var name: String { get }
    var contraOutput: Observable<FieldStateType> { get }
}

public struct FieldFactory<T: Equatable> : FieldFactoryType {
    
    public typealias ValidationRule = T -> ValidationNEL<T, ValidationError>
    
    public let name: String
    public let output: Observable<FieldState<T>>
    public var contraOutput: Observable<FieldStateType> {
        return output.map { $0 as FieldStateType }
    }
    
    public init<S: RawRepresentable where S.RawValue == String>(name: S, required: Bool = false, initialValue: T? = nil, input: Observable<T>, validation: ValidationRule? = nil) {
        self.init(name: name.rawValue, required: required, initial: Observable.just(initialValue), input: input, validation: validation)
    }
    
    public init(name: String, required: Bool = false, initialValue: T? = nil, input: Observable<T>, validation: ValidationRule? = nil) {
        self.init(name: name, required: required, initial: Observable.just(initialValue), input: input, validation: validation)
    }
    
    public init<S: RawRepresentable where S.RawValue == String>(name: S, required: Bool = false, initial: Observable<T?> = Observable.empty(), input: Observable<T>, validation: ValidationRule? = nil) {
        self.init(name: name.rawValue, required: required, initial: initial, input: input, validation: validation)
    }
    
    public init(name: String, required: Bool = false, initial: Observable<T?> = Observable.empty(), input: Observable<T>, validation: ValidationRule? = nil) {
        
        self.name = name
        
        output = initial
            .filterNil()
            .concat(input)
            .scan(nil) { acc, current -> FieldState<T>? in
                guard let acc = acc else {
                    return FieldState(name: name, required: required, initialValue: current, validation: validation)
                }
                
                return acc.onChange(current)
            }
            .filterNil()
            .shareReplay(1)
    }
    
}
