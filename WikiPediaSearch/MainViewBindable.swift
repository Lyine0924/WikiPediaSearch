//
//  MainViewBindable.swift
//  WikiPediaSearch
//
//  Created by Lyine on 2020/06/20.
//  Copyright © 2020 Lyine. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import RxViewBinder

class MainViewBindable: ViewBindable {
    enum Command {
        case fetch
    }
    
    struct Action {
        var _response:BehaviorRelay<[TableCellSection]> = .init(value:[])
        var _isLoading:BehaviorRelay<Bool> = .init(value: false)
        let _error: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    }
    
    struct State {
        var response: Driver<[TableCellSection]>
        var isLoading: Driver<Bool>
        var error: Driver<String?>
        
        init(action: Action) {
            response = action._response.asDriver()
            isLoading = action._isLoading.asDriver()
            error = action._error.asDriver()
        }
    }
    
    let action: Action
    lazy var state =  State(action: self.action)
    private var request: APIRequest?
    let service: APIClient
    
    init(service: APIClient = APIClient()) {
        self.service = service
        self.action = Action()
    }
    
    func bindRequest(request: APIRequest?) {
        self.request = request
    }
    
    func binding(command: Command) {
        switch command {
        case .fetch:
            guard let request = self.request, !request.parameter.isEmpty else { return }
            
            self.action._isLoading.accept(true)
            let result = service.search(apiRequest: request)

            result.asObservable()
                .catchError({ error in
                    self.action._error.accept(error.localizedDescription)
                    return .empty()
                })
                .map { $0.map { TableCellViewModel($0) } }
                .map { ([TableCellSection(model: Void(), items: $0)]) }
                .do(onCompleted: { [weak self] in self?.action._isLoading.accept(false) })
                .bind(to: self.action._response)
                .disposed(by: disposeBag)
        }
    }
}

