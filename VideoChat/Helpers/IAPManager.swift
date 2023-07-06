//
//  IAPManager.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 5.07.2023.
//

import Foundation
import StoreKit

final class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    static let shared = IAPManager()
    
    var products = [SKProduct]()
    
    enum Product: String, CaseIterable{
        case litepackage1
    }
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    public func fetchProducts(){
        let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap({ $0.rawValue })))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
    
    func purchase(product: Product) {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        
        guard let storeKitProduct = products.first(where: { $0.productIdentifier == product.rawValue }) else {
            return
        }
        
        let paymentRequest = SKPayment(product: storeKitProduct)
        SKPaymentQueue.default().add(paymentRequest)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                // Satın alma işlemi devam ediyor
                break
            case .purchased:
                // Satın alma işlemi başarılı oldu
                completeTransaction(transaction)
                break
            case .failed:
                // Satın alma işlemi başarısız oldu
                failTransaction(transaction)
                break
            case .restored:
                // Önceden satın alınmış ürün geri yüklendi
                restoreTransaction(transaction)
                break
            case .deferred:
                // Ödeme ertelendi
                break
            @unknown default:
                break
            }
        }
    }
    
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        // Satın alma işlemi tamamlandı, burada gerekli işlemleri gerçekleştirin
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failTransaction(_ transaction: SKPaymentTransaction) {
        // Satın alma işlemi başarısız oldu, burada gerekli işlemleri gerçekleştirin
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        // Önceden satın alınmış ürün geri yüklendi, burada gerekli işlemleri gerçekleştirin
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
