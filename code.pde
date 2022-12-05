import java.util.Arrays;
import java.util.List;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
String[] data; // contains all the words sorted by count
List<String> words = new ArrayList<String>(); // The initial data sorted by count with the numbers removed
List<String> topFourWords = new ArrayList<String>(); // Keep track of the top four words based on the user's input
int upperWordLimit = 20000;
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 100; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;

String currentWord = "";
float offset = 20;

String[] firstStopRow = {"the", "of", "and", "a", "to"};
String[] secondStopRow = {"in", "is", "you", "that", "it"};
String[] firstRow = {"a", "b", "c", "d", "e", "f", "g"};
String[] secondRow = {"h", "i", "j", "k", "l", "m", "n"};
String[] thirdRow = {"o", "p", "q", "r", "s", "t", "u"};
String[] fourthRow = {"v", "w", "x", "y", "z"};
String[] fifthRow = {"Space", "back"};

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory  
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing

  data = loadStrings("count_1w.txt");
  for (int i = 0; i < upperWordLimit; i++) {
    String[] wordAndCount = splitTokens(data[i]);
    String word = wordAndCount[0];
    words.add(word);
  }
 

 
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"

  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label
    
    textSize(11);
    if (topFourWords.size() == 4) {
      drawFirstAutoRow();
      drawSecondAutoRow();    
    } else if (topFourWords.size() == 2) {
      drawFirstAutoRow();
    } else {
      drawFirstStopRow();
      drawSecondStopRow();
    }
    
    
    drawFirstRow();
    drawSecondRow();
    drawThirdRow();
    drawFourthRow();
    drawFifthRow();
  }
}

void drawFirstAutoRow()
{
  for (int i = 0; i < 2; i++) {
    fill(255, 255, 255);
    stroke(0, 0, 0);
    rect(width/2-sizeOfInputArea/2 + i*sizeOfInputArea/2, height/2 - 50, sizeOfInputArea/2, sizeOfInputArea/7);
    noStroke();
    fill(0, 0, 0);
    text(topFourWords.get(i), width/2-sizeOfInputArea/2 + i*sizeOfInputArea/2, height/2 - 50 + sizeOfInputArea/8);    
  }
}

void drawSecondAutoRow()
{
  for (int i = 0; i < 2; i++) {
    fill(255, 255, 255);
    stroke(0, 0, 0);
    rect(width/2-sizeOfInputArea/2 + i*sizeOfInputArea/2, height/2 - 35, sizeOfInputArea/2, sizeOfInputArea/7);
    noStroke();
    fill(0, 0, 0);
    text(topFourWords.get(i + 2), width/2-sizeOfInputArea/2 + i*sizeOfInputArea/2, height/2 - 35 + sizeOfInputArea/8);    
  }
}


void drawFirstStopRow()
{
  for (int i = 0; i < 5; i++) {
    fill(255, 255, 255);
    stroke(0, 0, 0);
    rect(width/2-sizeOfInputArea/2 + i*sizeOfInputArea/5, height/2 - 50, sizeOfInputArea/5, sizeOfInputArea/7);
    noStroke();
    fill(0, 0, 0);
    text(firstStopRow[i], width/2-sizeOfInputArea/2 + i*sizeOfInputArea/5, height/2 - 50 + sizeOfInputArea/8);    
  }
}

void drawSecondStopRow()
{
  for (int i = 0; i < 5; i++) {
    fill(255, 255, 255);
    stroke(0, 0, 0);
    rect(width/2-sizeOfInputArea/2 + i*sizeOfInputArea/5, height/2 - 35, sizeOfInputArea/5, sizeOfInputArea/7);
    noStroke();
    fill(0, 0, 0);
    text(secondStopRow[i], width/2-sizeOfInputArea/2 + i*sizeOfInputArea/5, height/2 - 35 + sizeOfInputArea/8);    
  }
}


void drawFirstRow()
{
  for (int i = 0; i < 7; i++) {
    fill(255, 255, 255);
    stroke(0, 0, 0);
    rect(width/2-sizeOfInputArea/2 + i*sizeOfInputArea/7, height/2 - offset, sizeOfInputArea/7, sizeOfInputArea/7);
    noStroke();
    fill(0, 0, 0);
    text(firstRow[i], width/2-sizeOfInputArea/2 + i*sizeOfInputArea/7 + 3, height/2 - offset + sizeOfInputArea/8);    
  }
}

void drawSecondRow()
{
  for (int i = 0; i < 7; i++) {
    fill(255, 255, 255);
    stroke(0, 0, 0);
    rect(width/2-sizeOfInputArea/2 + i*sizeOfInputArea/7, height/2 - offset + sizeOfInputArea/7, sizeOfInputArea/7, sizeOfInputArea/7);
    noStroke();
    fill(0, 0, 0);
    text(secondRow[i], width/2-sizeOfInputArea/2 + i*sizeOfInputArea/7 + 3, height/2 - offset + sizeOfInputArea/7 + sizeOfInputArea/8);     
  }
}

void drawThirdRow()
{
  for (int i = 0; i < 7; i++) {
    fill(255, 255, 255);
    stroke(0, 0, 0);
    rect(width/2-sizeOfInputArea/2 + i*sizeOfInputArea/7, height/2 - offset + sizeOfInputArea*2/7, sizeOfInputArea/7, sizeOfInputArea/7);;
    noStroke();
    fill(0, 0, 0);
    text(thirdRow[i], width/2-sizeOfInputArea/2 + i*sizeOfInputArea/7 + 3, height/2 - offset + sizeOfInputArea*2/7 + sizeOfInputArea/8);   
  }
}

void drawFourthRow()
{
  for (int i = 0; i < 5; i++) {
    fill(255, 255, 255);
    stroke(0, 0, 0);
    rect(width/2-sizeOfInputArea/2 + i*sizeOfInputArea/7, height/2 - offset + sizeOfInputArea*3/7, sizeOfInputArea/7, sizeOfInputArea/7);
    noStroke();
    fill(0, 0, 0);
    text(fourthRow[i], width/2-sizeOfInputArea/2 + i*sizeOfInputArea/7 + 3, height/2 - offset + sizeOfInputArea*3/7 + sizeOfInputArea/8);       
  }
}

void drawFifthRow()
{
  fill(255, 255, 255);
  stroke(0, 0, 0);
  rect(width/2-sizeOfInputArea/2 + 0*sizeOfInputArea/7, height/2 - offset + sizeOfInputArea*4/7, sizeOfInputArea/7 + 35, sizeOfInputArea/7);
  noStroke();
  fill(0, 0, 0);
  text(fifthRow[0], width/2-sizeOfInputArea/2 + 0*sizeOfInputArea/7 + 3, height/2 - offset + sizeOfInputArea*4/7 + sizeOfInputArea/8);
  fill(255, 255, 255);
  stroke(0, 0, 0);
  rect(width/2-sizeOfInputArea/2 + 1*sizeOfInputArea/7 + 35, height/2 - offset + sizeOfInputArea*4/7, sizeOfInputArea/7 + 35, sizeOfInputArea/7);
  noStroke();
  fill(0, 0, 0);
  text(fifthRow[1], width/2-sizeOfInputArea/2 + 1*sizeOfInputArea/7 + 3 + 35, height/2 - offset + sizeOfInputArea*4/7 + sizeOfInputArea/8); 

}



//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}



void pressFirstStopRow() {
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2 - 50, sizeOfInputArea, sizeOfInputArea/7))
  {
    int i = int ((mouseX - (width/2 - sizeOfInputArea/2)) / (sizeOfInputArea/5));
    if (i < 5) {
      currentTyped += firstStopRow[i];
    }    
  }
}

void pressSecondStopRow() {
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2 - 35, sizeOfInputArea, sizeOfInputArea/7))
  {
    int i = int ((mouseX - (width/2 - sizeOfInputArea/2)) / (sizeOfInputArea/5));
    if (i < 5) {
      currentTyped += secondStopRow[i];
    }    
  }  
}

void pressFirstRow() {
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2 - offset, sizeOfInputArea, sizeOfInputArea/7))
  {
    int i = int ((mouseX - (width/2 - sizeOfInputArea/2)) / (sizeOfInputArea/7));
    if (i < 7) {
      currentTyped += firstRow[i];
      currentWord += firstRow[i];
    }
  }
}

void pressSecondRow() {
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2 - offset + sizeOfInputArea/7, sizeOfInputArea, sizeOfInputArea/7))
  {
    int i = int ((mouseX - (width/2 - sizeOfInputArea/2)) / (sizeOfInputArea/7));
    if (i < 7) {
      currentTyped += secondRow[i];
      currentWord += secondRow[i];
    }    
  }
}

void pressThirdRow() {
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2 - offset + sizeOfInputArea*2/7, sizeOfInputArea, sizeOfInputArea/7))
  {
    int i = int ((mouseX - (width/2 - sizeOfInputArea/2)) / (sizeOfInputArea/7));
    if (i < 7) {
      currentTyped += thirdRow[i];
      currentWord += thirdRow[i];
    }        
  }
}

void pressFourthRow() {
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2 - offset + sizeOfInputArea*3/7, sizeOfInputArea, sizeOfInputArea/7))
  {
    int i = int ((mouseX - (width/2 - sizeOfInputArea/2)) / (sizeOfInputArea/7));
    if (i < 5) {
      currentTyped += fourthRow[i];
      currentWord += fourthRow[i];
    }     
  }
}

void pressFifthRow() {
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2 - offset + sizeOfInputArea*4/7, sizeOfInputArea, sizeOfInputArea/7))
  {
    int i = int ((mouseX - (width/2 - sizeOfInputArea/2)) / (sizeOfInputArea/2));
    String curLetter =  fifthRow[i];
    
    if (curLetter == "Space") {
      currentTyped += " ";
      currentWord = "";    
    }
      
    else {
      if (currentTyped.length()>0) {
        currentTyped = currentTyped.substring(0, currentTyped.length()-1);
      }
      if (currentWord.length() > 0) {
        currentWord = currentWord.substring(0, currentWord.length()-1);
      }
    } 
  }
}

void recomputeAutoWords() {
 topFourWords.clear();
 if (currentWord != "") {
   words.stream()
     .filter(word -> word.startsWith(currentWord))
     .limit(4)
     .forEach(word -> topFourWords.add(word)); 
 }
}

void pressFirstAutoRow() {
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2 - 50, sizeOfInputArea, sizeOfInputArea/7))
  {
    int i = int ((mouseX - (width/2 - sizeOfInputArea/2)) / (sizeOfInputArea/2));
    String word = topFourWords.get(i);
    currentTyped += word.substring(currentWord.length(), word.length());
    currentWord = "";     
  }  
}

void pressSecondAutoRow() {
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2 - 35, sizeOfInputArea, sizeOfInputArea/7))
  {
    int i = int ((mouseX - (width/2 - sizeOfInputArea/2)) / (sizeOfInputArea/2));
    String word = topFourWords.get(i + 2);
    currentTyped += word.substring(currentWord.length(), word.length());
    currentWord = "";     
  }  
}
    

void mousePressed()
{
  
  if (topFourWords.size() == 4) {
    pressFirstAutoRow();
    pressSecondAutoRow();    
  } else if (topFourWords.size() == 2) {
    pressFirstAutoRow();
  } else {
    pressFirstStopRow();
    pressSecondStopRow();
  }  


  pressFirstRow();
  pressSecondRow();
  pressThirdRow();
  pressFourthRow();
  pressFifthRow();
  
  recomputeAutoWords();
 
  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}





//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
