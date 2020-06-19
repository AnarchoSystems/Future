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
        
        let completion = {
            guard
                let out1 = out1,
                let out2 = out2 else{
                    return
            }
            handler(out1.flatMap{s in out2.map{(s, $0)}})
        }
        
        promise1.execute{
            result in out1 = result
            completion()
        }
        
        promise2.execute{
            result in out2 = result
            completion()
        }
        
    }
    
}



public func zip<S,T,U>(_ promise1: Promise<S>,
                     _ promise2: Promise<T>,
                     _ promise3: Promise<U>) -> Promise<(S,T,U)>{
    
    Promise<(S,T, U)>{handler in
        
        var out1 : Result<S, Error>!
        var out2 : Result<T, Error>!
        var out3 : Result<U, Error>!
        
        let completion = {
            guard
            let out1 = out1,
            let out2 = out2,
            let out3 = out3 else {
                return
            }
            handler(out1.flatMap{s in out2.flatMap{t in out3.map{(s,t,$0)}}})
        }
        
        promise1.execute{
            result in out1 = result
            completion()
        }
        
        promise2.execute{
            result in out2 = result
            completion()
        }
        
        promise3.execute{
            result in out3 = result
            completion()
        }
        
    }
    
}

