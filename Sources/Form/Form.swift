//
//  Form.swift
//  RxFormState
//
//  Created by Lance Zhu on 2016-07-07.
//  Copyright © 2016 Lance Zhu. All rights reserved.
//

import Foundation
import RxSwift

enum FormStatus {
    case Loading
    case Awaiting
    case Error
    case Submitting
    case Submitted
    case Fatal
}

public struct Form {
    
    let fields: [String : Observable<FieldStateType>]
    let status: Observable<FormStatus>
    let submissionEnabled: Observable<Bool>
    
    init(
        initialLoadTrigger: Observable<Void> = Observable.just(()),
        submitTrigger: Observable<Void>,
        submitHandler: [String : FieldStateType] -> Observable<FormStatus>,
        formField: FieldFactoryType...
        ) {
        self.init(initialLoadTrigger: initialLoadTrigger, submitTrigger: submitTrigger, submitHandler: submitHandler, formField: formField)
    }
    
    init(
        initialLoadTrigger: Observable<Void> = Observable.just(()),
        submitTrigger: Observable<Void>,
        submitHandler: [String : FieldStateType] -> Observable<FormStatus>,
        formField: [FieldFactoryType]
        ) {
        
        var dict = [String : Observable<FieldStateType>]()
        formField.forEach {
            guard dict[$0.name] == nil else {
                fatalError("Cannot have fields with the same name")
            }
            dict[$0.name] = $0.contraOutput
        }
        fields = dict
        
        
        status = initialLoadTrigger
            .map { _ in .Awaiting }
            .concat(submitTrigger
                .flatMap {
                    formField
                        .map { $0.contraOutput }
                        .combineLatest {
                            $0.filter { $0.isUserInput }
                        }
                        .flatMap { fields -> Observable<FormStatus> in
                            guard (fields.map { $0.valid }.and) else {
                                return Observable.just(.Error)
                            }
                            guard (fields.map { $0.dirty }.or) else {
                                return Observable.just(.Awaiting)
                            }
                            
                            var dictionary = [String : FieldStateType]()
                            fields.forEach { dictionary[$0.name] = $0 }
                            
                            return submitHandler(dictionary)
                                .startWith(.Submitting)
                    }
                }
            )
            .startWith(.Loading)
            .shareReplay(1)
            .observeOn(MainScheduler.instance)
        
        submissionEnabled = [
            status
                .map {
                    switch $0 {
                    case .Awaiting: return true
                    case .Submitted: return true
                    default: return false
                    }
            },
            formField
                .map { $0.contraOutput }
                .combineLatest { i -> Bool in
                    // all required fields have to be valid and dirty.
                    // all optional fields also have to be valid.
                    return i.reduce(true) { $0 && $1.valid && ( $1.required ? $1.dirty : true) }
            }
            ]
            .combineLatest {
                $0.and
            }
            // submission is disabled initially
            .startWith(false)
    }
    
    public func fieldOutput<T: Equatable, S: RawRepresentable where S.RawValue == String>(name: S, type: T.Type) -> Observable<FieldState<T>>? {
        return fieldOutput(name.rawValue, type: type)
    }
    
    public func fieldOutput<T: Equatable>(name: String, type: T.Type) -> Observable<FieldState<T>>? {
        return fields[name]
            .map { $0.map { $0 as! FieldState<T> } }
    }
    
    public var dirty: Observable<Bool> {
        return fields.values
            .combineLatest {
                $0.reduce(false) { $0 || $1.dirty }
        }
    }
    
    public var pristine: Observable<Bool> {
        return dirty
            .map(!)
    }
    
    public var valid: Observable<Bool> {
        return fields.values
            .combineLatest {
                $0.reduce(true) { $0 && $1.valid }
        }
    }
    
    public var invalid: Observable<Bool> {
        return valid
            .map(!)
    }
}
