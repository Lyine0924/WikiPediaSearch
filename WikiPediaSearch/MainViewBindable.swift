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
        case fetch(APIRequest)
    }
    
    struct Action {
        var _request:BehaviorRelay<APIRequest> = .init(value: WikipediaRequest.init(word: ""))
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
    let service: APIClient
    
    init(service: APIClient = APIClient()) {
        self.service = service
        self.action = Action()
    }
    
    func binding(command: Command) {
        switch command {
        case .fetch(let word):
            search(word: word)
        }
    }
    
    private func search(word: APIRequest) {
        self.action._request.accept(word)
        
        self.action._request
            .asObservable()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] request in
                self?.bindingSearchResult(request: request)
            })
            .disposed(by: disposeBag)
    }
    
    private func startLoading() {
        action._isLoading.accept(true)
    }
    
    private func stopLoading() {
        action._isLoading.accept(false)
    }
    
    private func bindingSearchResult(request: APIRequest?) {
        guard let api = request, !api.parameter.isEmpty else {
            return
        }
        
        startLoading()
        
        let result = self.service.search(apiRequest: api)

        result.asObservable()
            .catchError({ error in
                self.action._error.accept(error.localizedDescription)
                return .empty()
            })
            .map { $0.map { TableCellViewModel($0) } }
            .map { ([TableCellSection(model: Void(), items: $0)]) }
            .do(onCompleted: { [weak self] in self?.stopLoading() })
            .bind(to: self.action._response)
            .disposed(by: disposeBag)
    }
}

