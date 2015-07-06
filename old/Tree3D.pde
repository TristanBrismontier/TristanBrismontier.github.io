Stick stick;
  float p = 0;
  boolean compute = true;
  ArrayList<MapPVector> pVectorMap = new ArrayList<MapPVector>();

  public void setup() {
    size(800, 800, OPENGL);
    initStick();
  }

  public void draw() {
    computeStickPosition();
    displaySticks();
  }

  private void displaySticks() {
    background(0);
    noStroke();
    pointLight(51, 102, 126, 35, 40, 36);
    translate(width / 2, height, -200);
    rotateY(radians(p++));
    for (int i = 0; i < pVectorMap.size(); i++){
       for (int j = 0; j < pVectorMap.get(i).pVectorWidths.size(); j++) {
        pushMatrix();
        drawCylinder(pVectorMap.get(i).pVectorWidths.get(j));
        popMatrix();
      }
    }
  }

  private void computeStickPosition() {
   if (compute) {
      ArrayList<PVectorWidth> buleListComputed = stick.display();
      for (int i = 0; i < buleListComputed.size(); i++) {
        PVectorWidth current =  (PVectorWidth) buleListComputed.get(i);
        ArrayList<PVectorWidth> listbule = new ArrayList<PVectorWidth>();
        for (int j = 0; j < pVectorMap.size(); j++) {
          if(pVectorMap.get(j).id == current.getId()){
            listbule = pVectorMap.get(j).pVectorWidths;
          }
        }
        
        if (listbule.size() <=0) {
          listbule = new ArrayList<PVectorWidth>();
          listbule.add(current);
          pVectorMap.add(new MapPVector(current.getId(), listbule));
        } else {
          PVectorWidth lastVector = (PVectorWidth)listbule.get(listbule.size()-1);
          PVector last = new PVector(lastVector.x,lastVector.y,lastVector.z);
          PVector niou = new PVector(current.x,current.y,current.z);
          if (abs(last.dist(niou)) >= current.getWid()) {
             
            listbule.add((PVectorWidth) current);
          }
        }
      }
    }
  }

  public void mousePressed() {
    initStick();
  }

  void drawCylinder(final PVectorWidth current) {
    float r1 = current.getWid()*3;
    translate(current.x*3, current.y*3, current.z*3);
    box(r1);
  }

  private void initStick() {
    compute = true;
    pVectorMap =  new ArrayList<MapPVector>();
    stick = new Stick( new PVector(0, 0), 50, 80);
    background(0);
  }

class EntityT {

  PVector location;
  float width;
  float height;
  float id;

  public EntityT(PVector location, float width, float height, float id) {
    this.id = id;
    this.location = location.get();
    this.width = width;
    this.height = height;
  }
}
class MapPVector { 
  float id;
 ArrayList<PVectorWidth> pVectorWidths;
 
 public MapPVector(float id, ArrayList<PVectorWidth> pVectorWidths){
   this.id = id;
   this.pVectorWidths = pVectorWidths;
 }
 
 
}
class PVectorWidth extends PVector {
  float wid;
  float grey;
  float alpha;
  float id;

  public PVectorWidth( PVector vector,  float wid, float grey, float alpha, float id) {
    super(vector.x,vector.y,vector.z);
    this.wid = wid;
    this.grey = grey;
    this.alpha = alpha;
    this.id = id;
  }
  
  public float getId() {
    return id;
  }
  
  public float getGrey() {
    return grey;
  }

  public float getAlpha() {
    return alpha;
  }

  public float getWid(){
    return wid;
  }
  
}
 class Stick extends EntityT {
  PVector velocity;
  ArrayList<Stick> sticks;
  boolean pStick;
  float vampireLife ;
  float life;

  public Stick(PVector location, float width, float life, PVector velocity){
    super(location, width, width, random(10000));
    sticks = new ArrayList<Stick>();
    this.life = life;  
    this.velocity = velocity.get();
    pStick = false;
  }

  public Stick(PVector location, int width, float life){
    super(location, width, width, random(10000));
    sticks = new ArrayList<Stick>();
    this.life = life;  
    this.velocity = new PVector(0,-0.3f,0);
    pStick = true;
    vampireLife = 100;
  }
public ArrayList<PVectorWidth>  display(){
    final ArrayList<PVectorWidth> buleList = new ArrayList<PVectorWidth>();
    if(life > 0){
      final PVectorWidth self = new PVectorWidth(location, width *(life/255), 75-life, life, id);
    if(width *(life/255) >=1f){
       buleList.add(self);
      }
      computeNewData();
    
  }
     
    final ArrayList<Stick> stickToRemove = new ArrayList<Stick>();
    for (int i = 0; i < sticks.size(); i++) {
      ArrayList<PVectorWidth> childList = sticks.get(i).display();
      if(childList.isEmpty()){
        stickToRemove.add(sticks.get(i));
      }else{
        buleList.addAll(childList);
      }
    }
    sticks.removeAll(stickToRemove);
    return buleList;
  }
  
  private void computeNewData() {
    location.add(velocity);    
    life -=random(0.11f,0.05f);
    if(pStick){
      computeParentStick();
    }else{
      computeChildStick();
    }
  }

  private void computeChildStick() {
    velocity.y -= random(-2,2)/500;
    velocity.x += random(-3.5f,3.5f) /100;
    velocity.z += random(-3.5f,3.5f) /100;
    constrain(velocity.x, -0.95f, 0.95f);
    constrain(velocity.z, -0.95f, 0.95f);
    constrain(velocity.y, -9f, -0.05f);
    if(random(115)> life && percent(0.2f)) addstick();
  }

  private void computeParentStick() {
    velocity.y -=  random(-1,2) /500;
    velocity.x +=  random(-2,2) /100;
    velocity.z +=  random(-2,2) /100;
    constrain(velocity.x, -0.95f, 0.95f);
    constrain(velocity.z, -0.95f, 0.95f);
    if(random(255)> life && percent(3.5f) || life<25 && percent(3.5f)) addstick();
  }
  
  private boolean percent( float chance){
    return  random(100) < chance;
  }

  private void addstick() {
    float ratiolife = (pStick)?0.65f:0.80f;
    float ratioWidth = (pStick)?0.75f:0.9f;
    //add map instead
    PVector newVelocity = new PVector(velocity.x+(random(-1,1)*0.3f), velocity.y+(random(-0.5f,3)*0.1f),velocity.z+(random(-1,1)*0.3f));
    sticks.add(new Stick(location, width*ratioWidth, life*ratiolife, newVelocity));
    vampireLife -= 1.2f;
    life =life *0.97f;
  }
 }



