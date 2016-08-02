//
//  ValidationNELTests.swift
//  ValidationNELTests
//
//  Created by Lance Zhu on 2016-07-07.
//  Copyright © 2016 Lance Zhu. All rights reserved.
//

import Quick
import Nimble
import Swiftz
import ValidationNEL

class ValidationNELTests : QuickSpec {
    
    override func spec() {
        
        let value = 10
        let error1 = MyError(message: "Error Message 1")
        let error2 = MyError(message: "Error Message 2")
        let error3 = MyError(message: "Error Message 3")
        let error4 = MyError(message: "Error Message 4")
        let error5 = MyError(message: "Error Message 5")
        
        
        describe("Initializing ValidationNEL") {
            
            context("With 1 failure") {
                it("should return nil") {
                    let base = ValidationNEL<Int, MyError>.Failure([error1])
                    
                    expect(base.isSuccess).to(beFalse())
                    expect(base.isFailure).to(beTrue())
                    expect(base.success).to(beNil())
                    expect(base.failure) == Optional.Some([error1])
                }
            }
            
            
            context("With 1 success") {
                it("should return the value") {
                    let base = ValidationNEL<Int, MyError>.Success(value)
                    
                    expect(base.isSuccess).to(beTrue())
                    expect(base.isFailure).to(beFalse())
                    expect(base.success) == value
                    expect(base.failure).to(beNil())
                }
                
                
                it("should return the value") {
                    let base = ValidationNEL<Int, MyError>.pure(value)
                    
                    expect(base.isSuccess).to(beTrue())
                    expect(base.isFailure).to(beFalse())
                    expect(base.success) == value
                    expect(base.failure).to(beNil())
                }
            }
            
        }
        
        describe("Compose ValidationNEL") {
            
            context("All success") {
                it("should return the value") {
                    
                    let base = ValidationNEL<Int -> Int -> Int -> Int, MyError>.Success({ a in { b in { c in value } } })
                    
                    
                    let rule1 = ValidationNEL<Int, MyError>.Success(value)
                    let rule2 = ValidationNEL<Int, MyError>.Success(value)
                    let rule3 = ValidationNEL<Int, MyError>.Success(value)
                    
                    let result = base <*> rule1 <*> rule2 <*> rule3
                    
                    expect(result.success) == Optional.Some(value)
                    expect(result.failure).to(beNil())
                }
            }
            
            
            context("With only one failure") {
                
                it("should return exactly 1 failure") {
                    
                    let base = ValidationNEL<Int -> Int, MyError>.Success({ a in value })
                    
                    let rule = ValidationNEL<Int, MyError>.Failure([error1])
                    
                    let result = base <*> rule
                    
                    expect(result.isFailure).to(beTrue())
                    expect(result.isSuccess).to(beFalse())
                    expect(result.failure) == Optional.Some([error1])
                }
            }
            
            context("With multiple failures") {
                
                it("should return only failures") {
                    
                    
                    let base = ValidationNEL<Int -> Int -> Int -> Int, MyError>.Success({ a in { b in { c in value } } })
                    
                    let rule1 = ValidationNEL<Int, MyError>.Failure([error1])
                    let rule2 = ValidationNEL<Int, MyError>.Success(value)
                    let rule3 = ValidationNEL<Int, MyError>.Failure([error3])
                    
                    let result = base <*> rule1 <*> rule2 <*> rule3
                    
                    expect(result.isFailure).to(beTrue())
                    expect(result.isSuccess).to(beFalse())
                    expect(result.failure) == Optional.Some([error1, error3])
                }
                
                it("should return multiple failures") {
                    
                    let base = ValidationNEL<Int -> Int -> Int -> Int, MyError>.Success({ a in { b in { c in value } } })
                    
                    let rule1 = ValidationNEL<Int, MyError>.Failure([error1])
                    let rule2 = ValidationNEL<Int, MyError>.Failure([error2])
                    let rule3 = ValidationNEL<Int, MyError>.Failure([error3])
                    
                    let result = base <*> rule1 <*> rule2 <*> rule3
                    
                    expect(result.isFailure).to(beTrue())
                    expect(result.isSuccess).to(beFalse())
                    expect(result.failure) == Optional.Some([error1, error2, error3])
                }
            }
            
            context("Multiple errors in one rule") {
                it("should faltten and return multiple failures") {
                    
                    let base = ValidationNEL<Int -> Int -> Int, MyError>.Success({ a in { b in value } })
                    
                    let rule1 = ValidationNEL<Int, MyError>.Failure([error1])
                    let rule2 = ValidationNEL<Int, MyError>.Failure([error2, error3])
                    
                    let result = base <*> rule1 <*> rule2
                    
                    expect(result.isFailure).to(beTrue())
                    expect(result.isSuccess).to(beFalse())
                    expect(result.failure) == Optional.Some([error1, error2, error3])
                }
                
                it("should faltten and return multiple failures") {
                    
                    let base = ValidationNEL<Int -> Int, MyError>.Success({ a in value })
                    
                    let rule1 = ValidationNEL<Int, MyError>.Failure([error1, error2, error3, error4, error5])
                    
                    let result = base <*> rule1
                    
                    expect(result.isFailure).to(beTrue())
                    expect(result.isSuccess).to(beFalse())
                    expect(result.failure) == Optional.Some([error1, error2, error3, error4, error5])
                }
            }

            
        }
        
        describe("`getOrElse`") {
            context("When validation is `Success`") {
                it("should return the original value contained in `Success`") {
                    
                    let base = ValidationNEL<Int, MyError>.Success(value)
                    
                    let result = base.getOrElse(1)
                    
                    expect(result) == value
                }
            }
            
            context("When validation is `Failure`") {
                it("should return the replacement value") {
                    
                    let base = ValidationNEL<Int, MyError>.Failure([error1])
                    
                    let result = base.getOrElse(1)
                    
                    expect(result) == 1
                }
            }
        }
        
        describe("`map`") {
            
            let valueString = "hello"
            
            it("should map `Success` to another value") {
                let base = ValidationNEL<Int, MyError>.Success(value)
                
                let result = base.map { a in valueString }
                
                expect(result.success) == Optional.Some(valueString)
                expect(result.failure).to(beNil())
            }
            
            it("should not change the value of `Failure`") {
                let base = ValidationNEL<Int, MyError>.Failure([error1])
                
                let result = base.map { a in valueString }
                
                expect(result.success).to(beNil())
                expect(result.failure) == Optional.Some([error1])
            }
            
            it("should map `Success` to another value") {
                let base = ValidationNEL<Int, MyError>.Success(value)
                
                let result = { a in valueString } <^> base
                
                expect(result.success) == Optional.Some(valueString)
                expect(result.failure).to(beNil())
            }
            
            
            it("should not change the value of `Failure`") {
                let base = ValidationNEL<Int, MyError>.Failure([error1])
                
                let result = { a in valueString } <^> base
                
                expect(result.success).to(beNil())
                expect(result.failure) == Optional.Some([error1])
            }
            
            
            it("should map `Success` to another value") {
                let base = ValidationNEL<Int, MyError>.Success(value)
                
                let result = base.fmap { a in valueString }
                
                expect(result.success) == Optional.Some(valueString)
                expect(result.failure).to(beNil())
            }
            
            it("should not change the value of `Failure`") {
                let base = ValidationNEL<Int, MyError>.Failure([error1])
                
                let result = base.fmap { a in valueString }
                
                expect(result.success).to(beNil())
                expect(result.failure) == Optional.Some([error1])
            }
        }
        
        describe("`pure`") {
            
            it("should return the value") {
                let base = ValidationNEL<Int, MyError>.pure(value)
                
                expect(base.isSuccess).to(beTrue())
                expect(base.isFailure).to(beFalse())
                expect(base.success) == value
                expect(base.failure).to(beNil())
            }
        }
    }
    
}
