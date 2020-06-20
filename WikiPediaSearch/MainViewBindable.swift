////
////  MainViewBindable.swift
////  WikiPediaSearch
////
////  Created by Lyine on 2020/06/20.
////  Copyright © 2020 Lyine. All rights reserved.
////
//
//import Foundation
//import RxSwift
//import RxCocoa
//import RxDataSources
//import RxViewBinder
//
//class MainViewBindable: ViewBindable {
//    enum Command {
//        case fetch
//    }
//    
//    struct Action {
//        var _response:BehaviorRelay<[TableCellSection]> = .init(value:[])
//        var _isLoading:BehaviorRelay<Bool> = .init(value: false)
//        let _error: BehaviorRelay<String?> = BehaviorRelay(value: nil)
//    }
//    
//    struct State {
//        var response: Driver<[TableCellSection]>
//        var isLoading: Driver<Bool>
//        var error: Driver<String?>
//        
//        init(action: Action) {
//            response = action._response.asDriver()
//            isLoading = action._isLoading.asDriver()
//            error = action._error.asDriver()
//        }
//    }
//    
//    let action: Action
//    lazy var state =  State(action: self.action)
//    let request: APIRequest
//    let service: APIClient
//}
//
