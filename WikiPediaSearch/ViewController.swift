//
//  ViewController.swift
//  WikiPediaSearch
//
//  Created by Lyine on 2020/04/30.
//  Copyright © 2020 Lyine. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import SafariServices

class ViewController: UIViewController {
    
    enum Cell: String {
        case identifier = "cellIdentifier"
    }
    
    private let tableView = UITableView()
    private let cellIdentifier = Cell.identifier.rawValue
    
    private let apiClient = APIClient()
    
    private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Here"
        return searchController
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureProperties()
        configureLayout()
        bindUI()
        // Do any additional setup after loading the view.
    }
    
    private func configureProperties() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        navigationItem.searchController = searchController
        navigationItem.title = "Wikipedia finder"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
    }

    private func bindUI() {
        searchController.searchBar.rx.text.orEmpty
            .asObservable()
            .throttle(.microseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { ($0 ?? "").lowercased().replacingOccurrences(of: " ", with: "_") }
            .map { WikipediaRequest(word: $0) }
            .flatMapLatest { request -> Observable<[searchResult]> in
                return self.apiClient.search(apiRequest: request)
            }
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier)) { index, model, cell in
                cell.textLabel?.text = model.title
                cell.textLabel?.adjustsFontSizeToFitWidth = true
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(searchResult.self)
            .map { URL(string: $0.url ?? "")! }
            .map { SFSafariViewController(url: $0) }
            .subscribe(onNext: { [weak self] safariViewController in
                self?.present(safariViewController,animated: true)
            })
            .disposed(by: disposeBag)
    }
}

