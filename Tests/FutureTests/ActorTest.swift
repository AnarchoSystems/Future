//
//  ActorTest.swift
//  
//
//  Created by Markus Pfeifer on 07.06.20.
//

import Foundation
import XCTest
import Future

extension String : Error{}

class ExampleAgent : Agent{
    
    let exp : XCTestExpectation
    let inv : XCTestExpectation
    var wasCalled = false
    
    init(exp: XCTestExpectation, inv: XCTestExpectation){
        
        self.exp = exp
        self.inv = inv
        
        super.init()
        
    }
    
    @Message(ExampleAgent.fooImpl) var foo
    private func fooImpl(_ int: Int) -> Void{
        
            
            defer{wasCalled = true}
            
            guard !wasCalled else{
                return inv.fulfill()
            }
            
            XCTAssert(int == 42)
            exp.fulfill()
            
    }
    
}

extension FutureTests{
    
    func testExample(){
        
        let exp = self.expectation(description: "Foo")
        let inv = self.expectation(description: "Bar")
        inv.isInverted = true
        
        let exa = ExampleAgent(exp: exp, inv: inv)
        
        exa.foo(42).execute()
        
        exa.crash(reason: "Test")
        
        exa.foo(24).execute()
        
        self.waitForExpectations(timeout: 1)
        
    }
    
}
