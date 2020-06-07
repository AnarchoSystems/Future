//
//  PromiseArrow.swift
//  
//
//  Created by Markus Pfeifer on 07.06.20.
//

import Foundation


public struct PromiseArrow<T,U>{
    
    private let arrow : (T) -> Promise<U>
    
    public init(wrappedValue : @escaping (T) -> Promise<U>){
        self.arrow = wrappedValue
    }
    
    public func callAsFunction(_ arg: T) -> Promise<U>{
        arrow(arg)
    }
    
}


public extension PromiseArrow where U == Void{
    
    func send(_ arg: T){
        arrow(arg).execute()
    }
    
}
