//
//  File.swift
//  RxFormState
//
//  Created by Hong Zhu on 2016-07-07.
//  Copyright © 2016 Lance Zhu. All rights reserved.
//

import Foundation
import RxFormState
import Quick
import Nimble

struct FieldStateFixture {
    let name = "TestFieldState"
    let required = true
    let initialValue = "hello"
    
    
    var toRequiredFieldState: FieldState<String> {
        return FieldState<String>(
            name: name,
            required: required,
            initialValue: initialValue,
            validation: nil
        )
    }
}

//protocol FieldStateFixture {
//    var toFieldState: FieldState {
//    
//    }
//}

class FieldStateTests : QuickSpec {
    override func spec() {
        describe("Initialization") {
            it("should initialize with proper values") {
                let state = FieldState<String>(
                    name: "Tester",
                    required: true,
                    initialValue: nil,
                    validation: nil
                )
                
                expect(state.name).to(equal("Tester"))
            }
        }
        
//        describe("onChange") {
//            it("should change")
//        }
    }
}
