#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>
#include <ArduinoJson.h>

// --- Configuration ---
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* mqtt_server = "broker.hivemq.com";
const int mqtt_port = 1883;

const String DEVICE_ID = "esp32-zone1-node1";

// --- Topics ---
String telemetry_topic = "smartagro/telemetry/" + DEVICE_ID;
String command_topic = "smartagro/command/" + DEVICE_ID;

// --- Pins ---
#define DHTPIN 4
#define DHTTYPE DHT22
#define SOIL_MOISTURE_PIN 34
#define RAIN_SENSOR_PIN 35
#define RELAY_PIN 5

DHT dht(DHTPIN, DHTTYPE);
WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected");
}

void callback(char* topic, byte* payload, unsigned int length) {
  String message;
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  Serial.println(message);

  // Command format {"relay": "ON"} or {"relay": "OFF"}
  StaticJsonDocument<200> doc;
  DeserializationError error = deserializeJson(doc, message);
  if (!error) {
    if (doc.containsKey("relay")) {
      String relay_cmd = doc["relay"].as<String>();
      if (relay_cmd == "ON") {
        digitalWrite(RELAY_PIN, HIGH);
        Serial.println("Pump turned ON");
      } else if (relay_cmd == "OFF") {
        digitalWrite(RELAY_PIN, LOW);
        Serial.println("Pump turned OFF");
      }
    }
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32Client-" + String(random(0, 1000));
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
      client.subscribe(command_topic.c_str());
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW); // Pump OFF by default
  
  dht.begin();
  setup_wifi();
  
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  static unsigned long lastMsg = 0;
  unsigned long now = millis();
  
  // Send telemetry every 10 seconds
  if (now - lastMsg > 10000) {
    lastMsg = now;
    
    float h = dht.readHumidity();
    float t = dht.readTemperature();
    int soil_val = analogRead(SOIL_MOISTURE_PIN);
    int rain_val = analogRead(RAIN_SENSOR_PIN);
    
    // Map analog readings to percentages (approximate logic)
    float soil_pct = map(soil_val, 4095, 0, 0, 100); 
    float rain_pct = map(rain_val, 4095, 0, 0, 100);
    
    if (isnan(h) || isnan(t)) {
      Serial.println("Failed to read from DHT sensor!");
      return;
    }

    StaticJsonDocument<200> doc;
    doc["temperature"] = t;
    doc["humidity"] = h;
    doc["moisture"] = soil_pct;
    doc["rain"] = rain_pct;
    doc["battery"] = 98.5; // Dummy battery value
    
    char msg[200];
    serializeJson(doc, msg);
    
    Serial.print("Publishing message: ");
    Serial.println(msg);
    client.publish(telemetry_topic.c_str(), msg);
  }
}
