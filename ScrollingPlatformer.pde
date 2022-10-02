/*
  Scrolling Platformer Lab:
  
  Add scrolling ability to the player. 
  
  For more detail, see the tutorial: 
  Scrolling: https://www.youtube.com/watch?v=y4smwQ794_M
  
  
  Complete the code as indicated by the comments.
  Do the following:
  1) You'll need implement the method scroll() below. Use the view_x and view_y variables
  already declared and initialized. 
  2) Call scroll() in draw().
  See the comments below for more details. 
 
*/

import processing.sound.*;
SoundFile music;

final static float MOVE_SPEED = 4;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = .6;
final static float JUMP_SPEED = 14; 

final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 80;
final static float VERTICAL_MARGIN = 150;
final static int NEUTRAL_FACING = 0; 
final static int RIGHT_FACING = 1; 
final static int LEFT_FACING = 2; 
final static float COIN_SCALE = 0.4;


final static float WIDTH = SPRITE_SIZE * 16;
final static float HEIGHT = SPRITE_SIZE * 21;
final static float GROUND_LEVEL = (SPRITE_SIZE*36) - SPRITE_SIZE;
final static float start = HEIGHT - SPRITE_SIZE;


//declare global variables
Player player;
Enemy enemy;
Sprite fg;
PImage dirt, crate, red_brick, brown_brick, spider, c, p, background, f, snow, ice, stone;
ArrayList<Sprite> platforms;
ArrayList<Enemy> enemies; 
ArrayList<Sprite> coins; 

ArrayList<String> arrows;

int score;
int lives;
boolean isGameOver;
boolean size;


float view_x;
float view_y;


//initialize them in setup().
void setup(){
  size(1200, 900);
  imageMode(CENTER);
  //player = new Sprite("player.png", 0.8);
  p = loadImage("player.png");
  player = new Player(p, 0.8);
  player.change_y = start;
  player.center_x = 100;

  
  music = new SoundFile(this, "SuperMario.mp3");
  music.play();
  
  
  coins = new ArrayList<Sprite>();
  enemies = new ArrayList<Enemy>();
  platforms = new ArrayList<Sprite>();
  
  arrows = new ArrayList<>();
  

  view_x = 0;
  view_y = 0;
  
  c = loadImage("gold1.png");
  // initialize score
  score = 0;
  lives = 3;
  isGameOver = false;
  size = true;
  
  
  background = loadImage("back_grd.jpg");
  background.resize(1200,900);
 
  red_brick = loadImage("red_brick.png");
  dirt = loadImage("dirt.png");
  snow = loadImage("snow.png");
  ice = loadImage("ice.jpg");
  stone = loadImage("stone.png");

  
  spider = loadImage("spider_walk_right1.png");
  brown_brick = loadImage("brown_brick.png");
  crate = loadImage("crate.png");
    
  createPlatforms("map.csv");
  
 
}

// modify and update them in draw().
void draw(){
  background(background);
   // call scroll here. Need to call scroll first!
  scroll();
  
  displayAll();
  
  if(!isGameOver){
    updateAll();
    collectCoins();
    checkDeath();  
  }
  

  
} 

void displayAll(){

  for(Sprite s: platforms)
    s.display();
    
    
  for(Sprite c: coins){
    c.display();
  }
  
  for(Enemy e: enemies){
     e.display();
  }
  player.display();
  //try{
  //  if (arrows.get(arrows.size()-1) == "RIGHT")
  //    player.change_x = MOVE_SPEED;
  //  else if (arrows.get(arrows.size()-1) == "LEFT")
  //   player.change_x = MOVE_SPEED;
  //  else
  //    player.change_x = 0;
  //} catch (Exception e) {
  //  player.change_x = 0;
  //}
  
  fill(255, 0, 0);
  textSize(32);
  text("Coins:" + score, view_x + 50, view_y + 50);
  text("Lives:" + player.lives, view_x + 50, view_y + 100);
  
  if(isGameOver){
    fill(0,0,255);
    music.stop();
    text("Game Over!", view_x + width/2 - 100, view_y + height/2);
    if(player.lives == -1){
      player.lives++;
      text("You lose!", view_x + width/2 - 100, view_y + height/2 + 50);
    }
    else{
      text("You win!", view_x + width/2 - 100, view_y + height/2 + 50);
    }
    text("Press SPACE to restart!", view_x + width/2 - 100, view_y + height/2 + 100);
  }


  
}

void updateAll(){

  player.updateAnimation();
  resolvePlatformCollisions(player, platforms);
  
  for(Sprite c: coins){
    ((AnimatedSprite)c).updateAnimation();
  }

  for(Enemy e: enemies){
     e.update();
     e.updateAnimation();
  }
  
  collectCoins();
  checkDeath();

  
}

void checkDeath(){
  boolean collideEnemy = false; 
  ArrayList<Enemy> collision_list = checkCollisionList1(player, enemies);
  if(collision_list.size() > 0){
    collideEnemy = true;
  }
  boolean fallOffCLiff = (player.getBottom() > GROUND_LEVEL);
  if(collideEnemy || fallOffCLiff){
    player.lives--;
    if(player.lives == 0){
      isGameOver = true;
    }
    else{
      player.center_x = 100;
      player.setBottom(start);
    }
  }
}


void collectCoins(){
  ArrayList<Sprite> collision_list = checkCollisionList(player, coins);
  if(collision_list.size() > 0){
    for(Sprite coin: collision_list){
       coins.remove(coin);
       score++;
    }
  }
  if(coins.size() == 0){
    isGameOver = true;
  }
}

void scroll(){
  
  // create and initialize left_boundary variable
  // Hint: left_boundary = view_x + LEFT_MARGIN
  // compute x-coordinate of right boundary
  // if player's right passed this boundary, update view_x
  float right_boundary = view_x + width - RIGHT_MARGIN;
  if(player.getRight() > right_boundary){
    view_x += player.getRight() - right_boundary;
  }
  // compute x-coordinate of left boundary
  // if player's left passed this boundary, update view_x

  float left_boundary = view_x + LEFT_MARGIN;
  if(player.getLeft() < left_boundary){
    view_x -= left_boundary - player.getLeft();
  }
  // compute y-coordinate of bottom boundary
  // if player's bottom passed this boundary, update view_y
  float bottom_boundary = view_y + height - VERTICAL_MARGIN;
  if(player.getBottom() > bottom_boundary){
    view_y += player.getBottom() - bottom_boundary;
  }
   float top_boundary = view_y + VERTICAL_MARGIN;
   if(player.getTop() < top_boundary){
     view_y -= top_boundary - player.getTop();
   }
   

  translate(-view_x, -view_y);


}


// returns true if sprite is one a platform.
public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls){
  // move down say 5 pixels
  s.center_y += 5;

  // check to see if sprite collide with any walls by calling checkCollisionList
  ArrayList<Sprite> collision_list = checkCollisionList(s, walls);
  
  // move back up 5 pixels to restore sprite to original position.
  s.center_y -= 5;
  
  // if sprite did collide with walls, it must have been on a platform: return true
  // otherwise return false.
  return collision_list.size() > 0; 
}


// Use your previous solutions from the previous lab.

public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls){
  // add gravity to change_y of sprite
  s.change_y += GRAVITY;
  
  // move in y-direction by adding change_y to center_y to update y position.
  s.center_y += s.change_y;
  
  // Now resolve any collision in the y-direction:
  // compute collision_list between sprite and walls(platforms).
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  
  /* if collision list is nonempty:
       get the first platform from collision list
       if sprite is moving down(change_y > 0)
         set bottom of sprite to equal top of platform
       else if sprite is moving up
         set top of sprite to equal bottom of platform
       set sprite's change_y to 0
  */
  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_y > 0){
      s.setBottom(collided.getTop());
    }
    else if(s.change_y < 0){
      s.setTop(collided.getBottom());
    }
    s.change_y = 0;
  }

  // move in x-direction by adding change_x to center_x to update x position.
  s.center_x += s.change_x;
  
  // Now resolve any collision in the x-direction:
  // compute collision_list between sprite and walls(platforms).   
  col_list = checkCollisionList(s, walls);

  /* if collision list is nonempty:
       get the first platform from collision list
       if sprite is moving right
         set right side of sprite to equal left side of platform
       else if sprite is moving left
         set left side of sprite to equal right side of platform
  */

  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_x > 0){
        s.setRight(collided.getLeft());
    }
    else if(s.change_x < 0){
        s.setLeft(collided.getRight());
    }
  }
}

boolean checkCollision(Sprite s1, Sprite s2){
  boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if(noXOverlap || noYOverlap){
    return false;
  }
  else{
    return true;
  }
}

public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> list){
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for(Sprite p: list){
    if(checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list;
}

public ArrayList<Enemy> checkCollisionList1(Sprite s, ArrayList<Enemy> list){
  ArrayList<Enemy> collision_list = new ArrayList<Enemy>();
  for(Enemy p: list){
    if(checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list;
}


void createPlatforms(String filename){
  String[] lines = loadStrings(filename);
  for(int row = 0; row < lines.length; row++){
    String[] values = split(lines[row], ",");
    for(int col = 0; col < values.length; col++){
      if(values[col].equals("a")){
        Sprite s = new Sprite(red_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("b")){
        Sprite s = new Sprite(dirt, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("c")){
        Sprite s = new Sprite(brown_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("d")){
        Sprite s = new Sprite(crate, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("q")){
        Sprite s = new Sprite(snow, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("i")){
        Sprite s = new Sprite(ice, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("w")){
        Sprite s = new Sprite(stone, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("x")){
        Coin s = new Coin(c, COIN_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        coins.add(s);
      }
      else if(values[col].equals("0")){
        continue;
      }
      else{
        // use Processing int() method to convert a numeric string to an integer
        // representing the walk length of the spider.
        // for example int a = int("9"); means a = 9.
        int lengthGap = int(values[col]);
        float bLeft = col * SPRITE_SIZE;
        float bRight = bLeft + lengthGap * SPRITE_SIZE;  
        enemy = new Enemy(spider, 50/72.0, bLeft, bRight);
        enemy.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;      // see cases above.
        enemy.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        // add enemy to enemies arraylist.
        enemies.add(enemy);
       }
    }
  }
}
 

// called whenever a key is pressed.
void keyPressed(){
  if(keyCode == RIGHT){
    player.change_x = MOVE_SPEED;
    //arrows.add("RIGHT");
  }
  else if(keyCode == LEFT){
    player.change_x = -MOVE_SPEED;
    //arrows.add("LEFT");
  }
  // add an else if and check if key pressed is 'a' and if sprite is on platforms
  // if true then give the sprite a negative change_y speed(use JUMP_SPEED)
  // defined above
  else if(key == 'a' && isOnPlatforms(player, platforms)){
    player.change_y = -JUMP_SPEED;
    
  }
  else if(key == 's'){
    if(size){
      player.setScale(0.4);
      player.updateScale();
      size = false;
    }
    else{
      player.setScale(0.8);
      player.updateScale();
      size = true;
    }

    
  }

  else if(isGameOver && key == ' '){
    setup();
  }
  


}

// called whenever a key is released.
void keyReleased(){
  if(keyCode == RIGHT){
    player.change_x = 0;
    //arrows.remove("RIGHT");
  }
  else if(keyCode == LEFT){
    player.change_x = 0;
    //arrows.remove("LEFT");
  }
}
