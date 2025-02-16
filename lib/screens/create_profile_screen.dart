import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedLivingWith;
  String? _selectedWorkStatus;
  String? _selectedFirstUseAge;
  String? _selectedLastUseDate;
  String? _selectedUseFrequency;
  String? _selectedAddictionKnowledge;

  double _importanceToQuit = 5.0;
  double _confidenceToQuit = 5.0;

  Map<String, bool> selectedMainCategories = {
    'Alkol': false,
    'Madde': false,
    'Kumar': false,
    'Oyun': false,
    'Diğer':false,
  };

  Map<String, bool> selectedSubCategories = {
    'Esrar': false,
    'Bonzai, Jamaican, Sentetik Kannabinoid': false,
    'Ekstazi': false,
    'Eroin': false,
    'Kokain': false,
    'Taş (Krak Kokain)': false,
    'Rohipnol, Rivotril (Roş) vb. haplar': false,
    'Uçucu Maddeler (Tiner, Bali, Gaz vb.)': false,
    'Çeşitli Haplar (Lyrica, Akineton, Tantum, Xanax vb.)': false,
    'Amfetamin Türevleri (Metamfetamin, Ice vb.)': false,
    'Diğer': false,
  };

  void _submitProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;

      if (_nameController.text.isEmpty || _surnameController.text.isEmpty || _ageController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen adınızı, soyadınızı ve yaşınızı girin!')),
        );
        return;
      }

      List<String> selectedDependencies = selectedMainCategories.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      List<String> selectedSubDependencies = selectedSubCategories.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      try {
        await FirebaseFirestore.instance.collection('profiles').doc(uid).set({
          'name': _nameController.text,
          'surname': _surnameController.text,
          'age': _ageController.text,
          'gender': _selectedGender ?? "",
          'livingWith': _selectedLivingWith ?? "",
          'workStatus': _selectedWorkStatus ?? "",
          'dependencyTypes': selectedDependencies,
          'subDependencyTypes': selectedSubDependencies,
          'importanceToQuit': _importanceToQuit,
          'confidenceToQuit': _confidenceToQuit,
          'firstUseAge': _selectedFirstUseAge ?? "",
          'lastUseDate': _selectedLastUseDate ?? "",
          'useFrequency': _selectedUseFrequency ?? "",
          'addictionKnowledge': _selectedAddictionKnowledge ?? "",
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla oluşturuldu!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil oluşturulurken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text(
          'Profil Oluştur',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Adınız', _nameController),
              _buildTextField('Soyadınız', _surnameController),
              _buildTextField('Yaşınız', _ageController, isNumber: true),
              _buildDropdown('Cinsiyet', ['Erkek', 'Kadın', 'Diğer'], (value) {
                setState(() {
                  _selectedGender = value;
                });
              }),
              _buildSingleChoiceSelection('Kimlerle Yaşıyorsunuz?', ['Yalnız', 'Aile', 'Arkadaş', 'Kurum'], _selectedLivingWith, (value) {
                setState(() {
                  _selectedLivingWith = value;
                });
              }),
              _buildSingleChoiceSelection('Çalışma Durumu', ['Çalışıyor', 'Çalışmıyor', 'Öğrenci'], _selectedWorkStatus, (value) {
                setState(() {
                  _selectedWorkStatus = value;
                });
              }),
              const SizedBox(height: 16),
              const Text(
                "Bağımlılık Türü",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              _buildMultiCheckboxWithSubOptions(),
              _buildSlider('Bırakma isteğiniz', _importanceToQuit, (value) {
                setState(() {
                  _importanceToQuit = value;
                });
              }),
              _buildSlider('Bırakmaya güveniniz', _confidenceToQuit, (value) {
                setState(() {
                  _confidenceToQuit = value;
                });
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text("Kaydet ve Devam Et", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items.map((String item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          label: value.toString(),
          onChanged: onChanged,
        ),
        Text('Değer: ${value.toStringAsFixed(1)}'),
      ],
    );
  }

  Widget _buildSingleChoiceSelection(String title, List<String> options, String? selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Column(
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selectedValue,
              onChanged: (value) {
                onChanged(value!);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiCheckboxWithSubOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...selectedMainCategories.keys.map((category) {
          return Column(
            children: [
              CheckboxListTile(
                title: Text(category),
                value: selectedMainCategories[category],
                onChanged: (val) {
                  setState(() {
                    selectedMainCategories[category] = val!;
                  });
                },
              ),
              if (category == "Madde" && selectedMainCategories[category] == true)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: selectedSubCategories.keys.map((subCategory) {
                      return CheckboxListTile(
                        title: Text(subCategory),
                        value: selectedSubCategories[subCategory],
                        onChanged: (val) {
                          setState(() {
                            selectedSubCategories[subCategory] = val!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
            ],
          );
        }).toList(),
      ],
    );
  }
}
