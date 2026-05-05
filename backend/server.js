const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/faceattend', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected'))
.catch(err => console.log('MongoDB connection error:', err));

// Models
const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['admin', 'manager'], default: 'admin' },
});

const EmployeeSchema = new mongoose.Schema({
  employeeId: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  department: { type: String, required: true },
  position: { type: String, required: true },
  email: { type: String },
  phone: { type: String },
  faceTemplate: { type: [Number] }, // Store as array of numbers
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

const AttendanceSchema = new mongoose.Schema({
  employeeId: { type: String, required: true },
  timestamp: { type: Date, required: true, default: Date.now },
  type: { type: String, enum: ['check_in', 'check_out'], required: true },
  confidence: { type: Number, default: 0 },
  location: { type: String },
  deviceId: { type: String },
});

const User = mongoose.model('User', UserSchema);
const Employee = mongoose.model('Employee', EmployeeSchema);
const Attendance = mongoose.model('Attendance', AttendanceSchema);

// Auth middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) return res.sendStatus(401);
  
  jwt.verify(token, process.env.JWT_SECRET || 'your_secret_key', (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// Routes
app.get('/', (req, res) => {
    res.json({ message: 'FaceAttend Backend API' });
});

// Auth routes
app.post('/api/auth/login', async (req, res) => {
    try {
        const { username, password } = req.body;
        const user = await User.findOne({ username });
        
        if (!user) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }
        
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }
        
        const accessToken = jwt.sign(
            { userId: user._id, username: user.username, role: user.role },
            process.env.JWT_SECRET || 'your_secret_key',
            { expiresIn: '8h' }
        );
        
        res.json({ 
            accessToken,
            user: {
                id: user._id,
                username: user.username,
                role: user.role
            }
        });
    } catch (error) {
        res.status(500).json({ message: 'Server error' });
    }
});

// Employee routes
app.get('/api/employees', authenticateToken, async (req, res) => {
    try {
        const employees = await Employee.find({ isActive: true });
        res.json(employees);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching employees' });
    }
});

app.post('/api/employees', authenticateToken, async (req, res) => {
    try {
        const { employeeId, name, department, position, email, phone, faceTemplate } = req.body;
        
        const existingEmployee = await Employee.findOne({ employeeId });
        if (existingEmployee) {
            return res.status(400).json({ message: 'Employee ID already exists' });
        }
        
        const employee = new Employee({
            employeeId,
            name,
            department,
            position,
            email: email || '',
            phone: phone || '',
            faceTemplate: faceTemplate || [],
        });
        
        const savedEmployee = await employee.save();
        res.status(201).json(savedEmployee);
    } catch (error) {
        res.status(500).json({ message: 'Error creating employee' });
    }
});

// Attendance routes
app.post('/api/attendance', authenticateToken, async (req, res) => {
    try {
        const { employeeId, type, confidence, location, deviceId } = req.body;
        
        // Verify employee exists
        const employee = await Employee.findOne({ employeeId, isActive: true });
        if (!employee) {
            return res.status(404).json({ message: 'Employee not found' });
        }
        
        const attendance = new Attendance({
            employeeId,
            type,
            confidence: confidence || 0,
            location: location || '',
            deviceId: deviceId || '',
        });
        
        const savedAttendance = await attendance.save();
        res.status(201).json(savedAttendance);
    } catch (error) {
        res.status(500).json({ message: 'Error recording attendance' });
    }
});

app.get('/api/attendance/reports', authenticateToken, async (req, res) => {
    try {
        const { employeeId, startDate, endDate } = req.query;
        
        let query = {};
        if (employeeId) query.employeeId = employeeId;
        if (startDate || endDate) {
            query.timestamp = {};
            if (startDate) query.timestamp.$gte = new Date(startDate);
            if (endDate) query.timestamp.$lte = new Date(endDate);
        }
        
        const attendance = await Attendance.find(query).populate('employeeId', 'name department');
        res.json(attendance);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching attendance reports' });
    }
});

// Create default admin user if none exists
const createDefaultAdmin = async () => {
    try {
        const adminExists = await User.findOne({ username: 'admin' });
        if (!adminExists) {
            const hashedPassword = await bcrypt.hash('admin123', 10);
            const admin = new User({
                username: 'admin',
                password: hashedPassword,
                role: 'admin',
            });
            await admin.save();
            console.log('Default admin user created: admin/admin123');
        }
    } catch (error) {
        console.error('Error creating default admin:', error);
    }
};

// Start server
const startServer = async () => {
    await createDefaultAdmin();
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
};

startServer();
