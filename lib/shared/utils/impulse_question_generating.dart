import 'dart:math';
import '../../model/impulse_question.dart';
import '../constant/impulse_question_data_model.dart';

// Function to pick 2 random questions from a given list
List<ImpulseQuestion> pickTwoRandomQuestions(List<ImpulseQuestion> questions) {
  if (questions.length <= 2)
    return List.from(questions); // if list is small, return all

  final random = Random();
  final selected = <ImpulseQuestion>[];

  while (selected.length < 2) {
    final question = questions[random.nextInt(questions.length)];
    if (!selected.contains(question)) {
      selected.add(question);
    }
  }

  return selected;
}

List<ImpulseQuestion> getQuestionToAsk() {
  List<ImpulseQuestion> list = [];
  list.addAll(pickTwoRandomQuestions(generQuestions));
  list.addAll(pickTwoRandomQuestions(moodQuestions));
  list.addAll(pickTwoRandomQuestions(eraQuestions));
  list.addAll(pickTwoRandomQuestions(pacingQuestions));
  list.addAll(pickTwoRandomQuestions(characterQuestions));
  list.addAll(pickTwoRandomQuestions(settingQuestions));
  list.addAll(pickTwoRandomQuestions(toneQuestions));
  list.addAll(pickTwoRandomQuestions(themeQuestions));
  return list;
}
