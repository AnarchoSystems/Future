//
//  Queued.swift
//  
//
//  Created by Markus Pfeifer on 07.06.20.
//

import Foundation



public struct Queued<T>{
    
    let _onRead : (@escaping Callback<T>) -> Void
    let _onMutatingRead : (@escaping (inout T) -> Void) -> Void
    
    public init(queue: DispatchQueue = DispatchQueue(label: "QueueQueue"),
                _ value: T){
        
        var mutable = value
        
        self._onRead = {reader in queue.async{reader(mutable)}}
        self._onMutatingRead = {reader in queue.async {reader(&mutable)}}
        
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
