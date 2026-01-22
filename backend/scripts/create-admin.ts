import mongoose from 'mongoose';
import dotenv from 'dotenv';
import { AdminUser } from '../src/models/AdminUser.model';

// Load environment variables
dotenv.config();

async function createAdmin() {
  try {
    // Connect to MongoDB
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/silah';
    await mongoose.connect(mongoURI);
    console.log('✅ Connected to MongoDB');

    // Get admin details from environment or use defaults
    const email = process.env.ADMIN_EMAIL || 'admin@silah.com';
    const password = process.env.ADMIN_PASSWORD || 'admin123';
    const fullName = process.env.ADMIN_NAME || 'Admin User';

    // Check if admin already exists
    const existingAdmin = await AdminUser.findOne({ email });
    if (existingAdmin) {
      console.log('⚠️  Admin user already exists!');
      console.log(`   Email: ${existingAdmin.email}`);
      console.log(`   Name: ${existingAdmin.fullName}`);
      console.log(`   Role: ${existingAdmin.role}`);
      process.exit(0);
    }

    // Create admin user
    const admin = new AdminUser({
      email,
      password, // Will be hashed by pre-save hook
      fullName,
      role: 'super_admin',
      isActive: true,
    });

    await admin.save();
    
    console.log('\n✅ Admin user created successfully!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📧 Email:    ${email}`);
    console.log(`🔑 Password: ${password}`);
    console.log(`👤 Name:     ${fullName}`);
    console.log(`🎭 Role:     super_admin`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('\n⚠️  IMPORTANT: Change the password after first login!');
    console.log('\n💡 You can now login to the admin dashboard at:');
    console.log('   http://localhost:3000/login\n');

    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error creating admin:', error.message);
    process.exit(1);
  }
}

createAdmin();
