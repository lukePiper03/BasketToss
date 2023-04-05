// Libraries
import processing.sound.*;

// Floats
float xPos, yPos, xVel, yVel, accel, boardLength, bucketX, bucketY, boardHeight, give, wind;
float ballLength = 57;

// Interger values
int score, highScore;
int messageType = 0;
int failMessage = 0;
int count = 0;

// Arc
float x1, y1;

// Moving hoop for hard mode
float bucketSpeed = 2.0;

// Booleans
boolean shooting, backboard, windNow, reset, hardMode;

// Mode Types
String modeType = "menu";
String ballType = "basketball";
String hoopType = "basketballHoop";

// Menu Images
PImage menuPic;
PImage title;
PImage button;
PImage arrow;

// Hoop Images
PImage hoop;
PImage woodBucket;
PImage backboardPic;

// Ball images
PImage menuBasketball;
PImage basketball;
PImage football;
PImage tennisBall;

// Pixelated font
PFont font;

// Music
SoundFile music;

// For menu bouncing ball movement in the menu
float x = 50;
float y = 100;
float vx;
float vy;

float ax = 0;
float ay = 1;

// Arrays for comments
String[] scoreText = new String[] {"Making it rain", "Putting on a Clinic", "Splish Splash Splosh", "Dropping Dimes", "Baller"};
String[] missText = new String[] {"Brick", "Aiiirrrrrrr Ball", "Thats weak"};

// Multi threading
void loadMusic() {
  // Loading music
  music = new SoundFile(this, "audio/normal.wav");
  music.loop();
  // fade in audio
  for (float vol=0; vol<1; vol+=0.1) {
    //music.amp(vol);
    delay(200);
  }
}


void setup() {

  // For menu ball
  vx = 3;
  vy = 1;

  // Size
  size (1000, 600);

  // Position and intital speed of ball
  xPos = 50;
  yPos = 400;
  yVel = .1;
  xVel = .1;
  accel = 1;
  boardHeight = 150;

  // Play music with multithreading
  thread("loadMusic");

  // Keep ball still
  shooting = false;

  // Set random position of bucket
  bucketX = random(500, 830);
  bucketY = random(200, 500);
  backboard = false;
  give = 20;

  // Initialise scores
  score = 0;
  highScore = 0;

  // Wind
  wind = random(-.2, .3);
  windNow = false;
  reset = false;

  // Load hoop images
  hoop = loadImage("images/hoopsy.png");
  woodBucket = loadImage("images/bucket.png");

  // Load ball images
  basketball = loadImage("images/basketball.png");
  football = loadImage("images/football.png");
  tennisBall = loadImage("images/tennisball.png");

  // Other images
  menuPic = loadImage("images/menuPic.png");
  title = loadImage("images/title.png");
  button = loadImage("images/button.png");
  menuBasketball = loadImage("images/menuBasketball.png");
  backboardPic = loadImage("images/backboard.png");
  arrow = loadImage("images/arrow.png");

  // Load font
  font = createFont("Pixeboy-z8XGD.ttf", 16);
  textFont(font);
}

void draw() {
  // Call method for current modeType
  if (modeType == "menu") {
    menu();
  } else if (modeType == "customise") {
    customise();
  } else if (modeType == "play") {
    play();
  }
}

void drawArc() {

  // Set variables
  float x = xPos;
  float y = yPos;
  float arcxvel = xVel;
  float arcyvel = yVel;

  // Set a maximum on x and y speeds
  if (arcxvel > 20) {
    arcxvel = 20;
  }
  if (arcyvel >25) {
    arcyvel = 25;
  }

  noStroke();
  fill(255);

  // Draw circles for arc
  for (float i=1; i<18; i++) {

    x+= arcxvel;
    arcyvel -= accel;
    y -= arcyvel;
    if (i % 2 == 0) {
      circle(x, y, 15 - i/2);
    }
  }
}

void play() {

  // Setup variables
  image(menuPic, -10, 0, 1010, 600);

  textSize(20);
  fill(0);
  boardLength = 150;

  // Set new highscore
  if (score > highScore) {
    highScore = score;
  }

  // Turn on wind
  if (windNow == true) {

    // Add wind to x movement
    xVel += wind;

    // Make 2dp
    String printWind = String.format("WIND: %.2f", wind*10);

    // Print wind amount
    text(printWind + " km/h", 10, height - 50);

    // Draw arrow
    if (wind > 0) {
      image(arrow, 140, height - 80, 50, 50);
    } else {
      // Flip arrow if wind is negative
      pushMatrix();
      translate(190, height - 80);
      scale(-1, 1);
      image(arrow, 0, 0, 50, 50);
      popMatrix();
    }
  }

  // Print scores
  text("HIGHSCORE: " + highScore, 10, height - 30);   
  text("SCORE: " + score, 10, height - 10);

  // Let user know the key boad controls available
  text("Controls: ", 10, 20);
  text("Press 'w' to turn wind ON / OFF", 10, 40);
  text("Press 'p' to pause", 10, 60);
  text("Press 'r' to reset score", 10, 80);
  text("Press 'h' to turn hardMode ON / OFF", 10, 100);

  // Cool comments
  fill(0);
  textSize(40);
  if (score % 3 == 0 && score > 0) {
    text(scoreText[messageType], 300, height - 10);
  }

  // Bad comment
  if (score == 0 && count > 0) {
    text(missText[failMessage], 300, height - 10);
  }

  // --------> Draw Hoops <------- //

  // Basketball Hoop
  if (hoopType == "basketballHoop") {
    image(hoop, bucketX, bucketY, boardLength, 100);
  }

  // Wood Bucket
  else if (hoopType == "woodBucket") {
    image(woodBucket, bucketX, bucketY, boardLength, 100);
  }
  fill(0);

  // Call ball
  ball();
}

void ball() {

  // Turn on hard mode if true
  if (hardMode == true) {

    // Make hoop start going down if gone too high
    if (bucketY - boardLength <= 50) {
      bucketSpeed = -bucketSpeed;
    }

    // Make hoop start going up if gone too low
    if (bucketY > 500) {
      bucketSpeed = -bucketSpeed;
    }
    // Move hoop
    bucketY += bucketSpeed*((score+1)*0.5);
  }

  /* ---------- Bouncing against walls -------- */

  // Bounce against right wall
  if (xPos >= width) {
    xVel = -xVel;
  }

  // Bounce against left wall
  if (xPos - (ballLength/2) <= 0) {
    xVel = -xVel;
  }

  // Bounce ball against top wall
  if (yPos <= 0) {
    yVel = -yVel;
  }

  // If ball hits ground reset
  if (yPos >= height) {
    failMessage = (int)random(0, 3);
    count += 1;
    reset = true;
  }

  // Set a maximum on x and y speeds
  if (xVel > 20) {
    xVel = 20;
  }
  if (yVel >25) {
    yVel = 25;
  }

  // Backboard
  image(backboardPic, bucketX+boardLength, bucketY - boardHeight, 20, boardLength+50);

  // Not shooting
  if (shooting == false) {
    // Set x and y velocity
    xVel = (mouseX-width/5)/10;
    yVel = (400 - mouseY)/7;

    // Draw ball arc
    drawArc();
  }
  // Shooting
  if (shooting == true) {

    // If hit backboard
    if (backboard) {
      // Drop into hoop
      yVel -= 5 ;
      xPos -= xVel;
      give = 40;
    } else {
      xPos+= xVel;
    }
    yVel -= accel;
    yPos -= yVel;
  }

  // Hitting backboard
  if (xPos > bucketX-20 + boardLength && xPos < bucketX + boardLength + 30 && yPos > bucketY -boardHeight-5 && yPos < bucketY) {
    backboard = true;
  }

  // Bounce off edge of rim
  if (xPos>bucketX-10 && xPos<bucketX+20 && yPos < (bucketY + give) && yPos > (bucketY -10)) {
    yVel = -yVel;
    xVel = -xVel;
  }

  // If ball hits the bucket
  if (xPos>bucketX+20 && xPos<(bucketX+boardLength) && yPos < (bucketY + give) && yPos > (bucketY -10) && yVel < 1 ) {

    // Reset position of ball
    xPos = 50;
    yPos = 400;

    // Reset vel
    yVel = .1;
    xVel = .1;
    accel = 1;

    // Set states
    shooting = false;

    // Find new random position for bucked and backboard
    bucketX = random(500, 830);
    bucketY = random(200, 500);

    // Set new wind value
    wind = random(-.2, .3);

    // Add to score
    backboard = false;
    score += 1;
    messageType = (int)random(0, 5);
  }

  // Draw circle
  imageMode(CENTER);
  // Basketball
  if (ballType == "basketball") {
    image(menuBasketball, xPos, yPos, ballLength, ballLength);
  }

  // Football
  else if (ballType == "football") {
    image(football, xPos, yPos, ballLength*1.5, ballLength*1.5);
  }

  // Tennis Ball
  else if (ballType == "tennis ball") {
    image(tennisBall, xPos, yPos, ballLength, ballLength);
  }
  imageMode(CORNER);

  // Reset if reset true
  if (reset == true) {
    reset();
  }
}

void reset() {

  // Reset everything
  xPos = 50;
  yPos = 400;
  yVel = .1;
  xVel = .1;
  accel = 1;
  shooting = false;
  bucketX = random(500, 830);
  bucketY = random(200, 500);
  wind = random(-.2, .3);
  backboard = false;
  boardHeight = 150;
  give = 15;
  score = 0;   
  reset = false;
}

void menu() {

  // Background
  image(menuPic, -10, 0, 1010, 600);

  // Draw bouncing basketball
  image(menuBasketball, x, y, 1.5*ballLength, 1.5*ballLength);

  // Title
  image(title, 100, 150);

  // Play and Customise buttons
  image(button, 120, 450, 350, 100);
  image(button, 500, 450, 350, 100);

  // Text for buttons
  fill(0);
  textSize(60);
  text("Play Ball", 175, 515);
  text("Customize", 550, 515);

  // Making the ball bounce and have gravity
  vx = vx + ax/2;
  vy = vy + ay/2;
  x = x + vx;
  y = y + vy;
  vx = vx + ax/2;
  vy = vy + ay/2;

  // Bounces off right wall
  if (x+(ballLength*1.5) > width) {
    vx = -vx;
  }

  // Bounces off left wall
  if (x < 0) {
    vx = -vx;
  }

  // Bounces off floor
  if (y+(ballLength*1.5) > height) {
    vy = -vy;
  }
}

void customise() {

  image(menuPic, -10, 0, 1010, 600);
  textSize(20);
  fill(0);

  // Let user know what is currently selected
  text("Currently selected: ", 20, 550);
  text("Currently selected: ", 640, 550);
  fill(228, 154, 80);
  textSize(25);
  text(ballType, 195, 550);
  text(hoopType, 815, 550);

  // Titles
  textSize(50);
  fill(0);
  text("Balls: ", 100, 100);
  text("Hoops: ", 700, 100);

  // Done button
  fill(228, 154, 80);
  image(button, 350, 475, 260, 100);
  textSize(60);
  fill(0);
  text("OK", 450, 540);

  // Balls
  image(menuBasketball, 100, 140, ballLength*1.5, ballLength*1.5);
  image(football, 100, 250, ballLength*1.8, ballLength*1.8);
  image(tennisBall, 90, 340, ballLength*2, ballLength*2);

  // Hoops
  image(hoop, 680, 120, 150, 150);
  image(woodBucket, 700, 300, 100, 100);
}

void mouseClicked() {

  // Play
  if (modeType == "play") {
    shooting = true;
  }

  // Menu
  else if (modeType == "menu") {

    // Go to Play
    if (mouseX > 120 && mouseX < 470 && mouseY > 450 && mouseY < 550) {
      modeType = "play";
    }

    // Go to customize
    if (mouseX > 500 && mouseX < 850 && mouseY > 450 && mouseY < 550) {
      modeType = "customise";
    }
  }

  // Customize
  else if (modeType == "customise") {

    // User clicking done
    if (mouseX > 350 && mouseX < 610 && mouseY > 475 && mouseY < 575) {
      modeType = "menu";
    }

    // -------> User clicking balls <------- //

    // Basketball
    if (mouseX > 100 && mouseX < 186 && mouseY > 140 && mouseY < 226) {
      ballType = "basketball";
    }

    // Football
    else if (mouseX > 100 && mouseX < 186 && mouseY > 250 && mouseY < 336) {
      ballType = "football";
    }

    // Tennis Ball
    else if (mouseX > 90 && mouseX < 204 && mouseY > 340 && mouseY < 434) {
      ballType = "tennis ball";
    }

    // -------> User clicking hoops <------- //

    // Basketball hoop
    if (mouseX > 700 && mouseX < 800 && mouseY > 150 && mouseY < 250) {
      hoopType = "basketballHoop";
    }

    // Wood Bucket
    else if (mouseX > 700 && mouseX < 800 && mouseY > 300 && mouseY < 400) {
      hoopType = "woodBucket";
    }
  }
}

// Use can press keys for different controls
void keyPressed() {

  // If r pressed reset current game
  if (key == 'r') {
    reset = true;
  }

  // Turn on/off wind
  if (key == 'w') {
    windNow = !windNow;
  } 

  // Go back to menu
  if (key == 'p') {
    modeType = "menu";
  }

  // Turn on/off hard mode
  if (key == 'h') {
    hardMode = !hardMode;
    reset = true;
  }
}
