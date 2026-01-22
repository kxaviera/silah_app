#!/bin/bash

# Backend Environment Setup Helper
# This script helps generate secure random strings for JWT secrets

echo "🔐 Generating Secure JWT Secrets..."
echo ""

# Generate JWT Secret
JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
echo "JWT_SECRET=$JWT_SECRET"
echo ""

# Generate Admin JWT Secret
ADMIN_JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
echo "ADMIN_JWT_SECRET=$ADMIN_JWT_SECRET"
echo ""

echo "✅ Copy these values to your .env file"
echo ""
echo "⚠️  Keep these secrets secure and never commit them to git!"
