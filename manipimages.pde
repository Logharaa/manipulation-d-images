import controlP5.*;
ControlP5 controlP5;

PFont police;
PImage img;
int nbPixels;
boolean visible=false;
int compteur=0;
int mat0, mat1, mat2, mat3, mat4, mat5, mat6, mat7, mat8 = 0;

float[][] matContraste = {  {0, -1, 0},
                            {-1, 5, -1},
                            {0, -1, 0 }  };
                            
float[][] matBlur = { {1/9f, 1/9f, 1/9},
                      {1/9f, 1/9f, 1/9f},
                      {1/9f, 1/9f, 1/9f}  };
                        
float[][] matDetectBords = {  {0, 1, 0},
                              {1, -4, 1},
                              {0, 1, 0 }  };
                              
float[][] matRenforcBords = {  {0, 0, 0},
                               {-1, 1, 0},
                               {0, 0, 0 }  };
                            
float[][] matUtilisateur = {  {mat0, mat1, mat2},
                              {mat3, mat4, mat5},
                              {mat6, mat7, mat8}  };
                             
                                      
void settings() {
  size(800, 730);
}

void setup(){
  police=loadFont("LiberationMono-24.vlw");
  img = loadImage("Roche-Jagu.jpg");
  nbPixels=img.width*img.height;
  background(255);
  image(img,0,0);
  PApplet.runSketch(platformNames, new fenetre2());
}

void draw() {
  menu();
}

void menu() {
  fill(0);
  textFont(police, 24);
  text("i : Inversion des couleurs", 430, img.height+45);
  text("r : Recharger l'image", 10, img.height+20 );
  text("n : Noir et blanc", 430, img.height+20);
  text("v : Inversion Verticale", 10, img.height+70 );
  text("h : Inversion Horizontale", 10, img.height+45 );
  text("c : Contraste", 430, img.height+70);
  text("f : Flou", 10, img.height+95 );
  text("d : Détection des bords", 430, img.height+95);
  text("b : Renforcement des bords", 10, img.height+120 );
  text("u : Choix matrice", 430, img.height+120);
}

void inversionVideo() {
  loadPixels();
  for (int i=0;i<nbPixels;i++) {
    pixels[i]=color(255-red(pixels[i]), 255-green(pixels[i]), 255-blue(pixels[i]));
  }
  updatePixels();
}

void noirEtBlanc() {
  loadPixels();
  for (int i=0;i<nbPixels;i++) {
    pixels[i]=color( (red(pixels[i]) + green(pixels[i]) + blue(pixels[i])) / 3);
  }
  updatePixels();
}

void retournementVertical() {
  loadPixels();  
  int[][] localtab = new int[img.width][img.height];
  for (int i = 0; i < localtab.length; i++)
    for (int j = 0; j < localtab[i].length; j++)
      localtab[i][j] = pixels[j * img.width + (img.width - i - 1)];
  for (int i = 0; i < localtab.length; i++)
    for (int j = 0; j < localtab[i].length; j++)
      pixels[j * localtab.length + i] = localtab[i][j];
  updatePixels();
} 

void retournementHorizontal() {
  loadPixels();  
  int[][] localtab = new int[img.width][img.height];
  for (int i = 0; i < localtab.length; i++)
    for (int j = 0; j < localtab[i].length; j++)
      localtab[i][j] = pixels[(img.height - j - 1) * img.width + i];
  for (int i = 0; i < localtab.length; i++)
    for (int j = 0; j < localtab[i].length; j++)
      pixels[j * localtab.length + i] = localtab[i][j];
  updatePixels();
}

int rgbtohsv(int rgb) {
  int r = rgb >> 16;
  int g = (rgb >> 8) & 255;
  int b = rgb & 255;
  int vmax = 0;
  int vmin = 255;
  int max = -1;
  int min = -1;
  if (r > vmax) {max = 0; vmax = r;}
  if (r < vmin) {min = 0; vmin = r;}
  if (g > vmax) {max = 1; vmax = g;}
  if (g < vmin) {min = 1; vmin = g;}
  if (b > vmax) {max = 2; vmax = b;}
  if (b < vmin) {min = 2; vmin = b;}
  int v = vmax;
  int s;
  if (vmax == 0) s = 0;
  else s = (int) Math.floor(256 - 256 * vmin / vmax);
  int h = 0;
  switch (max) {
  case 0:
    if (min == 1) h = (int) Math.floor(256 * (r - b) / (double) (s * v / 255d) / 6d + 256 * 5d / 6d);
    else h = (int) Math.floor(256 * (g - b) / (double) (s * v / 255d) / 6d + 256 * 0);
    break;
  case 1:
    if (min == 2) h = (int) Math.floor(256 * (g - r) / (double) (s * v / 255d) / 6d + 256 * 1d / 6d);
    else h = (int) Math.floor(256 * (b - r) / (double) (s * v / 255d) / 6d + 256 * 2d / 6d);
    break;
  case 2:
    if (min == 0) h = (int) Math.floor(255 * (b - g) / (double) (s * v / 255d) / 6d + 256 * 3d / 6d);
    else h = (int) Math.floor(256 * (r - g) / (double) (s * v / 255d) / 6d + 256 * 4d / 6d);
    break;
  }
  return (h << 16) | (s << 8) | v;
}

int hsvtorgb(int hsv) {
  int h = hsv >> 16;
  int s = (hsv >> 8) & 255;
  int v = hsv & 255;
  int hi = (int) Math.floor(6 * h / 256d) % 6;
  float f = 6 * h / 256f - hi;
  int max = v;
  int med1 = (int) Math.floor(v - v * s * f / 255d);
  int med2 = (int) Math.floor(v - v * s / 255d + v * s * f / 255d);
  int min = (int) Math.floor(v * (256 - s) / 255d);
  switch (hi) {
  case 0:
    return (max << 16) | (med2 << 8) | min;
  case 1:
    return (med1 << 16) | (max << 8) | min;
  case 2:
    return (min << 16) | (max  << 8) | med2;
  case 3:
    return (min << 16) | (med1 << 8) | max;
  case 4:
    return (med2 << 16) | (min << 8) | max;
  default:
    return (max << 16) | (min << 8) | med1;
  }
}

void contraste() {
  int tailleMatrice = 3;
  loadPixels();
  for (int x=0; x<img.width; x++) {
    for (int y=0; y<img.height; y++) {
      color c = convolution(x, y, matContraste, tailleMatrice, img);
      int posPixels = x + y*img.width;
      pixels[posPixels] = c;
    }
  }
  updatePixels();
}

void blur(){
  loadPixels();
  int tailleMatrice = 3;
  for (int x = 0; x < img.width; x++) {
     for (int y = 0; y < img.height; y++) {
        color c = convolution(x, y, matBlur, tailleMatrice, img);
        int posPixels = x + y*img.width;
        pixels[posPixels] = c;
     }
  }
  updatePixels();    
}

void detectBords() {
  int tailleMatrice = 3;
  loadPixels();
  for (int x=0; x<img.width; x++) {
    for (int y=0; y<img.height; y++) {
      color c = convolution(x, y, matDetectBords, tailleMatrice, img);
      int posPixels = x + y*img.width;
      pixels[posPixels] = c;
    }
  }
  updatePixels();
}

void renforcBords() {
  int tailleMatrice = 3;
  loadPixels();
  for (int x=0; x<img.width; x++) {
    for (int y=0; y<img.height; y++) {
      color c = convolution(x, y, matRenforcBords, tailleMatrice, img);
      int posPixels = x + y*img.width;
      pixels[posPixels] = c;
    }
  }
  updatePixels();
}

void matUtilisateur() {
  float[][] matUtilisateur = {  {mat0, mat1, mat2},
                                {mat3, mat4, mat5},
                                {mat6, mat7, mat8}  };
  int tailleMatrice = 3;
  loadPixels();
  for (int x=0; x<img.width; x++) {
    for (int y=0; y<img.height; y++) {
      color c = convolutionUser(x, y, matUtilisateur, tailleMatrice, img);
      int posPixels = x + y*img.width;
      pixels[posPixels] = c;
    }
  }
  updatePixels();    
}

public class fenetre2 extends PApplet {
  
  public void settings() {
    size(500, 200);
  }
  
  public void setup() {
    surface.setTitle("Choix utilisateur");
    controlP5 = new ControlP5(this);

      for (int g=0; g<3; g++) {
        for (int j=0; j<3; j++) {
          controlP5.addNumberbox("box" + compteur)
            .setValue(0)
            .setPosition(320+60*j,10+50*g)
            .setSize(30,30)
            .setScrollSensitivity(1)
            .setRange(-5, 5) 
            .setValue(0)
            ;
          compteur+=1;
        }
      }

   controlP5.addButton("Appliquer")
     .setPosition(356, 160)
     .setSize(80, 24)
     ;

  }
  
  public void draw() {
    background(255);
    surface.setVisible(visible);
    fill(0);
    textFont(police, 14);
    text("Entrez la matrice de votre choix :", 14, 100);
  }
    
  public void box0(int value) {
    mat0 = value;
  }
  public void box1(int value) {
    mat1 = value;
  }
  public void box2(int value) {
    mat2 = value;
  }
  public void box3(int value) {
    mat3 = value;
  }
  public void box4(int value) {
    mat4 = value;
  }
  public void box5(int value) {
    mat5 = value;
  }
  public void box6(int value) {
    mat6 = value;
  }
  public void box7(int value) {
    mat7 = value;
  }
  public void box8(int value) {
    mat8 = value;
  }

  public void Appliquer() {
    matUtilisateur();
    visible=false;
  }
  
}
                             
void keyPressed() {
  if (key=='i') inversionVideo();
  if (key=='r') image(img, 0, 0);
  if (key=='n') noirEtBlanc();
  if (key=='v') retournementVertical();
  if (key=='h') retournementHorizontal();
  if (key=='c') contraste();
  if (key=='f') blur();
  if (key=='d') detectBords();
  if (key=='b') renforcBords();
  if (key=='u') visible=true;
}

color convolution(int x, int y, float[][] matrice, int tailleMatrice, PImage img) 
{
  float r = 0.0;
  float g = 0.0;
  float b = 0.0;
  int matMilieu = tailleMatrice / 2;
  for (int i=0; i<tailleMatrice; i++) {
    for (int j=0; j<tailleMatrice; j++) {
      int xpos = x + i - matMilieu;
      int ypos = y + j - matMilieu;
      int pos = xpos + ypos * img.width;
      // On s'assure de ne pas être sorti de l'image
      pos = constrain(pos, 0, img.pixels.length-1);
      // Calcul de la convolution
      r += red(img.pixels[pos]) * matrice[i][j];
      g += green(img.pixels[pos]) * matrice[i][j];
      b += blue(img.pixels[pos]) * matrice[i][j];
    }
  }
  r = constrain(r, 0, 255);
  g = constrain(g, 0, 255);
  b = constrain(b, 0, 255);
  // On renvoie la couleur résultante
  return color(r, g, b);
}

color convolutionUser(int x, int y, float[][] matrice, int tailleMatrice, PImage img) 
{
  float r = 0.0;
  float g = 0.0;
  float b = 0.0;
  int matMilieu = tailleMatrice / 2;
  for (int i=0; i<tailleMatrice; i++) {
    for (int j=0; j<tailleMatrice; j++) {
      int xpos = x + i - matMilieu;
      int ypos = y + j - matMilieu;
      int pos = xpos + ypos * img.width;
      // On s'assure de ne pas être sorti de l'image
      pos = constrain(pos, 0, img.pixels.length-1);
      // Calcul de la convolution
      r += red(img.pixels[pos]) * matrice[i][j] / (abs(mat0) + abs(mat1) + abs(mat2) + abs(mat3) + abs(mat4) + abs(mat5) + abs(mat6) + abs(mat7) + abs(mat8));
      g += green(img.pixels[pos]) * matrice[i][j] / (abs(mat0) + abs(mat1) + abs(mat2) + abs(mat3) + abs(mat4) + abs(mat5) + abs(mat6) + abs(mat7) + abs(mat8));
      b += blue(img.pixels[pos]) * matrice[i][j] / (abs(mat0) + abs(mat1) + abs(mat2) + abs(mat3) + abs(mat4) + abs(mat5) + abs(mat6) + abs(mat7) + abs(mat8));
    }
  }
  r = constrain(r, 0, 255);
  g = constrain(g, 0, 255);
  b = constrain(b, 0, 255);
  // On renvoie la couleur résultante
  return color(r, g, b);
}
