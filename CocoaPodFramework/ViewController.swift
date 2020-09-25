//
//  ViewController.swift
//  CocoaPodFramework
//
//  Created by The App Experts on 22/09/2020.
//  Copyright © 2020 The App Experts. All rights reserved.
//

import UIKit
import Kingfisher
import ProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var pokisURLs:[Pokies]=[]
    var pokies:[Poki] = []
    let urlString = "https://pokeapi.co/api/v2/pokemon"
    var cellIdentifier = "theCell"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ProgressHUD.colorAnimation = .red
        ProgressHUD.animationType = .lineScaling
        ProgressHUD.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)

         getPokisUrls()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ProgressHUD.dismiss()
    }
    
    func getPokisUrls() {
        guard let url = URL(string: self.urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, err) in

            guard let data = data else {return}
            guard let results = try? JSONDecoder().decode(PokiResult.self, from: data) else {return}
//            print("pokis> \(results)")
            self.pokisURLs.append(contentsOf: results.results)
            DispatchQueue.main.async {
                for pokiUrl in self.pokisURLs {
                    self.getPoki(from: pokiUrl.url)
                }
            }
        }.resume()

    }
    
    func getPoki(from url: URL){
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            guard let results = try? JSONDecoder().decode(Poki.self, from: data) else {return}
//            print("poki> \(results.self)")
            
            self.pokies.append(results.self)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pokies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        
        let poki = self.pokies[indexPath.row]
        update(the: cell, with: poki)
        
        return cell
    }
    
    func update(the cell:UITableViewCell, with poki: Poki) {
//        if let data = try? Data(contentsOf: poki.spriteURL) {
//            cell.imageView?.image = UIImage(data: data)
//        }
        cell.imageView?.kf.setImage(with: poki.spriteURL, placeholder: UIImage(imageLiteralResourceName: "ninja"))
        cell.textLabel?.text = "\(poki.name)"
    }
}

struct PokiResult: Decodable {
    let results:[Pokies]
}

struct Pokies : Decodable{
    let url:URL
}

struct Poki: Decodable {
    let name:String
    let spriteURL:URL
    
    enum CodingKeys: String, CodingKey {
        case name
        case sprites
    }
    
    enum SpriteCodingKeys: String, CodingKey {
        case spriteURL = "front_default"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let spriteContainer = try container.nestedContainer(keyedBy: SpriteCodingKeys.self, forKey: .sprites)
        self.name = try container.decode(String.self, forKey: .name)
        self.spriteURL = try spriteContainer.decode(URL.self, forKey: .spriteURL)
    }
}
