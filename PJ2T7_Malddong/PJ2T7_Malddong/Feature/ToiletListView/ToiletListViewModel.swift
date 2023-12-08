//
//  ToiletViewModel.swift
//  BasicSetting
//
//  Created by 정다산 on 12/5/23.
//

import Foundation


class ToiletListViewModel:ObservableObject{
    @Published var toiletList: [Toilet]
    @Published var distributeSelect: String
    @Published var isGridAlign:Bool
    var distributeArea : [String]
    
    
    let api_key = "TOILET_API_KEY"
    private var apiKey: String? {
        get{ getValueOfPlistFile("ApiKeys",api_key)}
    }
    
    init(
        toiletList: [Toilet] = [],
        distributeSelect: String = "제주시",
        isGridAlign: Bool = true,
        distributeArea: [String] = ["제주시","서귀포시"]
        
    ) {
        self.toiletList = toiletList
        self.distributeSelect = distributeSelect
        self.isGridAlign = isGridAlign
        self.distributeArea = distributeArea
        
    }
    
    
  
    
}
extension ToiletListViewModel{
    //TODO: - 우 상단에 피커를 선택했을때 동네별로 분류해야함
    
    func gridOneLine(){
        isGridAlign = false
    }
    
    func gridTwoLine(){
        isGridAlign = true
    }
    
    func fectchData(){
        guard let apiKey = apiKey else {return}
        
        let urlString =
        "https://apis.data.go.kr/6510000/publicToiletService/getPublicToiletInfoList?pageNo=1&numOfRows=500&serviceKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            guard let response = response as?
                    HTTPURLResponse,response.statusCode == 200 else {
                print("status code is not 200")
                return
            }
            
            guard let data = data else {
                print("No dadta reseived")
                return
            }
            
            do{
                let json = try JSONDecoder().decode(ToiletResponse.self, from: data)
                
                DispatchQueue.main.async{
                    self.toiletList = json.response.body.items.item
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }//fetch
    
    
    func getValueOfPlistFile(_ plistFileName:String,_ key:String) -> String?{
        guard let filePath =
                Bundle.main.path(forResource: plistFileName, ofType: "plist") else {
            fatalError("Couldn't find file '\(plistFileName).plist'")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        
        guard let value = plist?.object(forKey: key) as? String else{
            fatalError("Couldn't find key '\(key)'")
        }
        return value
    }
    
    func imageNilCheck(_ toilet:Toilet) -> String{
        guard let toilet = toilet.photo else{
            return "dolhareubang"
        }
        return toilet[0]
    }
   
    
    
}
