//: Playground - noun: a place where people can play

import UIKit
import ValidationNEL
import Swiftz

struct MyError : Equatable {
    let message: String
}

func ==(lhs: MyError, rhs: MyError) -> Bool {
    return lhs.message == rhs.message
}

func validate(value: String) -> ValidationNEL<String, MyError> {
    let base = ValidationNEL<String -> String, MyError>.Success({ a in value })
    let rule: ValidationNEL<String, MyError> = value.characters.count >= 8 ?
        .Success(value) :
        .Failure([MyError(message: "The string must have more than 8 characters")])
    
    return base <*> rule
}


let password = "123456"
print(validate(password))

