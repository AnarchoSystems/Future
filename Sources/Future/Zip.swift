//
//  Zip.swift
//  
//
//  Created by Markus Pfeifer on 07.06.20.
//

import Foundation



public func zip<S,T>(_ promise1: Promise<S>,
                     _ promise2: Promise<T>) -> Promise<(S,T)>{
    
    Promise<(S,T)>{handler in
        
        var out1 : Result<S,Error>!
        var out2 : Result<T,Error>!
        
        let group = DispatchGroup()
        
        group.enter()
        promise1.execute{result in out1 = result; group.leave()}
        
        group.enter()
        promise2.execute{result in out2 = result; group.leave()}
        
        group.wait()
        
        handler(out1.flatMap{s in out2.map{(s,$0)}})
        
    }
    
}



public func zip<S,T,U>(_ promise1: Promise<S>,
                     _ promise2: Promise<T>,
                     _ promise3: Promise<U>) -> Promise<(S,T,U)>{
    
    Promise<(S,T, U)>{handler in
        
        var out1 : Result<S, Error>!
        var out2 : Result<T, Error>!
        var out3 : Result<U, Error>!
        
        let group = DispatchGroup()
        
        group.enter()
        promise1.execute{result in out1 = result; group.leave()}
        
        group.enter()
        promise2.execute{result in out2 = result; group.leave()}
        
        group.enter()
        promise3.execute{result in out3 = result; group.leave()}
        
        group.wait()
        
        handler(out1.flatMap{s in out2.flatMap{t in out3.map{(s,t,$0)}}})
        
    }
    
}

