import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;
  var portfolioValue = 2331201.0.obs;
  var returnValue = 345406.0.obs;
  var returnPercentage = 17.39.obs;
  var pickedImage = Rxn<XFile>();
  final ImagePicker _picker = ImagePicker();

  void onTabChanged(int index) {
    selectedIndex.value = index;
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedImage.value = XFile(pickedFile.path);
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedImage.value = image;
    }
  }

  Future<void> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      pickedImage.value = XFile(pickedFile.path);
    }
  }

  void clearImage() {
    pickedImage.value = null;
  }

}
