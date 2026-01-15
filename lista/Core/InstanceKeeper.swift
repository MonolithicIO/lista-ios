//
//  InstanceKeeper.swift
//  lista
//
//  Created by Lucca Beurmann on 15/01/26.
//

import SwiftUI
import Combine

@Observable
class InstanceKeeper {
    
    // MARK: - Initializers
    private init() {}
    
    static let shared: InstanceKeeper = .init()
    
    // MARK: - Singletons
    private var listDatasource: ListDataSourceProtocol?
    private var listRepository: ListRepositoryProtocol?
    
    // MARK: - Data Providers
    func provideListDatasource() -> ListDataSourceProtocol {
        guard let dataSource = listDatasource else {
            listDatasource = ListDataSource()
            return listDatasource!
        }
       return dataSource
    }
    
    func provideListRepository() -> ListRepositoryProtocol {
        guard let repository = listRepository else {
            listRepository = ListRepository(datasource: provideListDatasource())
            return listRepository!
        }
        return repository
    }
    
    
    // MARK: - Domain Providers
    func provideCreateListService() -> CreateListServiceProtocol {
        return CreateListService(repository: provideListRepository())
    }
    
    func provideFetchListsService() -> FetchListsServiceProtocol {
        return FetchListsService(repository: provideListRepository())
    }
    
    func provideRemoveListService() -> RemoveListServiceProtocol {
        return RemoveListService(repository: provideListRepository())
    }
}
