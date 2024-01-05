import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hangman_app/utils.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String word = wordsList[Random().nextInt(wordsList.length)];
  List wrongGuesses = [];
  List guessedAlphabets = [];
  int status = 0;
  bool soundOn = true;
  List images = [
    "images/images0.png",
    "images/images1.png",
    "images/images2.png",
    "images/images3.png",
    "images/images4.png",
    "images/images5.png",
    "images/images6.png",
    "images/images7.png",
    "images/images8.png",
    "images/images9.png",
    "images/images10.png",
    "images/images11.png",
  ];

//barrierDismissible er til að 'play again' takkinn hverfi ekki þó ýtt sé útfyrri hann.
  openDialog(String title) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: 180,
            decoration: const BoxDecoration(color: Colors.purpleAccent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: retroStyle(25, Colors.white, FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width / 2,
                  child: TextButton(
                    //takki til að spilað aftur.
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        status = 0;
                        guessedAlphabets.clear();
                        word = wordsList[Random().nextInt(wordsList.length)];
                      });
                    },
                    child: Center(
                      child: Text(
                        "Play again",
                        style: retroStyle(20, Colors.black, FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// hér er séð um að jafn mörg strik birtast eins og stafir í orðinu sem varð fyrir valinu
// og að stafirnir birtist á sínum stað þegar giskað er rétt
  String handleText() {
    String displayWord = "";
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      if (guessedAlphabets.contains(char)) {
        displayWord += "$char ";
      } else {
        displayWord += "_ ";
      }
    }
    return displayWord;
  }

// athuga hvort það sé réttur eða rangur stafur sem er giskað á
// telja niður giskin sem eftir eru
// kassin sem birtist og býður þer að spila aftur með viðeigandi texta eftir því hvort það sé unnið eða tapað.
  checkLetter(String alphabet) {
    if (!word.contains(alphabet)) {
      setState(() {
        wrongGuesses.add(alphabet);
      });
    }
    if (word.contains(alphabet)) {
      setState(() {
        guessedAlphabets.add(alphabet);
      });
    } else if (status != 11) {
      setState(() {
        status += 1;
      });
    } else {
      openDialog("You lost");
      setState(() {
        guessedAlphabets.clear();
        wrongGuesses.clear();
      });
    }
    bool isWon = true;
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      if (!guessedAlphabets.contains(char)) {
        setState(() {
          isWon = false;
        });
        break;
      }
    }
    if (isWon) {
      setState(() {
        wrongGuesses.clear();
      });
      openDialog("Good job! You won");
    }
  }

//appbar - hangman
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black45,
        title: Text(
          "Hangman",
          style: retroStyle(30, Colors.white, FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
          //staðsetning myndanna, kalla fram myndina
          alignment: Alignment.center,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Image(
                width: 155,
                height: 200,
                image: AssetImage(images[status]),
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "${12 - status} guesses left",
                style: retroStyle(30, Colors.grey, FontWeight.w700),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                handleText(),
                style: retroStyle(35, Colors.white, FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20, //lyklaborðið
              ),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 5),
                childAspectRatio: 1.3,
                children: letters.map((alphabet) {
                  //stafir verða rauðir/grænir eftir því sem á við
                  //ekki hægt að klikka á sama staf oftar en 1x
                  Color charColor = guessedAlphabets.contains(alphabet)
                      ? Colors.lightGreenAccent
                      : wrongGuesses.contains(alphabet)
                          ? Colors.red
                          : Colors.white;
                  bool hasClickedLetter = guessedAlphabets.contains(alphabet) ||
                      wrongGuesses.contains(alphabet);
                  return InkWell(
                    onTap:
                        !hasClickedLetter ? () => checkLetter(alphabet) : null,
                    child: Center(
                      child: Text(
                        alphabet,
                        style: retroStyle(20, charColor, FontWeight.w700),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
