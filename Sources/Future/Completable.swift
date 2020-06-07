//
//  Completable.swift
//  
//
//  Created by Markus Pfeifer on 07.06.20.
//

import Foundation


public struct Completable<T>{
    
    let produce : (@escaping Handler<T>) -> Void
    let onError : (Error) -> Void
    
    func execute(deliverOn queue: DispatchQueue = .main, then callback: @escaping Callback<T>){
        produce{result in
            switch result{
                
            case .success(let value):
                
                queue.async{
                callback(value)
                }
                
            case .failure(let error):
                
                queue.async{
                self.onError(error)
                }
                
            }
        }
    }
    
}

