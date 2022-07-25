Player u;
Platform [] platforms;

boolean left, right, up, down, space, shift;

PImage [] animIdleLeft;
PImage [] animWalkLeft;
PImage [] animJumpLeft;
PImage [] animWinLeft;
PImage [] animIdleRight;
PImage [] animWalkRight;
PImage [] animJumpRight;
PImage [] animWinRight;
int animSpeed;

PImage [] weapons;
boolean [] unlockedWeapons;
Timer [] weaponTimers;

PImage bullet;

Bullet [] bullets;
Gun gun;
int nextBullet;

Timer firingTimer;
Timer [] animTimers;

void setup() 
{
  size(1280, 720);
  smooth(0);
  animSpeed = 2;
  gun = new Gun();
  animTimers = new Timer[6];
  animTimers[0] = new Timer(1000/(4 * animSpeed));
  animTimers[1] = new Timer(1000/(4 * animSpeed));
  animTimers[2] = new Timer(1000/(6 * animSpeed));
  animTimers[3] = new Timer(1000/(6 * animSpeed));
  animTimers[4] = new Timer(1000/(6 * animSpeed));
  animTimers[5] = new Timer(1000/(6 * animSpeed));
  
  for (int i = 0; i < 6; i++)
  {
    animTimers[i].start();
  }

  weapons = new PImage[2];
  weapons[0] = loadImage("sprMagnum_0Left.png");
  weapons[1] = loadImage("sprMagnum_0Right.png");
  frameRate(60);

//Animation settings
  animIdleLeft = new PImage[6];
  
  for (int i = 0; i<6; i++) 
  {
    animIdleLeft[i]=loadImage("sprPlayer1Left_"+i+".png");
  }

  animWalkLeft = new PImage[6];
  
  for (int i = 0; i<6; i++) 
  {
    animWalkLeft[i]=loadImage("sprPlayer1WalkLeft_"+i+".png");
  }

  animJumpLeft = new PImage[4];
  
  for (int i = 0; i<4; i++) 
  {
    animJumpLeft[i]=loadImage("sprPlayer1JumpLeft_"+i+".png");
  }

  animIdleRight = new PImage[6];
  
  for (int i = 0; i<6; i++) 
  {
    animIdleRight[i]=loadImage("sprPlayer1Right_"+i+".png");
  }

  animWalkRight = new PImage[6];
  
  for (int i = 0; i<6; i++) 
  {
    animWalkRight[i]=loadImage("sprPlayer1WalkRight_"+i+".png");
  }

  animJumpRight = new PImage[4];
  
  for (int i = 0; i<4; i++) 
  {
    animJumpRight[i]=loadImage("sprPlayer1JumpRight_"+i+".png");
  }

  

  bullet = loadImage("sprBullet_0.png");

  u = new Player();
  platforms = new Platform[4];
  platforms[0] = new Platform (300, 460, 200, 25, "safe");
  platforms[1] = new Platform (0, 300, 200, 25, "safe");
  platforms[2] = new Platform (600, 300, 200, 25, "safe");
  platforms[3] = new Platform (300, 140, 200, 25, "safe");

  bullets = new Bullet [3];
  
  for (int i = 0; i < bullets.length; ++i) 
  {
    bullets[i] = new Bullet();
  }
  
  nextBullet = 0;

  left = false;
  right = false;
  up = false;
  down = false;
  space = false;
  shift = false;

  firingTimer = new Timer(300);
  firingTimer.start();
}

void draw() 
{
  background(255);
  u.update();

  for (int i = 0; i < platforms.length; ++i) 
  {
    rectangleCollisions(u, platforms[i]);
    u.checkPlatforms();
  }

  u.checkBoundaries();
  
  if (space) 
  {
    if (firingTimer.isFinished()) 
    {
      bullets[nextBullet].fire(u.x, u.y, u.w, u.facingRight);
      nextBullet = (nextBullet+1)%bullets.length;
      firingTimer.start();
    }
  }

  u.display();
  gun.display();  

  for (int i = 0; i < platforms.length; ++i) 
  {
    platforms[i].display();
  }
  
  for (int i = 0; i < bullets.length; ++i) 
  {
    bullets[i].update();
    bullets[i].display();
  }
}

void keyPressed()
{
  switch (keyCode) 
  {
  case 37://left
    left = true;
    break;
  case 39://right
    right = true;
    break;
  case 38://up
    up = true;
    break;
  case 40://down
    down = true;
    break;
  case 32: //space
    space = true;
    break;
  case 16: //shift
    shift = true;
  }
}

void keyReleased() 
{
  switch (keyCode) 
  {
  case 37://left
    left = false;
    break;
  case 39://right
    right = false;
    break;
  case 38://up
    up = false;
    break;
  case 40://down
    down = false;
    break;
  case 32: //space
    space = false;
    break;
  case 16: //shift
    shift = false;
  }
}


void rectangleCollisions(Player r1, Platform r2) 
{

  float dx = (r1.x+r1.w/2) - (r2.x+r2.w/2);
  float dy = (r1.y+r1.h/2) - (r2.y+r2.h/2);

  float combinedHalfWidths = r1.halfWidth + r2.halfWidth;
  float combinedHalfHeights = r1.halfHeight + r2.halfHeight;

  if (abs(dx) < combinedHalfWidths) 
  {

    if (abs(dy) < combinedHalfHeights) 
    {

      float overlapX = combinedHalfWidths - abs(dx);
      float overlapY = combinedHalfHeights - abs(dy);

      if (overlapX >= overlapY) 
      {
        if (dy > 0) 
        {
          r1.collisionSide = "top";
          r1.y += overlapY;
        } 
        
        else 
        {
          r1.collisionSide = "bottom";
          r1.y -= overlapY;
        }
      } 
      
      else 
      {
        if (dx > 0) 
        {
          r1.collisionSide = "left";
          r1.x += overlapX;
        } 
        
        else 
        {
          r1.collisionSide = "right";
          r1.x -= overlapX;
        }
      }
    } 
    
    else 
    {
      r1.collisionSide = "none";
    }
  } 
  
  else 
  {
    r1.collisionSide = "none";
  }
}

class Player 
{

  float w, h, x, y, vx, vy, 
    accelerationX, accelerationY, 
    speedLimit, friction, bounce, gravity;
  boolean isOnGround;
  float jumpForce;
  float halfWidth, halfHeight;
  int [] currentFrame;
  String collisionSide;
  boolean facingRight;
  int [] frameSequence;

  Player() 
  {
    w = 60;
    h = 60;
    x = 10;
    y = 150;
    vx = 0;
    vy = 0;
    accelerationX = 0;
    accelerationY = 0;
    speedLimit = 5;
    friction = 0.96;
    bounce = -0.7;
    gravity = 3;
    isOnGround = false;
    jumpForce = -10;

    halfWidth = (w-(w/10))/2;
    halfHeight = h/2;

    currentFrame = new int [6];
    frameSequence = new int [6];

    for (int i = 0; i < 6; i++)
    {
      currentFrame[i] = 0;
    }

    frameSequence[0] = 4;
    frameSequence[1] = 4;
    frameSequence[2] = 6;
    frameSequence[3] = 6;
    frameSequence[4] = 6;
    frameSequence[5] = 6;


    collisionSide = "";
  }

  void update()
  {
    if (left)
    {
      accelerationX = -1;
      friction = 1;
      facingRight = false;
    }

    if (right)
    {
      accelerationX = 1;
      friction = 1;
      facingRight = true;
    }

    if (!left&&!right) 
    {
      accelerationX = 0;
      friction = 0;
      gravity = 0.3;
    } 
    
    else if (left&&right)
    {
      accelerationX = 0;
      friction = 0;
      gravity = 0.3;
    }

    if (up && isOnGround)
    {
      vy += jumpForce;
      isOnGround = false;
      friction = 1;
    }

    vx += accelerationX;
    vy += accelerationY;

    if (isOnGround)
    {
      vx *= friction;
    }

    vy += gravity;

    if (vx > speedLimit)
    {
      vx = speedLimit;
    }

    if (vx < -speedLimit)
    {
      vx = -speedLimit;
    }

    if (vy > speedLimit * 2)
    {
      vy = speedLimit * 2;
    }

    x+=vx;
    y+=vy;
  }

  void checkPlatforms() 
  {

    if (collisionSide == "bottom" && vy >= 0) 
    {
      isOnGround = true;
      vy = -gravity;
    } 
    
    else if (collisionSide == "top" && vy <= 0) 
    {
      vy = 0;
    } 
    
    else if (collisionSide == "right" && vx >= 0) 
    {
      vx = 0;
    } 
    
    else if (collisionSide == "left" && vx <= 0) 
    {
      vx = 0;
    }
    
    if (collisionSide != "bottom" && vy > 0) 
    {
      isOnGround = false;
    }
  }
  
  void checkBoundaries() 
  {

    if (x < -w) 
    {
      x = width;
    }
    
    if (x  > width) 
    {
      x = -w;
    }

    if (y < 0) 
    {

    }
    
    if (y + h > height) 
    {
      y = height - h;
      isOnGround = true;
      vy = -gravity;
    }
  }
  
  void display()
  {

    if (facingRight && isOnGround)
    {

      if (right && !left)
      {
        
        image(animWalkRight[currentFrame[2]], x, y, w, h);        
        if (animTimers[2].isFinished())
        {          
          currentFrame[2] = (currentFrame[2]+1)%frameSequence[2];
          
          for (int i = 0; i < 6; i++)
          {
            
            if (i == 2)
            {
              
            } 
            
            else
            {
              currentFrame[i] = 0;
            }
          }
          
          animTimers[2].start();
          
        }
      }
      
      else
      {
        image(animIdleRight[currentFrame[3]], x, y, w, h);
        
        if (animTimers[3].isFinished())
        {
          currentFrame[3] = (currentFrame[3]+1)%frameSequence[3];
          
          for (int i = 0; i < 6; i++)
          {
            
            if (i == 3)
            {
              
            } 
            
            else
            {
              currentFrame[i] = 0;
            }
          }
          
          animTimers[3].start();
          
        }
      }
    } 
    
    else if (!facingRight && isOnGround)
    {
      if (left && !right)
      {
        image(animWalkLeft[currentFrame[4]], x, y, w, h);
        
        if (animTimers[4].isFinished())
        {
          currentFrame[4] = (currentFrame[4]+1)%frameSequence[4];
          
          for (int i = 0; i < 6; i++)
          {
            
            if (i == 4)
            {
              
            } 
            
            else
            {
              currentFrame[i] = 0;
            }
          }
          
          animTimers[4].start();
          
        }
      } 
      
      else
      {
        image(animIdleLeft[currentFrame[5]], x, y, w, h);
        
        if (animTimers[5].isFinished())
        {
          currentFrame[5] = (currentFrame[5]+1)%frameSequence[5];
          
          for (int i = 0; i < 6; i++)
          {
            
            if (i == 5)
            {
              
            } 
            
            else
            {
              currentFrame[i] = 0;
            }
          }
          
          animTimers[5].start();
          
        }
      }
    }

    if (facingRight && !isOnGround)
    {
      image(animJumpRight[currentFrame[0]], x, y, w, h);
      
      if (animTimers[0].isFinished())
      {
        currentFrame[0] = (currentFrame[0]+1)%frameSequence[0];
        
        for (int i = 0; i < 6; i++)
        {
          
          if (i == 0)
          {
            
          } 
          
          else
          {
            currentFrame[i] = 0;
          }
        }
        
        animTimers[0].start();
        
      }
    } 
    
    else if (!facingRight && !isOnGround)
    {
      image(animJumpLeft[currentFrame[1]], x, y, w, h);
      
      if (animTimers[1].isFinished())
      {
        currentFrame[1] = (currentFrame[1]+1)%frameSequence[1];
        
        for (int i = 0; i < 6; i++)
        {
          if (i == 1)
          {
            
          } 
          
          else
          {
            currentFrame[i] = 0;
          }
        }
        
        animTimers[1].start();
        
      }
    }
  }
}


class Bullet 
{
  float w, h, x, y;
  float halfWidth, halfHeight;
  float vx, vy;
  boolean firing = false;

  Bullet() 
  {
    w = 15;
    h = 15;
    x = 0;
    y = -h;
    halfWidth = w/2;
    halfHeight = h/2;
    vx = 0;
    vy = 0;
  }
  
  void fire(float _x, float _y, float _w, boolean _facingRight) 
  {
    if (!firing) 
    {
      y = _y+24;
      firing = true;
      
      if (_facingRight == true) 
      {
        vx = 15;
        x = _x + _w - 35;
      } 
      
      else 
      {
        vx = -15;
        x = _x;
      }
    }
  }
  
  void reset() 
  {
    x = 0;
    y = -h;
    vx = 0;
    vy = 0;
    firing = false;
  }
  
  void update() 
  {
    if (firing) 
    {
      x += vx;
      y += vy;
    }

    if (x < 0 || x > width || y < 0 || y > height) 
    {
      reset();
    }
  }
  
  void display() 
  {
    image(bullet,x,y,w,h);
  }
}

class Platform 
{
  float w, h, x, y;
  String typeof;
  float halfWidth, halfHeight;

  Platform(float _x, float _y, float _w, float _h, String _typeof) 
  {
    w = _w;
    h = _h;
    x = _x;
    y = _y;
    typeof = _typeof;

    halfWidth = w/2;
    halfHeight = h/2;
  }

  void display() 
  {
    fill(0, 0, 255);
    rect(x, y, w, h);
  }
}

class Timer 
{
  int startTime;
  float interval;

  Timer(float tempTime) 
  {
    interval=tempTime;
  }

  void start() 
  {
    startTime=millis();
  }

  boolean isFinished() 
  {
    int elapsedTime = millis() - startTime;
    
    if (elapsedTime>interval) 
    {
      return true;
    } 
    
    else 
    {
      return false;
    }
  }
}

class Gun
{
  float x, y, w, h;
  int gunType;

  Gun()
  {
    gunType = 0;
    w = 40;
    h = 40;
  }

  void display()
  {
    x = u.x + (u.w / 2 - w/2);
    y = u.y;
    
    if (u.facingRight)
    {
      image(weapons[gunType + 1], x + w/2, y + (u.h/4) + 0, w, h);
    } 
    
    else
    {
      image(weapons[gunType], x - w/2, y + (u.h/4) + 0, w, h);
    }
  }
}
