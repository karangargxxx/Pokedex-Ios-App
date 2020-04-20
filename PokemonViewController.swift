//cs50.harvard.edu/x/2020/tracks/mobile/ios/
import UIKit

class PokemonViewController: UIViewController {
    var url: String!
    var name = ""
    static var pokeDidCatch = PokeCatch()
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var pokeImage: UIImageView!
    @IBOutlet var pokedescription: UILabel!
    @IBOutlet var catchPokemon: UIButton!
    
    @IBAction func toggleCatch() {
        PokemonViewController.self.pokeDidCatch.CatchPokemons[name] = !(PokemonViewController.self.pokeDidCatch.CatchPokemons[name]!)
        UserDefaults.standard.set(PokemonViewController.pokeDidCatch.CatchPokemons, forKey: "catchedPokemons")
        if PokemonViewController.self.pokeDidCatch.CatchPokemons[name] == false{
            catchPokemon.setTitle("Catch", for: UIControl.State.normal)
        }
        else {
            catchPokemon.setTitle("Release", for:UIControl.State.normal)
        }
    }

    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PokemonViewController.pokeDidCatch.CatchPokemons = UserDefaults.standard.dictionary(forKey: "catchedPokemons") as? [String:Bool] ?? [:]
        
        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        
        let group = DispatchGroup()
        group.enter()
        loadPokemon()
        group.leave()
        
        
        
        group.notify(queue: .main) {
            
            if PokemonViewController.self.pokeDidCatch.CatchPokemons[self.name] == false {
                self.catchPokemon.setTitle("Catch", for: UIControl.State.normal)
            }
            else if PokemonViewController.pokeDidCatch.CatchPokemons[self.name] == true {
                self.catchPokemon.setTitle("Release", for:UIControl.State.normal)
            }
        }
    }

    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                
                if PokemonViewController.pokeDidCatch.CatchPokemons[result.name] == nil {
                    PokemonViewController.self.pokeDidCatch.CatchPokemons[result.name] = false
                }
                self.name = result.name
                self.loadDescription()
                let urlString =  result.sprites.front_default
                guard let urlImage = URL(string: urlString) else {
                    return
                }
                guard let imageData = try? Data(contentsOf: urlImage) else {
                    return
                }
                guard let image = UIImage(data: imageData) else {
                    return
                }
                
                
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)
                    self.pokeImage.image = image

                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = self.capitalize(text: typeEntry.type.name)
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = self.capitalize(text: typeEntry.type.name)
                        }
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    func loadDescription() {
        let urlDescription = "https://pokeapi.co/api/v2/pokemon-species/" + self.name
        print(urlDescription)
        URLSession.shared.dataTask(with: URL(string: urlDescription)!) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let pokemonDescription = try JSONDecoder().decode(PokemonDescription.self, from: data)
                DispatchQueue.main.async {
                    for description in pokemonDescription.flavor_text_entries {
                        if description.language.name == "en" {
                            self.pokedescription.text = self.capitalize(text: description.flavor_text.replacingOccurrences(of: "\n", with: " "))
                            print(description.flavor_text)
                            break
                        }
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
}
