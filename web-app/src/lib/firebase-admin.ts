import admin from "firebase-admin";

const firebaseCredentials = process.env.FIREBASE_ADMIN_CREDENTIALS;

if (!firebaseCredentials) {
  throw new Error("FIREBASE_ADMIN_CREDENTIALS is not set in environment variables.");
}

let serviceAccount: admin.ServiceAccount;

try {
  serviceAccount = JSON.parse(firebaseCredentials);
} catch (error) {   
    console.log(firebaseCredentials)
  throw new Error("Invalid JSON format in FIREBASE_ADMIN_CREDENTIALS.");
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

export default admin;
