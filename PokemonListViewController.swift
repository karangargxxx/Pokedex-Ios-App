import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    var pokemon: [PokemonListResult] = []
    var searchResults: [PokemonListResult] = []
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    // This function is called everytime text inside searchbar changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = pokemon
        if searchText.isEmpty {
            searchResults = pokemon
            tableView.reloadData()
            return
        }
        searchResults.removeAll { !$0.name.contains(searchText.lowercased())}
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // delegate is way by which objects pass info with each other
        // here i am specifying the type of info this search bar will pass will be
        // self ie.- an instance of PokemonListViewController
        searchBar.delegate = self
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                self.searchResults = self.pokemon
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        cell.textLabel?.text = capitalize(text: searchResults[indexPath.row].name)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemonSegue",
                let destination = segue.destination as? PokemonViewController,
                let index = tableView.indexPathForSelectedRow?.row {
            destination.url = searchResults[index].url
        }
    }
}
