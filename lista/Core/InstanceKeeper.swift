//
//  InstanceKeeper.swift
//  lista
//
//  Created by Lucca Beurmann on 15/01/26.
//

import Combine
import CoreData
import SwiftUI

@Observable
class InstanceKeeper {

    // MARK: - Initializers
    private init() {}

    static let shared: InstanceKeeper = .init()

    // MARK: - Singletons
    private var listDatasource: ListDataSourceProtocol?
    private var listRepository: ListRepositoryProtocol?

    // MARK: - Core
    func provideDateProvider() -> DateProviderProtocol {
        return DateProvider()
    }

    // MARK: - Data Providers
    func provideContext() -> NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }

    func provideListDatasource() -> ListDataSourceProtocol {
        guard let dataSource = listDatasource else {
            listDatasource = ListDataSource(
                context: provideContext(),
                dateProvider: provideDateProvider()
            )
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

    // MARK: - Presentation Providers
    func provideHomeViewModel() -> HomeScreen.ViewModel {
        return HomeScreen.ViewModel(
            fetchListsService: provideFetchListsService(),
            createListService: provideCreateListService(),
            removeListService: provideRemoveListService()
        )
    }
}
