import processing.serial.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.nio.charset.Charset;

import org.json.JSONException;
import org.json.JSONObject;


import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.io.UnsupportedEncodingException;

import org.apache.commons.io.FileUtils;






final int BAUD_RATE = 230400;
final String serialName = "COM4";
Serial port;

int hour; 
int min;

PFont f;
PImage img;

String desiredLocation = "";

boolean button1;
boolean button2;
boolean record;
String apikey ="&key=";

//https://maps.googleapis.com/maps/api/geocode/outputFormat?parameters
String geocodeurl = "https://maps.googleapis.com/maps/api/geocode/json?address=";
//https://maps.googleapis.com/maps/api/staticmap?parameters
String staticmapurl = "https://maps.googleapis.com/maps/api/staticmap?";

String mapparams = "&size=600x400&maptype=roadmap&markers=color:green%7C";

int zoom = 12;


JSONObject json;

boolean startjson;
double lat = 0.0;
double lng = 0.0;

String defaultlocal = "Worcester, MA"; // change this when change location.


//int gmt = hour()+5;
int buffer = 0; 


void setup(){
  port = new Serial(this, serialName, BAUD_RATE); // open port
  try {
  json = readJsonFromUrl(geocodeurl+encodeValue(defaultlocal)+apikey);
  lat = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getDouble("lat");
  lng = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getDouble("lng");
  updateImage();
  //println(TimezoneMapper.latLngToTimezoneString(lat, lng));
  }catch(IOException e){
      
  }
  
  size(800,600);
  background(255);
  
  //String data = link("https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=AIzaSyDscFXxK5GytLm4PulloON9OeywNBhH1zc");
  // https://stackoverflow.com/questions/4308554/simplest-way-to-read-json-from-a-url-in-java
  
  img = loadImage("staticmap.png");
  textSize(20);  

}




void getLatLong(){
   try { 
       json = readJsonFromUrl(geocodeurl+encodeValue(desiredLocation)+apikey);
       //println(json.toString());
       //println(geocodeurl+encodeValue(desiredLocation)+apikey);
        //println(typeof(json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").get("lat")));
       lat = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getDouble("lat");
       lng = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getDouble("lng");
       //println("("+lat + ", " + lng+ ")");
       zoom = 12;
       FileUtils.copyURLToFile(new URL(staticmapurl +"&center" + encodeValue(lat +"," + lng) + "&zoom=" +zoom + mapparams + encodeValue(lat +"," + lng) + apikey), new File("C:/Users/Thomas/Desktop/Clock Project/Brains/staticmap.png"));
       desiredLocation = "";
       img = loadImage("staticmap.png");
       updatebuffer();
       
     } catch (JSONException | IOException e) {
       println(e);
     }
}

void updateImage(){
   try { 
     if(lat != 0.0 && lng !=0.0){
      // println(staticmapurl +"&center" + encodeValue(lat +"," + lng) + "&zoom=" +zoom + mapparams + encodeValue(lat +"," + lng) + apikey);
       FileUtils.copyURLToFile(new URL(staticmapurl +"&center" + encodeValue(lat +"," + lng) + "&zoom=" +zoom + mapparams + encodeValue(lat +"," + lng) + apikey), new File("C:/Users/Thomas/Desktop/Clock Project/Brains/staticmap.png"));
       img = loadImage("staticmap.png");
     }
   }catch  (IOException e) {
       println(e);
   }
}


void updatebuffer (){
       double temp = 0.0;
      if(lat != 0.0 && lng !=0.0){
        temp = Math.round((lng / 0.004167)/3600);
        
        buffer = 5 + (int)temp;
      // println(buffer);
      }
}


void draw() {
      background(255);
      
      // text and line
      text(desiredLocation, 100, 100);
      fill(0);
      stroke(0);
      line(100,110,500,110);
      
      //button 1
      noFill();
      text("Mic", 530, 100);
      if(record){
         fill(0,255,0); 
      }
      rect(510, 80, 75, 30, 28);
      fill(0);
      noFill();
      
    
      
      //button 2
      text("→", 625, 100);
      rect(590, 80, 75, 30, 28);
  
  
    
    image(img, 100, 150);
    text("( is zoom out and ) is zoom in", 260, 580);
    
    hour = hour() + buffer;
    if(hour >= 24){
      hour -= 24;
    }
    min = minute();
    
    if (hour < 10){
      
      // makes the hour i.e. 1 =  '0' , '1' when sending the bytes
     port.write('0');
     port.write(char(hour + '0'));
    }else{
      // make the hour '1','2' out of 12when sending bytes
      port.write(char(hour/10 +'0'));
      port.write(char(hour%10 + '0'));
    }
    if ( min < 10){
      // makes the min i.e. 7 =  '0' , '7' when sending the bytes
      port.write('0');
      port.write(char(min + '0'));
    }else{
      port.write(char(min/10 +'0'));
      port.write(char(min%10 + '0'));
    }

    
  
}


void mousePressed(){
  if (mouseX > 510 && mouseX < 585 && mouseY > 80 && mouseY < 110 && !record) {
        record = true;
        println("Started recording");
        //TODO 
        //Start recording
        
  }else if(mouseX > 510 && mouseX < 585 && mouseY > 80 && mouseY < 110){
        println("stopped recording");
        record = false;
        //TODO
        //stop recording
        // translate mp4 into word and make set the "desiredLocation" variable
  }
  
  // rect(590, 80, 75, 30, 28);
  if (mouseX> 590 && mouseX< 665 && mouseY > 80 && mouseY <110){
   if (!desiredLocation.equals(""))
    getLatLong();
    
    
  }
}



void keyTyped( KeyEvent e) {
  
   if((int(key) == 40) ){
     --zoom;
    // println(zoom);
     updateImage();
  }
  if(int(key) == 41 ){
    ++zoom;
    //println(zoom);
    updateImage();
  }
  if(int(key) >= 42 || int(key)  == 32){
    desiredLocation = desiredLocation + Character.toString(key); 
    
  }if(int(key) == 8){
    if(desiredLocation.length() != 0)
      desiredLocation = desiredLocation.substring(0,desiredLocation.length()-1);
  }if(int(key) == 10 && !desiredLocation.equals("")){
    getLatLong();
  }
  
  
}




private static String encodeValue(String value) {
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8.toString());
        } catch (UnsupportedEncodingException ex) {
            throw new RuntimeException(ex.getCause());
        }
    }



 private static String readAll(Reader rd) throws IOException {
    StringBuilder sb = new StringBuilder();
    int cp;
    while ((cp = rd.read()) != -1) {
      sb.append((char) cp);
    }
    return sb.toString();
  }



public static JSONObject readJsonFromUrl(String url) throws IOException, JSONException {
    InputStream is = new URL(url).openStream();
    try {
      BufferedReader rd = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
      String jsonText = readAll(rd);
      JSONObject json = new JSONObject(jsonText);
      return json;
    } finally {
      is.close();
    }
  }
