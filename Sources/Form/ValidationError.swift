//
//  ValidationError.swift
//  RxFormState
//
//  Created by Lance Zhu on 2016-07-07.
//  Copyright © 2016 Lance Zhu. All rights reserved.
//

import Foundation


public enum ValidationError : ErrorType {
    case Required
    case Custom(message: String)
    
    public var description: String {
        switch self {
        case .Required:
            return "必填项目"
        case let .Custom(e):
            return e
        }
    }
}