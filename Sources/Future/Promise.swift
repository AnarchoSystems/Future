//
//  Promise.swift
//  
//
//  Created by Markus Pfeifer on 07.06.20.
//

import Foundation



public struct Promise<T>{
    
    let declaration : (@escaping Handler<T>) -> Void
    let queue : DispatchQueue
    
    internal init(queue: DispatchQueue, declaration: @escaping (@escaping Handler<T>) -> Void){
        self.queue = queue
        self.declaration = {handler in
            
            let wasCalled = Queued(queue: queue, false)
            
            wasCalled.enqueueMutatingRead{called in
                
                defer{called = true}
                
                if !called{
                        declaration(handler)
                }
                
            }
        }
    }
    
}


public extension Promise{
    
    init(_ declaration: @escaping (@escaping Handler<T>) -> Void){
        self = Promise(queue: DispatchQueue(label: "Promise"), declaration: declaration)
    }
    
    init(_ declaration: @escaping (@escaping Callback<T>, @escaping Callback<Error>) -> Void){
        self = Promise{handler in
            declaration({handler(.success($0))}, {handler(.failure($0))})
        }
    }
    
    init(pure: T){
        self = Promise{$0(.success(pure))}
    }
    
    init(failure: Error){
        self = Promise{$0(.failure(failure))}
    }
    
}


public extension Promise{
    
    func handleError(_ onError: @escaping (Error) -> Void) -> Completable<T>{
        Completable(produce: declaration,
                    onError: onError)
    }
    
    func execute(_ onResult: @escaping Handler<T>){
        declaration(onResult)
    }
    
}



public extension Promise where T == Void{
    
    func execute(){
        execute{_ in }
    }
    
}



public extension Promise{
    
    
    func map<U>(_ transform: @escaping (T) -> U) -> Promise<U>{
        
        Promise<U>(queue: self.queue) { (handler) in
            self
                .handleError{handler(.failure($0))}
                .execute(deliverOn: self.queue){handler(.success(transform($0)))}
        }
        
    }
    
    
    func then<U>(_ transform: @escaping (T) -> Promise<U>) -> Promise<U>{
        
        Promise<U>(queue: self.queue) { (handler) in
            self
                .handleError{handler(.failure($0))}
                .execute(deliverOn: self.queue) {transform($0).execute(handler)}
        }
        
    }
    
    
    func then<U>(_ transform: PromiseArrow<T,U>) -> Promise<U>{
        then(transform.callAsFunction)
    }
    
    
}

