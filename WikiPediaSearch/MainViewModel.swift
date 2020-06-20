//
//  TableCellViewModel.swift
//  WikiPediaSearch
//
//  Created by Lyine on 2020/06/13.
//  Copyright © 2020 Lyine. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

typealias TableCellSection = SectionModel<Void, TableCellViewModelType>

protocol MainViewModelInput {
    func fetchData(request: APIRequest)
}

protocol MainViewModelOutput {
    var response: Driver<[TableCellSection]> { get }
    var isLoading: Driver<Bool> { get }
}

protocol MainViewModelType {
    var input: MainViewModelInput { get }
    var output: MainViewModelOutput { get }
}

class MainViewModel: MainViewModelType, MainViewModelInput, MainViewModelOutput {
    var input: MainViewModelInput { return self }
    var output: MainViewModelOutput { return self }

    let apiClient: APIClient
    let disposeBag = DisposeBag()

    lazy var response: Driver<[TableCellSection]> = _response.asDriver()
    lazy var isLoading: Driver<Bool> = _isLoading.asDriver()
    lazy var error: Driver<String?> = _error.asDriver()

    private var _response: BehaviorRelay<[TableCellSection]> = .init(value: [])
    private var _isLoading: BehaviorRelay<Bool> = .init(value: false)
    private let _error: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    init(_ apiService: APIClient = APIClient()) {
        self.apiClient = apiService
    }

    func fetchData(request: APIRequest) {
        let result = apiClient.search(apiRequest: request)

        result.asObservable()
            .catchError({ error in
                self._error.accept(error.localizedDescription)
                return .empty()
            })
            .map { $0.map { TableCellViewModel($0) } }
            .map { ([TableCellSection(model: Void(), items: $0)]) }
            .do(onCompleted: { [weak self] in self?._isLoading.accept(false) })
            .bind(to: self._response)
            .disposed(by: disposeBag)
    }
}
