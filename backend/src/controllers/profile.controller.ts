import { Response } from 'express';
import { User } from '../models/User.model';
import { ProfileView } from '../models/ProfileView.model';
import { AuthRequest } from '../middleware/auth.middleware';
import multer from 'multer';
import path from 'path';
import fs from 'fs';

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'uploads/profile-photos';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'photo-' + uniqueSuffix + path.extname(file.originalname));
  },
});

export const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (extname && mimetype) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  },
});

// Complete profile
export const completeProfile = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;
    const {
      role, // Role can be updated in complete profile
      name,
      dateOfBirth,
      gender,
      height,
      complexion,
      livingCountry,
      state,
      city,
      caste,
      education,
      profession,
      annualIncome,
      about,
      partnerPreferences,
      hideMobile,
      hidePhotos,
      profileHandledBy,
      // Family details
      fatherName,
      fatherOccupation,
      motherName,
      motherOccupation,
      brothersCount,
      brothersMaritalStatus,
      sistersCount,
      sistersMaritalStatus,
      profilePhoto,
    } = req.body;

    const updateData: any = {
      isProfileComplete: true,
      // Set verification status to false (Under Review) when profile is completed
      // Admin will verify later
      isVerified: false,
    };

    // Update role if provided
    if (role && ['bride', 'groom'].includes(role)) {
      updateData.role = role;
    }

    const updateData: any = {
      isProfileComplete: true,
      // Set verification status to false (Under Review) when profile is completed
      // Admin will verify later
      isVerified: false,
      role, // Role is REQUIRED
      fullName: name, // Full name is REQUIRED
    };

    // Update date of birth and calculate age
    if (dateOfBirth) {
      updateData.dateOfBirth = new Date(dateOfBirth);
      const dob = new Date(dateOfBirth);
      const today = new Date();
      let age = today.getFullYear() - dob.getFullYear();
      const monthDiff = today.getMonth() - dob.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dob.getDate())) {
        age--;
      }
      updateData.age = age;
    }

    // Update gender if provided
    if (gender) updateData.gender = gender;

    // Update current status if provided
    if (currentStatus) updateData.currentStatus = currentStatus;

    if (height !== undefined) updateData.height = height;
    if (complexion) updateData.complexion = complexion;
    if (physicalStatus) updateData.physicalStatus = physicalStatus;
    if (livingCountry) updateData.livingCountry = livingCountry;
    if (state) updateData.state = state;
    if (city) updateData.city = city;
    if (caste) updateData.caste = caste;
    if (education) updateData.education = education;
    if (profession) updateData.profession = profession;
    if (annualIncome) updateData.annualIncome = annualIncome;
    if (about) updateData.about = about;
    if (partnerPreferences) updateData.partnerPreferences = partnerPreferences;
    if (hideMobile !== undefined) updateData.hideMobile = hideMobile;
    if (hidePhotos !== undefined) updateData.hidePhotos = hidePhotos;
    if (profileHandledBy) updateData.profileHandledBy = profileHandledBy;
    if (profilePhoto) updateData.profilePhoto = profilePhoto;

    // Family details
    if (fatherName) updateData.fatherName = fatherName;
    if (fatherOccupation) updateData.fatherOccupation = fatherOccupation;
    if (motherName) updateData.motherName = motherName;
    if (motherOccupation) updateData.motherOccupation = motherOccupation;
    if (brothersCount) updateData.brothersCount = brothersCount;
    if (brothersMaritalStatus) updateData.brothersMaritalStatus = brothersMaritalStatus;
    if (sistersCount) updateData.sistersCount = sistersCount;
    if (sistersMaritalStatus) updateData.sistersMaritalStatus = sistersMaritalStatus;

    const user = await User.findByIdAndUpdate(
      userId,
      updateData,
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found.',
      });
      return;
    }

    res.json({
      success: true,
      message: 'Profile completed successfully.',
      user,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to complete profile.',
    });
  }
};

// Upload profile photo
export const uploadPhoto = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    if (!req.file) {
      res.status(400).json({
        success: false,
        message: 'No file uploaded.',
      });
      return;
    }

    const userId = req.user._id;
    const photoUrl = `/uploads/profile-photos/${req.file.filename}`;

    // In production, upload to cloud storage (AWS S3, Cloudinary, etc.)
    // For now, using local storage
    const user = await User.findByIdAndUpdate(
      userId,
      { profilePhoto: photoUrl },
      { new: true }
    ).select('-password');

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found.',
      });
      return;
    }

    res.json({
      success: true,
      message: 'Photo uploaded successfully.',
      photoUrl: user.profilePhoto,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to upload photo.',
    });
  }
};

// Search profiles
export const searchProfiles = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const currentUser = req.user;
    const {
      search,
      country,
      state,
      city,
      religion,
      livingCountry,
      onlyNRIs,
      onlyInIndia,
      minAge,
      maxAge,
      minHeight,
      prioritizeByCity,
      page = 1,
      limit = 20,
    } = req.query;

    // Build query - always filter by opposite role
    const oppositeRole = currentUser.role === 'bride' ? 'groom' : 'bride';
    const query: any = {
      role: oppositeRole,
      isActive: true,
      isBlocked: false,
      isProfileComplete: true,
      // Only show profiles with active boost
      boostStatus: 'active',
      boostExpiresAt: { $gt: new Date() },
    };

    // Search by name
    if (search) {
      query.fullName = { $regex: search, $options: 'i' };
    }

    // Country filter
    if (country) {
      query.country = country;
    }

    // State filter
    if (state) {
      query.state = state;
    }

    // City filter
    if (city) {
      query.city = city;
    }

    // Religion filter
    if (religion) {
      query.religion = religion;
    }

    // Living country filter
    if (livingCountry) {
      query.livingCountry = livingCountry;
    }

    // NRI filter
    if (onlyNRIs === 'true') {
      query.livingCountry = { $ne: query.country || currentUser.country };
    }

    // Only in India filter
    if (onlyInIndia === 'true') {
      query.livingCountry = 'India';
    }

    // Age filter
    if (minAge || maxAge) {
      query.age = {};
      if (minAge) query.age.$gte = parseInt(minAge as string);
      if (maxAge) query.age.$lte = parseInt(maxAge as string);
    }

    // Height filter
    if (minHeight) {
      query.height = { $gte: parseInt(minHeight as string) };
    }

    // Build sort - prioritize by city if requested
    let sort: any = {};
    if (prioritizeByCity && currentUser.city) {
      // Sort by: same city first, then featured, then standard
      sort = {
        city: currentUser.city === query.city ? 1 : -1,
        boostType: 'featured' === 'featured' ? -1 : 1,
        createdAt: -1,
      };
    } else {
      // Sort by: featured first, then standard, then by date
      sort = {
        boostType: 'featured' === 'featured' ? -1 : 1,
        createdAt: -1,
      };
    }

    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const profiles = await User.find(query)
      .select('-password -resetPasswordToken -resetPasswordExpire')
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit as string));

    const total = await User.countDocuments(query);

    // Format response
    const formattedProfiles = profiles.map((profile) => ({
      _id: profile._id,
      fullName: profile.fullName,
      age: profile.age,
      country: profile.country,
      livingCountry: profile.livingCountry,
      state: profile.state,
      city: profile.city,
      religion: profile.religion,
      role: profile.role,
      boostType: profile.boostType,
      featured: profile.boostType === 'featured',
      sponsored: false, // Can be added later
      isVerified: profile.isVerified || false, // Admin verification status
      profession: profile.profession,
      education: profile.education,
      height: profile.height,
      profilePhoto: profile.hidePhotos ? undefined : profile.profilePhoto,
    }));

    res.json({
      success: true,
      profiles: formattedProfiles,
      pagination: {
        page: parseInt(page as string),
        limit: parseInt(limit as string),
        total,
        pages: Math.ceil(total / parseInt(limit as string)),
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to search profiles.',
    });
  }
};

// Get profile by ID
export const getProfile = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { userId } = req.params;
    const currentUser = req.user;
    const isOwnProfile = currentUser._id.toString() === userId;

    const profile = await User.findById(userId).select('-password -resetPasswordToken -resetPasswordExpire');

    if (!profile) {
      res.status(404).json({
        success: false,
        message: 'Profile not found.',
      });
      return;
    }

    // For own profile, always allow access (no boost check)
    // For other profiles, check if profile is boosted
    if (!isOwnProfile) {
      if (!profile.isActive || profile.isBlocked) {
        res.status(404).json({
          success: false,
          message: 'Profile not found.',
        });
        return;
      }

      // Check if profile is boosted (only for viewing other profiles)
      if (profile.boostStatus !== 'active' || !profile.boostExpiresAt || profile.boostExpiresAt < new Date()) {
        res.status(404).json({
          success: false,
          message: 'Profile not available.',
        });
        return;
      }
    }

    // Respect privacy settings (only for other profiles)
    const profileData: any = {
      _id: profile._id,
      fullName: profile.fullName,
      age: profile.age,
      gender: profile.gender,
      country: profile.country,
      livingCountry: profile.livingCountry,
      state: profile.state,
      city: profile.city,
      religion: profile.religion,
      caste: profile.caste,
      education: profile.education,
      profession: profile.profession,
      annualIncome: profile.annualIncome,
      height: profile.height,
      complexion: profile.complexion,
      about: profile.about,
      partnerPreferences: profile.partnerPreferences,
      role: profile.role,
      boostType: profile.boostType,
      boostStatus: profile.boostStatus,
      boostExpiresAt: profile.boostExpiresAt,
      isVerified: profile.isVerified || false,
      emailVerified: profile.emailVerified,
      mobileVerified: profile.mobileVerified,
      idVerified: profile.idVerified,
      verificationNotes: profile.verificationNotes,
      isProfileComplete: profile.isProfileComplete,
    };

    // For own profile, always show mobile and photos
    // For other profiles, respect privacy settings
    if (isOwnProfile) {
      profileData.mobile = profile.mobile;
      profileData.profilePhoto = profile.profilePhoto;
    } else {
      // Hide mobile if privacy setting is enabled
      if (!profile.hideMobile) {
        profileData.mobile = profile.mobile;
      }

      // Hide photos if privacy setting is enabled
      if (!profile.hidePhotos) {
        profileData.profilePhoto = profile.profilePhoto;
      }
    }

    // Create profile view record (only for other profiles)
    if (!isOwnProfile) {
      await ProfileView.create({
        profileUserId: userId,
        viewerUserId: currentUser._id,
        viewedAt: new Date(),
      });
    }

    res.json({
      success: true,
      profile: profileData,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch profile.',
    });
  }
};

// Get profile analytics
export const getAnalytics = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;

    // Get total views
    const totalViews = await ProfileView.countDocuments({ profileUserId: userId });

    // Get recent views (last 10)
    const recentViews = await ProfileView.find({ profileUserId: userId })
      .populate('viewerUserId', 'fullName')
      .sort({ viewedAt: -1 })
      .limit(10)
      .select('viewerUserId viewedAt');

    // TODO: Get likes and shortlists when implemented
    const totalLikes = 0;
    const totalShortlisted = 0;

    // Get total requests received
    const { ContactRequest } = await import('../models/ContactRequest.model');
    const totalRequests = await ContactRequest.countDocuments({ toUserId: userId });

    res.json({
      success: true,
      analytics: {
        totalViews,
        totalLikes,
        totalShortlisted,
        totalRequests,
        recentViews: recentViews.map((view: any) => ({
          viewerId: view.viewerUserId._id,
          viewerName: view.viewerUserId.fullName,
          viewedAt: view.viewedAt,
        })),
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch analytics.',
    });
  }
};
