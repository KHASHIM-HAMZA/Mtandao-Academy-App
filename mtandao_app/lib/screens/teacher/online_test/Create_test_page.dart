import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mtandao_app/providers/teacher_test_provider.dart';
import 'package:mtandao_app/model/questions_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/model/test_model.dart';

class CreateTestPage extends StatefulWidget {
  const CreateTestPage({super.key});

  @override
  State<CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends State<CreateTestPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ Keeps state alive

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _subjectCtrl = TextEditingController();
  final TextEditingController _durationCtrl = TextEditingController();
  String _selectedLevel = "O-Level";
  List<Question> _questions = [];

  void _addOrEditQuestion({Question? question, int? index}) async {
    final newQuestion = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddQuestionPage(question: question)),
    );
    if (newQuestion != null && newQuestion is Question) {
      setState(() {
        if (index != null) {
          _questions[index] = newQuestion; // edit
        } else {
          _questions.add(newQuestion); // add
        }
      });
    }
  }

  void _removeQuestion(int index) => setState(() => _questions.removeAt(index));

  Future<void> _submitTest() async {
    if (!_formKey.currentState!.validate() || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and add questions."),
        ),
      );
      return;
    }
    final provider = Provider.of<TeacherTestProvider>(context, listen: false);
    final test = TestModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleCtrl.text.trim(),
      subject: _subjectCtrl.text.trim(),
      level: _selectedLevel,
      duration: int.tryParse(_durationCtrl.text.trim()) ?? 30,
      questions: _questions,
      creator: "teacher123",
      createdAt: DateTime.now(),
      published: false,
    );
    bool success = await provider.createTest(test);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Test created successfully!" : "Failed to create test.",
        ),
      ),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = Provider.of<TeacherTestProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Test",
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 27, 88, 138),
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    Card(
                      color: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            Icon(Icons.add_task, color: Colors.white, size: 32),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Create New Test\nDesign auto-graded tests for your students",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(
                              labelText: "Test Title",
                              prefixIcon: Icon(Icons.title),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.isEmpty ? "Enter title" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _subjectCtrl,
                            decoration: const InputDecoration(
                              labelText: "Subject",
                              prefixIcon: Icon(Icons.subject),
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (v) => v!.isEmpty ? "Enter subject" : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedLevel,
                            decoration: const InputDecoration(
                              labelText: "Level",
                              prefixIcon: Icon(Icons.school),
                              border: OutlineInputBorder(),
                            ),
                            items:
                                ["Primary", "O-Level", "A-Level"]
                                    .map(
                                      (lvl) => DropdownMenuItem(
                                        value: lvl,
                                        child: Text(lvl),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (val) => setState(() => _selectedLevel = val!),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _durationCtrl,
                            decoration: const InputDecoration(
                              labelText: "Duration (minutes)",
                              prefixIcon: Icon(Icons.timer),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (v) => v!.isEmpty ? "Enter duration" : null,
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                "Questions (${_questions.length})", // Shows total count
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () => _addOrEditQuestion(),
                                icon: const Icon(Icons.add),
                                label: const Text("Add Question"),
                              ),
                            ],
                          ),
                          const Divider(),
                          ..._questions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final q = entry.value;
                            return Card(
                              color: Colors.grey[100],
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                title: Text(
                                  q.questionText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Type: ${q.type}"),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Correct Answer: ${q.correctAnswer}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _addOrEditQuestion(
                                            question: q,
                                            index: index,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removeQuestion(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _submitTest,
                              icon: const Icon(Icons.save),
                              label: const Text("Save Test"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class AddQuestionPage extends StatefulWidget {
  final Question? question;
  const AddQuestionPage({super.key, this.question});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionCtrl;
  late List<TextEditingController> _optionCtrls;
  String _correctAnswer = "";
  String _type = "mcq";
  File? _selectedMedia;

  @override
  void initState() {
    super.initState();
    _questionCtrl = TextEditingController(
      text: widget.question?.questionText ?? "",
    );
    _optionCtrls = List.generate(
      4,
      (i) => TextEditingController(
        text:
            widget.question != null && widget.question!.options.length > i
                ? widget.question!.options[i]
                : "",
      ),
    );
    _correctAnswer = widget.question?.correctAnswer ?? "";
    _type = widget.question?.type ?? "mcq";
    _selectedMedia =
        widget.question != null && widget.question!.mediaUrl != null
            ? File(widget.question!.mediaUrl!)
            : null;
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (var ctrl in _optionCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() => _selectedMedia = File(result.files.single.path!));
    }
  }

  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) return;
    if (_type == "mcq" && _correctAnswer.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select correct answer.")));
      return;
    }

    final question = Question(
      id: DateTime.now().millisecondsSinceEpoch,
      questionText: _questionCtrl.text.trim(),
      options:
          _type == "mcq"
              ? _optionCtrls
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .toList()
              : ["True", "False"],
      correctAnswer: _correctAnswer,
      type: _type,
      mediaUrl: _selectedMedia?.path,
    );

    Navigator.pop(context, question);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Question")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _questionCtrl,
                decoration: const InputDecoration(
                  labelText: "Question Text",
                  prefixIcon: Icon(Icons.question_mark),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter question" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: "Question Type",
                  prefixIcon: Icon(Icons.list),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "mcq",
                    child: Text("Multiple Choice"),
                  ),
                  DropdownMenuItem(
                    value: "true_false",
                    child: Text("True / False"),
                  ),
                ],
                onChanged: (val) => setState(() => _type = val!),
              ),
              const SizedBox(height: 12),
              if (_type == "mcq")
                Column(
                  children: List.generate(4, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TextFormField(
                        controller: _optionCtrls[i],
                        decoration: InputDecoration(
                          labelText: "Option ${i + 1}",
                          prefixIcon: const Icon(Icons.circle),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? "Enter option" : null,
                        onChanged: (v) {
                          setState(
                            () {},
                          ); // refresh dropdown when option changes
                        },
                      ),
                    );
                  }),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _correctAnswer.isEmpty ? null : _correctAnswer,
                decoration: const InputDecoration(
                  labelText: "Correct Answer",
                  prefixIcon: Icon(Icons.check),
                  border: OutlineInputBorder(),
                ),
                items:
                    _type == "mcq"
                        ? _optionCtrls
                            .map((ctrl) => ctrl.text.trim())
                            .where((text) => text.isNotEmpty)
                            .map(
                              (text) => DropdownMenuItem(
                                value: text,
                                child: Text(text),
                              ),
                            )
                            .toList()
                        : const [
                          DropdownMenuItem(value: "True", child: Text("True")),
                          DropdownMenuItem(
                            value: "False",
                            child: Text("False"),
                          ),
                        ],
                onChanged: (val) => setState(() => _correctAnswer = val ?? ""),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _selectedMedia == null
                      ? "Attach Image/PDF (Optional)"
                      : "Attached: ${_selectedMedia!.path.split('/').last}",
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveQuestion,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Question"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
