console.log("✅ application.js chargé !");

// Importation des dépendances
import "bootstrap";
import "controllers/stats_chart";  // Assure que stats_chart.js est bien inclus
console.log("✅ stats_chart.js devrait être importé !");

// Désactivation de @rails/ujs (inutile avec Importmap)
console.log("⚠️ @rails/ujs n'est pas nécessaire avec Importmap.");
