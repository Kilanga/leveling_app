import Chart from "chart.js/auto";

document.addEventListener("DOMContentLoaded", function () {
  const canvas = document.getElementById("statsChart");
  if (!canvas) return;

  const ctx = canvas.getContext("2d");
  const statsData = JSON.parse(canvas.dataset.stats);

  const labels = statsData.map(stat => stat.name);
  const data = statsData.map(stat => stat.level);

  new Chart(ctx, {
    type: "radar",
    data: {
      labels: labels,
      datasets: [{
        label: "Niveaux des stats",
        data: data,
        backgroundColor: "rgba(54, 162, 235, 0.2)",
        borderColor: "rgba(54, 162, 235, 1)",
        borderWidth: 2
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        r: {
          beginAtZero: true,
          max: Math.max(...data) + 5
        }
      }
    }
  });
});
