const express = require("express");
const sql = require("mssql");
const cors = require("cors");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static("public")); // Serve static files from "public" folder

// Database Configuration for MSSQL
const config = {
    username: "ACE\Ananya",
    // password: "mypassword",
    server: "ACE\SQLEXPRESS",  // or "ACE\\SQLEXPRESS" // Specify custom port
    database: "clinic_appointments1",
    options: {
        trustServerCertificate: true,
        encrypt: false
    }
};

// Connect to MSSQL Database
const poolPromise = new sql.ConnectionPool(config)
    .connect()
    .then(pool => {
        console.log("✅ Connected to MSSQL database.");
        return pool;
    })
    .catch(err => {
        console.error("❌ Database connection failed:", err);
    });

// Serve index.html
app.get("/", (req, res) => {
    res.sendFile(path.join(__dirname, "public", "index.html"));
});

// Route to get all tables
app.get("/tables", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().query("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'");
        res.json(result.recordset);
    } catch (err) {
        console.error("Error fetching tables:", err);
        res.status(500).json({ error: "Database query failed" });
    }
});

// Route to get all doctors
app.get("/doctors", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().query("SELECT * FROM doctors");
        res.json(result.recordset);
    } catch (err) {
        console.error("Error fetching doctors:", err);
        res.status(500).json({ error: "Failed to fetch doctors" });
    }
});

// Route to get available appointments
app.get("/appointments", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().query("SELECT * FROM appointments WHERE status='Scheduled'");
        res.json(result.recordset);
    } catch (err) {
        console.error("Error fetching appointments:", err);
        res.status(500).json({ error: "Failed to fetch appointments" });
    }
});

// Route to book an appointment
app.post("/book", async (req, res) => {
    const { patient_id, doctor_id, appointment_date, appointment_time } = req.body;
    if (!patient_id || !doctor_id || !appointment_date || !appointment_time) {
        return res.status(400).json({ error: "All fields are required" });
    }

    try {
        const pool = await poolPromise;
        const query = `
            INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, status) 
            VALUES (@patient_id, @doctor_id, @appointment_date, @appointment_time, 'Scheduled')
        `;
        await pool.request()
            .input("patient_id", sql.Int, patient_id)
            .input("doctor_id", sql.Int, doctor_id)
            .input("appointment_date", sql.Date, appointment_date)
            .input("appointment_time", sql.Time, appointment_time)
            .query(query);

        res.json({ message: "Appointment booked successfully" });
    } catch (err) {
        console.error("Error booking appointment:", err);
        res.status(500).json({ error: "Failed to book appointment" });
    }
});

// Start the server
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
});

// Remember to create a 'public' folder and place index.html inside it!
