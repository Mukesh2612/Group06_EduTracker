import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'category_data.dart';


class ApplyActivityScreen extends StatefulWidget {
  const ApplyActivityScreen({super.key});

  @override
  State<ApplyActivityScreen> createState() => _ApplyActivityScreenState();
}

class _ApplyActivityScreenState extends State<ApplyActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();

  String? selectedLevel;
  String? selectedGroup;
  String? selectedCategory;
  String? fileName;
  int? points;

  // Same palette as your app
  static const bg = Color(0xFFE8E9EB);
  static const light = Color(0xFFCCCDC6);
  static const mid = Color(0xFFACADA8);
  static const dark = Color(0xFF746D69);
  static const black = Color(0xFF262626);

  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  InputDecoration fieldStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: dark, fontWeight: FontWeight.w700),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: light),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: black, width: 1.5),
      ),
    );
  }

  ButtonStyle primaryBtn() {
    return ElevatedButton.styleFrom(
      backgroundColor: black,
      foregroundColor: bg,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> pickProofFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
      });
    }
  }

  void resetForm() {
    titleController.clear();
    setState(() {
      selectedLevel = null;
      selectedGroup = null;
      selectedCategory = null;
      points = null;
      fileName = null;
    });
  }

  List<String> get groupList {
    if (selectedLevel == null) return [];

    if (selectedLevel == "Department Level") {
      return departmentData.keys.toList();
    }
    return instituteData.keys.toList();
  }

  List<String> get categoryList {
    if (selectedLevel == null || selectedGroup == null) return [];

    if (selectedLevel == "Department Level") {
      return departmentData[selectedGroup]!.keys.toList();
    }
    return instituteData[selectedGroup]!.keys.toList();
  }

  void updatePoints(String? category) {
    if (selectedLevel == null || selectedGroup == null || category == null) {
      setState(() => points = null);
      return;
    }

    final p = selectedLevel == "Department Level"
        ? departmentData[selectedGroup]![category]
        : instituteData[selectedGroup]![category];

    setState(() => points = p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        title: const Text(
          "Apply Activity Points",
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // FORM CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: light),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Activity Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: black,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // TITLE
                    TextFormField(
                      controller: titleController,
                      decoration: fieldStyle("Activity Title"),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? "Enter activity title"
                          : null,
                    ),

                    const SizedBox(height: 14),

                    // LEVEL
                    DropdownButtonFormField<String>(
                      value: selectedLevel,
                      decoration: fieldStyle("Select Level"),
                      items: const [
                        DropdownMenuItem(
                          value: "Department Level",
                          child: Text("Department Level"),
                        ),
                        DropdownMenuItem(
                          value: "Institute Level",
                          child: Text("Institute Level"),
                        ),
                      ],
                      validator: (value) => value == null ? "Select level" : null,
                      onChanged: (value) {
                        setState(() {
                          selectedLevel = value;
                          selectedGroup = null;
                          selectedCategory = null;
                          points = null;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // GROUP
                    DropdownButtonFormField<String>(
                      value: selectedGroup,
                      decoration: fieldStyle("Select Group"),
                      items: groupList
                          .map(
                            (g) => DropdownMenuItem(
                          value: g,
                          child: Text(g),
                        ),
                      )
                          .toList(),
                      validator: (value) => value == null ? "Select group" : null,
                      onChanged: (value) {
                        setState(() {
                          selectedGroup = value;
                          selectedCategory = null;
                          points = null;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // CATEGORY
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: fieldStyle("Select Category"),
                      items: categoryList
                          .map(
                            (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ),
                      )
                          .toList(),
                      validator: (value) =>
                      value == null ? "Select category" : null,
                      onChanged: (value) {
                        setState(() => selectedCategory = value);
                        updatePoints(value);
                      },
                    ),

                    // POINTS BOX
                    if (points != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: light),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: black),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Points for this activity",
                                style: TextStyle(
                                  color: dark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              "$points",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // UPLOAD PROOF CARD
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: pickProofFile,
                child: Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: light),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: light),
                        ),
                        child: const Icon(
                          Icons.upload_file_rounded,
                          color: black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Upload Proof",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fileName ?? "PDF / JPG / PNG",
                              style: const TextStyle(
                                color: dark,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: dark,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: primaryBtn(),
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    if (fileName == null) {
                      msg("Please upload proof");
                      return;
                    }

                    msg("Application Sent to FA");
                    resetForm();
                  },
                  child: const Text(
                    "Submit Application",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Make sure your proof file is clear and valid.",
                style: TextStyle(color: mid, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
