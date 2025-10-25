// ================== IMPORT DEPENDENCIES ==================
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const axios = require('axios');

const app = express();

// ================== MIDDLEWARE ==================
app.use(bodyParser.json());

// ✅ CORS CONFIG — allows web & mobile access
// Allow CORS for development; this permits browser requests from Flutter web.
app.use(cors());
// Simple preflight responder for older router versions
app.use((req, res, next) => {
  if (req.method === 'OPTIONS') {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    return res.sendStatus(200);
  }
  next();
});

// ================== CONNECT TO MONGODB ==================
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB connected"))
  .catch(err => console.error("❌ MongoDB connection error:", err));

// ================== FARMER SCHEMA ==================
const farmerSchema = new mongoose.Schema({
  username: { type: String, unique: true, required: true },
  name: String,
  email: { type: String, unique: true, required: true },
  password: { type: String, required: true },
  thingspeakChannel: String,
  thingspeakApiKey: String,
  // farmLocation, farmSize, crops removed per request
});

const Farmer = mongoose.model('Farmer', farmerSchema);

// ================== AUTH MIDDLEWARE ==================
function authMiddleware(req, res, next) {
  const authHeader = req.headers["authorization"];
  if (!authHeader) return res.status(401).json({ error: "No token provided" });

  const token = authHeader.split(" ")[1];
  if (!token) return res.status(401).json({ error: "Invalid token" });

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ error: "Token not valid" });
    req.userId = decoded.id;
    next();
  });
}

// ================== ROUTES ==================

// Root Route
app.get('/', (req, res) => {
  res.send("🌱 Smart Farm API is running!");
});

// Signup Endpoint
app.post('/signup', async (req, res) => {
  try {
    const { username, name, email, password, thingspeakChannel, thingspeakApiKey } = req.body;

    // check if username or email already exists
    const existingUser = await Farmer.findOne({ $or: [{ username }, { email }] });
    if (existingUser) return res.status(400).json({ error: "Username or email already registered" });

    const hashedPassword = await bcrypt.hash(password, 10);
    const farmer = new Farmer({
      username,
      name,
      email,
      password: hashedPassword,
      thingspeakChannel,
      thingspeakApiKey
    });

    await farmer.save();
    res.status(200).json({ message: "Farmer registered successfully!" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

// Login Endpoint (username OR email + password)
app.post('/login', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    if (!password || (!username && !email)) {
      return res.status(400).json({ error: "Provide username/email and password" });
    }

    // Find farmer by username OR email
    const farmer = await Farmer.findOne({ $or: [{ username }, { email }] });
    if (!farmer) return res.status(400).json({ error: "Invalid username or email" });

    // Compare password
    const isMatch = await bcrypt.compare(password, farmer.password);
    if (!isMatch) return res.status(400).json({ error: "Invalid password" });

    // Generate JWT
    const token = jwt.sign({ id: farmer._id }, process.env.JWT_SECRET, { expiresIn: "1h" });

    // Send back farmer data without password
    const safeFarmer = farmer.toObject();
    delete safeFarmer.password;

    res.status(200).json({ message: "Login successful", token, farmer: safeFarmer });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});


// Protected Farmer Data Endpoint
app.get('/farmer/data', authMiddleware, async (req, res) => {
  try {
    const farmer = await Farmer.findById(req.userId).select("-password");
    if (!farmer) return res.status(404).json({ error: "Farmer not found" });

    let sensorData = {};

    // ✅ Check that user has Thingspeak details
    if (!farmer.thingspeakChannel || !farmer.thingspeakApiKey) {
      return res.status(400).json({
        error: "Thingspeak credentials missing for this user",
        farmer
      });
    }

    try {
      const tsResponse = await axios.get(
        `https://api.thingspeak.com/channels/${farmer.thingspeakChannel}/feeds.json`,
        {
          params: {
            api_key: farmer.thingspeakApiKey,
            results: 1, // latest entry only
          }
        }
      );

      const feeds = tsResponse.data.feeds?.[0];
      const channelFields = tsResponse.data.channel;

      if (!feeds || !channelFields) {
        return res.status(404).json({ error: "No Thingspeak data available", farmer });
      }

      // ✅ Dynamically map all field names and values
      for (let i = 1; i <= 8; i++) {
        const fieldKey = `field${i}`;
        const fieldName = channelFields[fieldKey];
        if (fieldName && feeds[fieldKey] !== undefined && feeds[fieldKey] !== null) {
          sensorData[fieldName] = feeds[fieldKey];
        }
      }

      res.status(200).json({ farmer, sensorData });

    } catch (err) {
      console.error("Thingspeak fetch error:", err.message);
      return res.status(502).json({
        error: "Unable to fetch Thingspeak data",
        farmer
      });
    }

  } catch (err) {
    console.error("Server error:", err.message);
    res.status(500).json({ error: "Server error" });
  }
});


// ================== START SERVER ==================
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`🚀 Server running on port ${PORT}`));

