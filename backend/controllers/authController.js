const { poolPromise, sql } = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { sendWelcomeEmail, sendOtpEmail } = require('../config/email');

// ─── SIGNUP ───────────────────────────────────────────────────────────────────
exports.signup = async (req, res) => {
    try {
        const { username, email, password } = req.body;

        // Validate required fields
        if (!username || !email || !password) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        // Validate password length
        if (password.length < 6) {
            return res.status(400).json({ message: 'Password must be at least 6 characters' });
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({ message: 'Invalid email format' });
        }

        const pool = await poolPromise;
        const hashedPassword = await bcrypt.hash(password, 12);

        await pool.request()
            .input('username', sql.NVarChar, username)
            .input('email', sql.NVarChar, email)
            .input('password', sql.NVarChar, hashedPassword)
            .query('INSERT INTO Users (username, email, password) VALUES (@username, @email, @password)');

        // Send welcome email (non-blocking — don't fail signup if email fails)
        sendWelcomeEmail(email, username).catch(err =>
            console.error('Welcome email failed:', err.message)
        );

        res.status(201).json({ message: 'Account created successfully! Please check your email.' });
    } catch (err) {
        if (err.number === 2627) {
            return res.status(400).json({ message: 'Username or email already exists' });
        }
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};

// ─── LOGIN ────────────────────────────────────────────────────────────────────
exports.login = async (req, res) => {
    try {
        const { identifier, password } = req.body; // identifier = username OR email

        if (!identifier || !password) {
            return res.status(400).json({ message: 'Identifier and password are required' });
        }

        const pool = await poolPromise;
        const result = await pool.request()
            .input('identifier', sql.NVarChar, identifier)
            .query('SELECT * FROM Users WHERE username = @identifier OR email = @identifier');

        const user = result.recordset[0];
        if (!user) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const token = jwt.sign(
            { userId: user.id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.status(200).json({
            token,
            userId: user.id,
            username: user.username,
            email: user.email,
        });
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};

// ─── FORGOT PASSWORD ──────────────────────────────────────────────────────────
exports.forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ message: 'Email is required' });
        }

        const pool = await poolPromise;
        const result = await pool.request()
            .input('email', sql.NVarChar, email)
            .query('SELECT * FROM Users WHERE email = @email');

        const user = result.recordset[0];
        if (!user) {
            // Return 200 to avoid revealing whether an email exists (security best practice)
            return res.status(200).json({ message: 'If this email is registered, an OTP has been sent.' });
        }

        // Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const expiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes from now

        // Store OTP and expiry in database
        await pool.request()
            .input('otp', sql.NVarChar, otp)
            .input('expiry', sql.DateTime, expiry)
            .input('email', sql.NVarChar, email)
            .query('UPDATE Users SET otp = @otp, otp_expiry = @expiry WHERE email = @email');

        // Send OTP email
        try {
            await sendOtpEmail(email, user.username, otp);
            console.log(`OTP email sent to ${email}`);
        } catch (mailErr) {
            console.error('OTP email failed:', mailErr.message);
            // Still continue — return OTP in response for dev/demo purposes
            return res.status(200).json({
                message: 'Email could not be sent. Here is your OTP for testing.',
                otp, // ⚠️ Remove this in production!
            });
        }

        res.status(200).json({ message: 'OTP sent to your email. Valid for 10 minutes.' });
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};

// ─── VERIFY OTP & RESET PASSWORD ─────────────────────────────────────────────
exports.resetPassword = async (req, res) => {
    try {
        const { email, otp, newPassword } = req.body;

        if (!email || !otp || !newPassword) {
            return res.status(400).json({ message: 'Email, OTP, and new password are required' });
        }

        if (newPassword.length < 6) {
            return res.status(400).json({ message: 'Password must be at least 6 characters' });
        }

        const pool = await poolPromise;
        const result = await pool.request()
            .input('email', sql.NVarChar, email)
            .query('SELECT otp, otp_expiry FROM Users WHERE email = @email');

        const user = result.recordset[0];
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Check OTP match
        if (user.otp !== otp) {
            return res.status(400).json({ message: 'Invalid OTP' });
        }

        // Check OTP expiry
        if (new Date() > new Date(user.otp_expiry)) {
            return res.status(400).json({ message: 'OTP has expired. Please request a new one.' });
        }

        // Update password and clear OTP
        const hashedPassword = await bcrypt.hash(newPassword, 12);
        await pool.request()
            .input('password', sql.NVarChar, hashedPassword)
            .input('email', sql.NVarChar, email)
            .query('UPDATE Users SET password = @password, otp = NULL, otp_expiry = NULL WHERE email = @email');

        res.status(200).json({ message: 'Password reset successfully! You can now log in.' });
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};
