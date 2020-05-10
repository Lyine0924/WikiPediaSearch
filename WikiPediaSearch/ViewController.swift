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
import SafariServices

class ViewController: UIViewController {
    
    private let tableView = UITableView()
    private let cellIdentifier = "cellIdentifier"
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
    }

    private func bindUI() {
        searchController.searchBar.rx.text.asObservable()
            .filter { $0?.isEmpty == false }
            .map { ($0 ?? "").lowercased() }
            .map { WikipediaRequest(word: $0) }
            .flatMap { request -> Observable<[searchResult]> in
                return self.apiClient.search(apiRequest: request)
            }
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier)) { index, model, cell in
                cell.textLabel?.text = model.title
//                cell.detailTextLabel?.text = model.description
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

