const jwt = require('jsonwebtoken');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'default-secret-key-change-this';

/**
 * Generate JWT token
 */
function generateToken(userId, phone) {
  return jwt.sign(
    { userId, phone },
    JWT_SECRET,
    { expiresIn: '30d' }
  );
}

/**
 * Verify JWT token middleware
 */
function verifyToken(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.replace('Bearer ', '');
    const decoded = jwt.verify(token, JWT_SECRET);
    
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

module.exports = {
  generateToken,
  verifyToken
};
