
import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(price: String,currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    var delegate:CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "0783E3E2-0098-4B5F-9945-3B5C80E88386"
    
    let currencyArray = ["TRY","AUD", "BRL","CAD","EUR","GBP","HKD","IDR","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SGD","USD","ZAR"]
    let units = ["₺","AU$","R$","C$","€","£","HK$","Rp","₹","¥","Mex$","kr","NZ$","zł","L","₽","S$","$","R"]
    
    func getCoinPrice(for currency: String){
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let bitcoinPrice = self.parseJSON(safeData){
                        let bitCoinPriceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdateCoin(price: bitCoinPriceString, currency: currency)
                    
                }
            }
            
            
        }
            task.resume()

    }
    }
    
    func parseJSON(_ coinData: Data)->Double?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let lastPrice = decodedData.rate
            return lastPrice
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
