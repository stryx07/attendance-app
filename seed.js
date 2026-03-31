const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

// Configuration des fichiers
const SERVICE_ACCOUNT_PATH = path.join(__dirname, "serviceAccountKey.json");
const DATA_PATH = path.join(__dirname, "users_data.json");

// Vérification des fichiers requis
if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
  console.error("❌ Erreur : Le fichier 'serviceAccountKey.json' est introuvable !");
  console.log("👉 Veuillez le télécharger depuis Firebase Console > Paramètres du projet > Comptes de service.");
  process.exit(1);
}

if (!fs.existsSync(DATA_PATH)) {
  console.error("❌ Erreur : Le fichier 'users_data.json' est introuvable !");
  process.exit(1);
}

// Chargement des données
const serviceAccount = require(SERVICE_ACCOUNT_PATH);
const { users } = require(DATA_PATH);

// Initialisation de Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function createOrGetUser(u) {
  try {
    const user = await admin.auth().getUserByEmail(u.email);
    console.log(`✅ Utilisateur existe déjà : ${u.email}`);
    return user;
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      const newUser = await admin.auth().createUser({
        email: u.email,
        password: u.password,
        displayName: u.name,
      });
      console.log(`✨ Nouvel utilisateur créé : ${u.email}`);
      return newUser;
    }
    throw error;
  }
}

async function runSeed() {
  console.log("🚀 Lancement de la configuration automatique de la base de données...");
  const stats = [];

  for (const u of users) {
    try {
      const userRecord = await createOrGetUser(u);

      // Mise à jour de Firestore
      await db.collection("users").doc(userRecord.uid).set({
        uid: userRecord.uid,
        email: u.email,
        name: u.name,
        role: u.role,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      stats.push({ Nom: u.name, Email: u.email, Rôle: u.role, Statut: "OK" });
    } catch (e) {
      console.error(`❌ Erreur pour ${u.email}:`, e.message);
      stats.push({ Nom: u.name, Email: u.email, Rôle: u.role, Statut: "ERREUR" });
    }
  }

  console.log("\n📊 Résumé de l'opération :");
  console.table(stats);
  console.log("\n✅ Configuration terminée !");
  process.exit(0);
}

runSeed().catch(err => {
  console.error("💥 Erreur fatale :", err);
  process.exit(1);
});
