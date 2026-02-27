const nodemailer = require('nodemailer');

/**
 * Shared Nodemailer transporter using Gmail SMTP.
 * Uses App Password from .env (EMAIL_PASS).
 */
const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 587,
    secure: false, // TLS via STARTTLS
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,  // Gmail App Password 
    },
});

/**
 * Send a welcome email after registration.
 * @param {string} toEmail
 * @param {string} username
 */
async function sendWelcomeEmail(toEmail, username) {
    await transporter.sendMail({
        from: `"${process.env.EMAIL_FROM_NAME}" <${process.env.EMAIL_USER}>`,
        to: toEmail,
        subject: '🎉 Welcome to InventorySMS!',
        html: `
        <!DOCTYPE html>
        <html lang="en">
        <body style="margin:0;padding:0;font-family:Arial,sans-serif;background:#f4f4f4;">
          <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f4f4;padding:30px 0;">
            <tr><td align="center">
              <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
                <!-- Header -->
                <tr>
                  <td style="background:linear-gradient(135deg,#1a73e8,#0d47a1);padding:40px 40px 30px;text-align:center;">
                    <h1 style="color:#ffffff;margin:0;font-size:28px;letter-spacing:1px;">📦 InventorySMS</h1>
                    <p style="color:#bbdefb;margin:8px 0 0;font-size:14px;">Inventory Management System</p>
                  </td>
                </tr>
                <!-- Body -->
                <tr>
                  <td style="padding:40px;">
                    <h2 style="color:#1a73e8;margin:0 0 16px;">Welcome, ${username}! </h2>
                    <p style="color:#555;font-size:15px;line-height:1.6;margin:0 0 16px;">
                      Your account has been successfully created. You can now log in and start managing your inventory.
                    </p>
                    <table width="100%" cellpadding="12" style="background:#f0f7ff;border-radius:6px;margin:24px 0;">
                      <tr>
                        <td>
                          <p style="margin:0;font-size:14px;color:#555;"> <strong>Email:</strong> ${toEmail}</p>
                        </td>
                      </tr>
                    </table>
                    <p style="color:#555;font-size:15px;line-height:1.6;margin:0;">
                      If you did not create this account, please ignore this email.
                    </p>
                  </td>
                </tr>
                <!-- Footer -->
                <tr>
                  <td style="background:#f9f9f9;padding:20px 40px;text-align:center;border-top:1px solid #eee;">
                    <p style="color:#aaa;font-size:12px;margin:0;">© 2026 InventorySMS · All rights reserved</p>
                  </td>
                </tr>
              </table>
            </td></tr>
          </table>
        </body>
        </html>
        `,
    });
}

/**
 * Send OTP email for password reset.
 * @param {string} toEmail
 * @param {string} username
 * @param {string} otp
 */
async function sendOtpEmail(toEmail, username, otp) {
    await transporter.sendMail({
        from: `"${process.env.EMAIL_FROM_NAME}" <${process.env.EMAIL_USER}>`,
        to: toEmail,
        subject: '🔐 Your Password Reset OTP',
        html: `
        <!DOCTYPE html>
        <html lang="en">
        <body style="margin:0;padding:0;font-family:Arial,sans-serif;background:#f4f4f4;">
          <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f4f4;padding:30px 0;">
            <tr><td align="center">
              <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
                <!-- Header -->
                <tr>
                  <td style="background:linear-gradient(135deg,#e53935,#b71c1c);padding:40px 40px 30px;text-align:center;">
                    <h1 style="color:#ffffff;margin:0;font-size:28px;letter-spacing:1px;">📦 InventorySMS</h1>
                    <p style="color:#ffcdd2;margin:8px 0 0;font-size:14px;">Password Reset Request</p>
                  </td>
                </tr>
                <!-- Body -->
                <tr>
                  <td style="padding:40px;">
                    <h2 style="color:#e53935;margin:0 0 16px;">Hi, ${username}!</h2>
                    <p style="color:#555;font-size:15px;line-height:1.6;margin:0 0 24px;">
                      We received a request to reset your password. Use the OTP code below to proceed.
                      This code is valid for <strong>10 minutes</strong>.
                    </p>

                    <!-- OTP Box -->
                    <table width="100%" cellpadding="0" cellspacing="0">
                      <tr><td align="center">
                        <div style="display:inline-block;background:#fff3e0;border:2px dashed #e53935;border-radius:8px;padding:20px 40px;text-align:center;">
                          <p style="margin:0 0 4px;font-size:12px;color:#999;letter-spacing:2px;text-transform:uppercase;">Your OTP Code</p>
                          <p style="margin:0;font-size:40px;font-weight:bold;letter-spacing:12px;color:#e53935;">${otp}</p>
                        </div>
                      </td></tr>
                    </table>

                    <p style="color:#888;font-size:13px;line-height:1.6;margin:24px 0 0;text-align:center;">
                      ⚠️ Do not share this code with anyone.<br/>
                      If you did not request a password reset, please ignore this email.
                    </p>
                  </td>
                </tr>
                <!-- Footer -->
                <tr>
                  <td style="background:#f9f9f9;padding:20px 40px;text-align:center;border-top:1px solid #eee;">
                    <p style="color:#aaa;font-size:12px;margin:0;">© 2026 InventorySMS · All rights reserved</p>
                  </td>
                </tr>
              </table>
            </td></tr>
          </table>
        </body>
        </html>
        `,
    });
}

module.exports = { sendWelcomeEmail, sendOtpEmail };
