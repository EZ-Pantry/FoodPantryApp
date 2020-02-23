
import UIKit

class ItemCell: UICollectionViewCell {
    
    //View controller for the collection view cell
    //Inheritance of functions here
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(text: String) {
        //get label from firebase or title of image
        self.textLabel.text = text
    }
    
    func setImage(text: String){
        self.itemImageView.image = UIImage(named: text);
        //display the urled image
    }
}
