console.log("✅ stats_chart.js chargé !");

// Vérification que Chart.js est bien chargé
document.addEventListener("DOMContentLoaded", function () {
  console.log("✅ DOM complètement chargé !");

  if (typeof window.Chart === "undefined") {
    console.error("❌ Erreur : Chart.js n'a pas été chargé !");
    return;
  }

  console.log("📊 Vérification Chart.js :", window.Chart);

  const canvas = document.getElementById("statsChart");

  if (!canvas) {
    console.error("❌ Erreur : Le canvas #statsChart n'existe pas !");
    return;
  }

  console.log("🎨 Canvas trouvé :", canvas);
  console.log("📊 Données stats (brutes) :", canvas.dataset.stats);

  let statsData;
  try {
    statsData = JSON.parse(canvas.dataset.stats);
  } catch (error) {
    console.error("❌ Erreur de parsing JSON :", error);
    return;
  }

  console.log("📈 Labels :", statsData.map(stat => stat.name));
  console.log("📊 Niveaux :", statsData.map(stat => stat.level));

  const ctx = canvas.getContext("2d");

  new window.Chart(ctx, {
    type: "radar",
    data: {
      labels: statsData.map(stat => stat.name),
      datasets: [{
        data: statsData.map(stat => stat.level),
        backgroundColor: "rgba(0, 153, 255, 0.2)",  // ✅ Bleu léger, moins saturé
        borderColor: "#00A3CC",  // ✅ Bleu néon atténué
        borderWidth: 2,  // ✅ Traits plus fins mais visibles
        pointBackgroundColor: "#111",  // ✅ Points légèrement plus sombres pour contraster
        pointBorderColor: "#00A3CC",  // ✅ Bordure néon atténuée
        pointBorderWidth: 2,  // ✅ Bordure plus fine
        pointRadius: 7,  // ✅ Taille équilibrée
        pointHoverRadius: 10,
        pointStyle: 'circle',
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },  // ✅ Suppression de la légende
        tooltip: { enabled: false },  // ✅ Désactivation des tooltips
      },
      scales: {
        r: {
          angleLines: { display: false },  // ✅ Suppression des lignes entre les axes
          grid: { display: false },  // ✅ Suppression de la grille
          suggestedMin: 0,
          suggestedMax: Math.max(...statsData.map(stat => stat.level)) + 5,
          ticks: { display: false },  // ✅ Suppression des valeurs des axes
          pointLabels: { font: { size: 14, weight: 'bold' }, color: "#00A3CC" },  // ✅ Labels bleus mais moins flashy
        }
      },
      elements: {
        line: { borderWidth: 1.8 },  // ✅ Traits équilibrés
      },
      animation: {
        duration: 800,
      },
    },
    plugins: [{
      // Plugin pour afficher les niveaux sur les points avec un effet lumineux atténué
      afterDatasetsDraw: function (chart) {
        const ctx = chart.ctx;
        ctx.font = "bold 14px Arial";
        ctx.fillStyle = "#00A3CC";  // ✅ Bleu atténué pour les chiffres
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.shadowColor = "#00A3CC";  // ✅ Glow plus léger
        ctx.shadowBlur = 5;  // ✅ Moins d'effet flashy

        chart.data.datasets.forEach((dataset, i) => {
          const meta = chart.getDatasetMeta(i);
          meta.data.forEach((point, index) => {
            const value = dataset.data[index];

            // ✅ Garde ton positionnement précis des chiffres
            let xOffset = 0;
            let yOffset = 0;

            if (index === 0) {  
              yOffset = -18; // ✅ Le premier chiffre (en haut) au-dessus
            } else if (index === 1 || index === 2) {  
              xOffset = 18; // ✅ Les deux de gauche à gauche
            } else {  
              xOffset = -18; // ✅ Les deux de droite à droite
            }

            ctx.fillText(value, point.x + xOffset, point.y + yOffset);

            // ✅ Cercle en pointillés plus subtil
            ctx.beginPath();
            ctx.arc(point.x, point.y, 13, 0, Math.PI * 2);
            ctx.setLineDash([4, 2]);  
            ctx.strokeStyle = "#00A3CC";
            ctx.lineWidth = 1.5;
            ctx.globalAlpha = 0.6;  // ✅ Opacité plus douce
            ctx.stroke();
            ctx.setLineDash([]);  
            ctx.globalAlpha = 1;
          });
        });
      }
    }]
  });

  console.log("✅ Graphique style gaming (moins flashy) généré avec succès !");
});
