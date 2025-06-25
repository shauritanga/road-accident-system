# TARURA Web Portal - Deployment Guide

## 🚀 Quick Deployment

### Option 1: Firebase Hosting (Recommended)

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Initialize Firebase Hosting**
   ```bash
   firebase init hosting
   ```
   - Select your existing Firebase project
   - Set public directory to `build`
   - Configure as single-page app: Yes
   - Don't overwrite index.html

4. **Build the project**
   ```bash
   npm run build
   ```

5. **Deploy**
   ```bash
   firebase deploy --only hosting
   ```

### Option 2: Netlify

1. **Build the project**
   ```bash
   npm run build
   ```

2. **Deploy to Netlify**
   - Drag and drop the `build` folder to Netlify
   - Or connect your Git repository for automatic deployments

### Option 3: Vercel

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Deploy**
   ```bash
   vercel --prod
   ```

## 🔧 Environment Configuration

### Production Environment Variables

Create a `.env.production` file:

```env
REACT_APP_FIREBASE_API_KEY=your_production_api_key
REACT_APP_FIREBASE_AUTH_DOMAIN=road-accident-system-dit.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=road-accident-system-dit
REACT_APP_FIREBASE_STORAGE_BUCKET=road-accident-system-dit.firebasestorage.app
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=1060591687534
REACT_APP_FIREBASE_APP_ID=1:1060591687534:web:569b8e99432f41efdad37f

REACT_APP_NAME=TARURA Road Accident Portal
REACT_APP_VERSION=1.0.0
REACT_APP_ENABLE_DEVTOOLS=false
```

## 🔐 Security Checklist

### Firebase Security Rules

Ensure your Firestore security rules allow read access for the web app:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to accidents collection
    match /accidents/{document} {
      allow read: if true; // Adjust based on your auth requirements
    }
    
    // Allow read access to config collection
    match /config/{document} {
      allow read: if true;
    }
    
    // Allow read access to users collection (for admin purposes)
    match /users/{document} {
      allow read: if true; // Adjust based on your auth requirements
    }
  }
}
```

### HTTPS Configuration

- Ensure your hosting platform serves the app over HTTPS
- Configure proper SSL certificates
- Set up HTTP to HTTPS redirects

### Content Security Policy

Add CSP headers to your hosting configuration:

```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline' https://unpkg.com; img-src 'self' data: https:; connect-src 'self' https://*.googleapis.com https://*.firebaseio.com;
```

## 📊 Performance Optimization

### Build Optimization

The project is already configured with:
- Code splitting
- Tree shaking
- Minification
- Gzip compression

### CDN Configuration

For better performance, configure your CDN to:
- Cache static assets (JS, CSS, images) for 1 year
- Cache HTML files for 1 hour
- Enable Brotli compression

### Monitoring

Set up monitoring for:
- Page load times
- Error tracking
- User analytics
- Firebase usage metrics

## 🔄 CI/CD Pipeline

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches: [ main ]

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Build
        run: npm run build
        
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: road-accident-system-dit
```

## 🌐 Custom Domain

### Firebase Hosting Custom Domain

1. **Add custom domain in Firebase Console**
   - Go to Hosting section
   - Click "Add custom domain"
   - Enter your domain (e.g., portal.tarura.go.tz)

2. **Configure DNS**
   - Add the provided DNS records to your domain registrar
   - Wait for SSL certificate provisioning

3. **Verify setup**
   - Check that your domain redirects to HTTPS
   - Test all functionality on the custom domain

## 📱 Mobile Optimization

The portal is responsive, but for optimal mobile experience:
- Test on various device sizes
- Ensure touch targets are at least 44px
- Optimize images for mobile bandwidth
- Consider implementing a PWA manifest

## 🔍 SEO Configuration

Add meta tags for better SEO:

```html
<meta name="description" content="TARURA Road Accident Information System - Professional portal for Tanzania Road and Traffic Authority">
<meta name="keywords" content="TARURA, Tanzania, road safety, accident data, traffic authority">
<meta property="og:title" content="TARURA Road Accident Portal">
<meta property="og:description" content="Professional web portal for road accident data analysis">
<meta property="og:type" content="website">
```

## 📞 Support & Maintenance

### Regular Maintenance Tasks

1. **Update dependencies monthly**
   ```bash
   npm audit
   npm update
   ```

2. **Monitor Firebase usage**
   - Check Firestore read/write quotas
   - Monitor hosting bandwidth
   - Review security rules

3. **Performance monitoring**
   - Check Core Web Vitals
   - Monitor error rates
   - Review user feedback

### Backup Strategy

- Firebase automatically backs up Firestore data
- Keep a copy of your deployment configuration
- Document any custom modifications

---

**Deployment completed successfully!** 🎉

Your TARURA web portal is now live and ready to help improve road safety in Tanzania.
