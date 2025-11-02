import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../model/flashcard.dart';
import 'WordScrambleProvider.dart';

class WordScrambleScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const WordScrambleScreen({super.key, required this.flashcards});

  @override
  State<WordScrambleScreen> createState() => _WordScrambleScreenState();
}

class _WordScrambleScreenState extends State<WordScrambleScreen> {
  late WordScrambleProvider provider;

  @override
  void initState() {
    super.initState();
    provider = WordScrambleProvider();
    provider.loadData(widget.flashcards); // Load flashcards and shuffle
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        appBar: AppBar(title: const Text('Sắp xếp chữ cái')),
        body: Consumer<WordScrambleProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Kéo chữ cái vào đúng vị trí:',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),

                  // DragTarget for placing letters
                  Wrap(
                    spacing: 8.0, // Horizontal space between the letters
                    runSpacing:
                        8.0, // Vertical space between the rows of letters
                    children: List.generate(provider.originalWord.length, (
                      index,
                    ) {
                      return DragTarget<LetterUnit>(
                        onAcceptWithDetails: (letterDetails) {
                          final letter = letterDetails.data;
                          final fromIndex = provider.userAnswer.indexOf(letter);
                          if (fromIndex != -1) {
                            provider.moveLetterBetweenTargets(
                              letter,
                              fromIndex,
                              index,
                            );
                          } else {
                            provider.acceptLetter(letter, index);
                          }
                        },
                        builder: (_, accepted, rejected) {
                          final letter =
                              index < provider.userAnswer.length
                                  ? provider.userAnswer[index]
                                  : null;
                          return Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.grey[200],
                            ),
                            child:
                                letter != null
                                    ? Draggable<LetterUnit>(
                                      data: letter,
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Text(
                                          letter.char,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Container(),
                                      child: Text(
                                        letter.char,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      onDragCompleted: () {
                                        provider.removeLetterFromAnswer(index);
                                      },
                                    )
                                    : null,
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 40),

                  // Draggable letters to be placed
                  Center(
                    child: Wrap(
                      spacing: 10, // Horizontal space between letters
                      runSpacing: 10, // Vertical space between wrapped rows
                      children:
                          provider.shuffledLetters.map((letter) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 100,
                              ), // Limit each letter box width
                              child: Draggable<LetterUnit>(
                                data: letter,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    letter.char,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _letterBox(letter.char),
                                ),
                                child: _letterBox(letter.char),
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed:
                        provider.submitted
                            ? () {
                              if (!provider.next()) {
                                provider.reset(); // Restart if no more words
                              }
                            }
                            : provider.submit,
                    child: Text(provider.submitted ? 'Từ khác' : 'Xác nhận'),
                  ),

                  const SizedBox(height: 20),

                  // Display result after submission
                  if (provider.submitted)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              provider.isCorrect
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  provider.isCorrect
                                      ? Colors.green
                                      : Colors.orange,
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              provider.isCorrect ? 'Chính xác!' : 'Sai rồi!',
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    provider.isCorrect
                                        ? Colors.green
                                        : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Từ gốc: ${provider.currentCard.question}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Nghĩa: ${provider.currentCard.answer}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),

                  // Dialog when retrying wrong answers
                  if (provider.isLast && provider.wrongCount > 0)
                    Builder(
                      builder: (context) {
                        Future.delayed(
                          Duration.zero,
                          () =>
                              Alert(
                                context: context,
                                type: AlertType.warning,
                                title: "Bạn có muốn làm lại các câu sai không?",
                                buttons: [
                                  DialogButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      provider.retryWrongQuestions();
                                    },
                                    color: Colors.blue,
                                    child: const Text(
                                      "Làm lại",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  DialogButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    color: Colors.red,
                                    child: const Text(
                                      "Không",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ).show(),
                        );
                        return const SizedBox.shrink(); // Return an empty widget
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _letterBox(String letter) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        letter,
        style: const TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }
}
