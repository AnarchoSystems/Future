//
//  Queued.swift
//  
//
//  Created by Markus Pfeifer on 07.06.20.
//

import Foundation



public struct AsyncRef<T>{
    
    let _onRead : (@escaping Callback<T>) -> Void
    let _onMutatingRead : (@escaping (inout T) -> Void) -> Void
    
    public init(_ value: T){
        
        var mutable = value
        
        self._onRead = {reader in reader(mutable)}
        self._onMutatingRead = {reader in reader(&mutable)}
        
    }
    
    public func enqueueRead(reader: @escaping Callback<T>){
        self._onRead(reader)
    }
    
    public func enqueueMutatingRead(reader: @escaping (inout T) -> Void){
        self._onMutatingRead(reader)
    }
    
    public func enqueueSet(newValue: T){
        enqueueMutatingRead(reader: {$0 = newValue})
    }
    
}
