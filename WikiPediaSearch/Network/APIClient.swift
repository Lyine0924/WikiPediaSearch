//
//  APIClient.swift
//  WikiPediaSearch
//
//  Created by Lyine on 2020/05/10.
//  Copyright © 2020 Lyine. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class APIClient {
    let disposeBag = DisposeBag()

    private func get<T:Codable>(apiRequest: APIRequest) -> Observable<T> {
        return Observable<T>.create { observer in
            let request = apiRequest.request()

            let dataRequest = AF.request(request).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let model: T = try JSONDecoder().decode(T.self, from: data)
                        observer.onNext(model)
                    } catch let error {
                        observer.onError(error)
                    }

                case .failure(let error):
                    observer.onError(error)
                    break
                }

                observer.onCompleted()
            }

            return Disposables.create {
                dataRequest.cancel()
            }
        }
    }

    func search(apiRequest: APIRequest) -> Observable<[searchResult]> {
        return Observable<[searchResult]>.create { observer in
            var titles: [String] = [String]()
            var urls: [String] = [String]()
            
            let observable: Observable<WikipediaResponses> = self.get(apiRequest: apiRequest)

            observable.subscribe(onNext: {
                $0.title.map {
                    titles.append($0)
                }

                $0.url.map {
                    urls.append($0)
                }
                
                observer.onNext(searchResult.fetchData(titles: titles, urls: urls))
                observer.onCompleted()     
            }).disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
}
